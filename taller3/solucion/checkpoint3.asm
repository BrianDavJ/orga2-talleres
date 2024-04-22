

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar:
NODO_LENGTH	EQU	32
LONGITUD_OFFSET	EQU	24
PACKED_NODO_LENGTH	EQU	28
PACKED_LONGITUD_OFFSET	EQU	20

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
	.ciclo: 

	cmp rdi, 0  ; null es 0 en asm
	je .fin
	
	mov rsi, [rdi + LONGITUD_OFFSET]	; accedemos a nuestra longitud de nodo
	add r9, rsi

	mov rdi, [rdi]	; paso al siguiente nodo
	jmp .ciclo

	.fin:

	mov rax, r9

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
	.ciclo: 

	cmp rdi, 0  ; null es 0 en asm
	je .fin
	
	mov rsi, [rdi + PACKED_LONGITUD_OFFSET]	; accedemos a nuestra longitud de nodo
	add r9, rsi

	mov rdi, [rdi]	; paso al siguiente nodo
	jmp .ciclo

	.fin:

	mov rax, r9

	pop rbp
	ret

