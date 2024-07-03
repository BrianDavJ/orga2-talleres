; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start
extern GDT_DESC
extern IDT_DESC
extern gdt
extern screen_draw_box
extern idt_init
extern tss_init
extern pic_enable
extern pic_reset
extern mmu_init_kernel_dir
extern tasks_screen_draw
extern sched_init
extern tasks_init

; COMPLETAR - Agreguen declaraciones extern según vayan necesitando
extern screen_draw_layout
; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL (1 << 3)
%define DS_RING_0_SEL (3 << 3)
%define INIT_RING_0_SEL (11 << 3)
%define IDLE_RING_0_SEL (12 << 3)

BITS 16
;; Saltear seccion de datos
jmp start

;;
;; Seccion de datos.
;; -------------------------------------------------------------------------- ;;
start_rm_msg db     'Iniciando kernel en Modo Real'
start_rm_len equ    $ - start_rm_msg

start_pm_msg db     'Iniciando kernel en Modo Protegido'
start_pm_len equ    $ - start_pm_msg

fila_rm equ 2
col_rm equ 0
;;
;; Seccion de código.
;; -------------------------------------------------------------------------- ;;

;; Punto de entrada del kernel.
BITS 16
start:
    ; COMPLETAR - Deshabilitar interrupciones
    cli

    ; Cambiar modo de video a 80 X 50
    mov ax, 0003h
    int 10h ; set mode 03h
    xor bx, bx
    mov ax, 1112h
    int 10h ; load 8x8 font

    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO REAL
    ; (revisar las funciones definidas en print.mac y los mensajes se encuentran en la
    ; sección de datos)
    ;;  Parametros:
;;      %1: Puntero al mensaje
;;      %2: Longitud del mensaje
;;      %3: Color
;;      %4: Fila
;;      %5: Columna
     print_text_rm start_rm_msg, start_rm_len, 0b010011010, fila_rm, col_rm

;;      * Bit #: 7 6 5 4 3 2 1 0
;;               | | | | | | | |
;;               | | | | | ^-^-^-- Fore color
;;               | | | | ^-------- Fore color bright bit
;;               | ^-^-^---------- Back color
;;               ^---------------- Back color bright bit OR enables blinking text

    ; COMPLETAR - Habilitar A20
    ; (revisar las funciones definidas en a20.asm)
    call A20_enable



    ; COMPLETAR - Cargar la GDT
    lgdt[GDT_DESC]
    ; COMPLETAR - Setear el bit PE del registro CR0
    mov eax, cr0
    or eax,1
    mov cr0,eax
    
    jmp CS_RING_0_SEL:modo_protegido

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ax,0x18;DS_RING_0_SEL
    mov ds,ax
    mov es,ax
    mov gs,ax
    mov fs,ax
    mov ss,ax

    
    ;Establecer el tope y la base de la pila
    mov esp, 0x25000    ;Establecemos el nuevo putero a la pila.
    mov ebp, esp        ;Establecemos la nueva base de la pila (apunta a la misma direccion que el puntero a la pila).
    
    ;Imprimir mensaje de bienvenida - MODO PROTEGIDO
    print_text_pm start_pm_msg, start_pm_len, 0b010011010, fila_rm, col_rm

    ;Inicializar pantalla
    ;call screen_draw_box
    call screen_draw_layout

    call idt_init
    lidt[IDT_DESC];

    call pic_reset
    call pic_enable
    
    call mmu_init_kernel_dir
    
    mov cr3, eax

    xor eax, eax        ;eax = 0
    mov eax, cr0        ;eax = CR0
    or eax, 0x80000000  ;Seteamos el bit 31
    mov cr0, eax        ;Prendemos el bit 31 del CR0 (para habilitar paginacion).
    
    ;Agrega los descriptores de tss de la tarea inicial y idle a la gdt.
    call tss_init

    ;Creamos el scheduler y creamos espacio para 4 tareas y marcamos esos cuatro espacios como libres
    call sched_init
    
    ;Habilita las interrupciones
    ;sti
    
    ;Llamamos a las interrupciones personalizadas para ver si funcionan
    ;int 88
    ;int 98

    ;Dibuja los marcos y títulos iniciales de la "interfaz" del sistema.
    call tasks_screen_draw

    ;Cargamos en ax (16 bits) el selector de segmento que indica que entrada de la GDT
    ;corresponde al descriptor de segmento de tss de la tarea inicial.
    mov ax, INIT_RING_0_SEL

    ;Carga el campo selector de segmento del registro TR
    ltr ax

    call tasks_init
    ;Saltamos a la tarea IDLE
    ;El offset es ignorado porque no queremos acceder a un lugar en el interior de un segmento (como queremos hacer cuando
    ;saltamos a un segmento que tiene su descriptor de segmento y un offset) el descriptor de segmento tiene solo base y 
    ;limite, por eso nesecitamos el offset para acceder a un lugar especifico del segmeto.
    ;Pero en este caso estamos haciendo un cambio de tarea por medio de un JMP, y lo que esta pasando es que el JMP usa el 
    ;selector de segmento que le pasamos como parametro para acceder al descriptor de la gdt que describe el segmento en el
    ;que se encuentra la TSS de la tarea que queremos que pase a ejecutarse.
    ;Ademas, el valor del EIP guardado en la TSS apuntada es cargado en el EIP actual para que la siguiente instruccion a 
    ;ejecutarse sea la proxima instruccion que iba a ejecutar la tarea llamada antes de que sea suspendida.
    ;Al hacer un cambio de tarea por medio de un JMP no se prende el bit NT (nested tastk) del EFLAGS y el campo previous
    ;task link de la TSS no se carga, por lo que no se puede volver a la tarea anterior por mediod de un IRET.
    jmp IDLE_RING_0_SEL:0
   
    ;Ciclar infinitamente
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    ;.aca:
    
    jmp $ ;.aca

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
