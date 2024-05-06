

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32
LONGITUD_OFFSET	EQU	24
PACKED_NODO_LENGTH	EQU	21
PACKED_LONGITUD_OFFSET	EQU	17
NULL EQU 0
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: lista[rdi]
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp

	; guardamos el elemento a sumar
	; vamos a recorrerlo hasta que next sea null

	xor r9, r9	; va a ser mi contador
	xor rsi, rsi
	xor rax, rax

	mov r8, [rdi]

	.ciclo: 

	cmp r8, 0  ; null es 0 en asm
	je .fin
	
	mov esi, dword [r8 + LONGITUD_OFFSET]	; accedemos a nuestra longitud de nodo
	add r9, rsi

	mov r8, [r8]	; paso al siguiente nodo
	jmp .ciclo

	.fin:

	mov eax, r9d

	pop rbp
	ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros: lista[?]
cantidad_total_de_elementos_packed:
	
	push rbp
	mov rbp, rsp

	; guardamos el elemento a sumar
	; vamos a recorrerlo hasta que next sea null

	xor r9, r9	; va a ser mi contador
	xor rax, rax
	xor rsi, rsi

	mov r8, [rdi] ; aca esta el head por eso hay que poner esto
	

	.ciclo: 

	cmp r8, 0  ; null es 0 en asm
	je .fin
	
	mov r9d, dword [r8 + PACKED_LONGITUD_OFFSET]	; accedemos a nuestra longitud de nodo
	add eax, r9d

	mov r8, [r8]	; paso al siguiente nodo
	jmp .ciclo

	.fin:

	;mov eax, r9d

	pop rbp
	ret

