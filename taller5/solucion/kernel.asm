; ** por compatibilidad se omiten tildes **
; ==============================================================================
; TALLER System Programming - ORGANIZACION DE COMPUTADOR II - FCEN
; ==============================================================================

%include "print.mac"

global start
extern GDT_DESC
extern gdt
extern screen_draw_box
; COMPLETAR - Agreguen declaraciones extern según vayan necesitando

; COMPLETAR - Definan correctamente estas constantes cuando las necesiten
%define CS_RING_0_SEL 1  
%define DS_RING_0_SEL 3   


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
    call print_text_rm start_rm_msg, start_rm_len, 0b010011010, fila_rm, col_rm

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
    mov rdi, cr0
    inc rdi
    mov cr0,rdi
    jmp CS_RING_0_SEL:modo_protegido ;no sabemos si va ":" o "+"

    ; COMPLETAR - Saltar a modo protegido (far jump)
    ; (recuerden que un far jmp se especifica como jmp CS_selector:address)
    ; Pueden usar la constante CS_RING_0_SEL definida en este archivo

BITS 32
modo_protegido:
    ; COMPLETAR - A partir de aca, todo el codigo se va a ejectutar en modo protegido
    ; Establecer selectores de segmentos DS, ES, GS, FS y SS en el segmento de datos de nivel 0
    ; Pueden usar la constante DS_RING_0_SEL definida en este archivo
    mov ds,gdt[DS_RING_0_SEL]
    mov es,gdt[DS_RING_0_SEL]
    mov gs,gdt[DS_RING_0_SEL]
    mov fs,gdt[DS_RING_0_SEL]
    mov ss,gdt[DS_RING_0_SEL]

    
    ; COMPLETAR - Establecer el tope y la base de la pila
    mov esp, 0x25000
    mov ebp, esp
    
    ; COMPLETAR - Imprimir mensaje de bienvenida - MODO PROTEGIDO
    call print_text_pm start_pm_msg, start_pm_len,0b010011010,fila_rm,col_rm
    ; COMPLETAR - Inicializar pantalla
 
   
    ; Ciclar infinitamente 
    mov eax, 0xFFFF
    mov ebx, 0xFFFF
    mov ecx, 0xFFFF
    mov edx, 0xFFFF
    jmp $

;; -------------------------------------------------------------------------- ;;

%include "a20.asm"
