extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; * String *

; int32_t strCmp(char* a, char* b)
strCmp:

	push rbp
	mov rbp, rsp

	xor rax, rax
	xor r8, r8
	xor r9, r9
	

	.ciclo:
	
	mov r8b, byte [rdi]
	mov r9b, byte [rsi]

	cmp r8,r9		; comparamos si son iguales
	je .iguales		; si son iguales tengo que ver si sigo ciclando o no
	jg .prim_grande	; si el primero es mas grande devuelvo -1
	jl .prim_chico	; es mas chico devuelvo 1
	

	.prim_chico:
	mov rax, 1
	jmp .fin

	.iguales:	
	; nos fijamos si r8 es = 0 (es decir es vacio o llegamos al fin)
	cmp r8, 0	;
	jne .continuo	; si no estoy en el fin tengo que seguir ciclando
	; si r8 = 0 entonces r8 = r9 ya sea porque llegamos al final o porque ya recorrimos todo
	mov rax, 0
	jmp .fin
	; si no son 0 entonces continuo en el ciclo
	
	.continuo:
	inc rdi
	inc rsi
	jmp .ciclo


	.prim_grande:
	mov rax, -1		; si si es igual entonces termina mi ciclo con rax en -1

	.fin:

	pop rbp
	ret

; char* strClone(char* a)
strClone:
	push rbp
    mov rbp, rsp
	push r13
	push r12

    xor r9, r9
    xor rax,rax
	xor r8,r8

	mov r13, rdi

	call strLen
	; en rax esta la long de la palabra

	; hay que pedir uno mas para el 0 del final
	inc rax
	mov rdi, rax	; aca estan en BYTES , la memoria que queremos
	call malloc

	; en rax el puntero que vamos a devolver
    
	mov r12, rax
	.ciclo:
    mov r8b, byte [r13]	; le pasamos la primera letra
    cmp r8b, 0	; comparamos si es el final o no
	
	je .fin

	mov [r12], r8b
	inc r12
	inc r13	
	jmp .ciclo

	.fin:
	mov byte [r12], 0 ; lo tengo que escribir a la fuerza porque sale antes en el ciclo

	pop r12
	pop r13
	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	push rbp
	mov rbp,rsp

	call free

	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
    mov rbp, rsp
	push r11
	push r12

    xor r9, r9
    xor rax,rax
	xor r8,r8

	mov r11, rdi
	mov r12, rsi

	call strLen
	; en rax tenemos la longitud de la palabra

    .ciclo:

    mov r8b, byte [r11]
    cmp r8, 0
    je .contador

	.escribo:
	; le dice al sistema que escriba
	mov r12, r11	; le pasamos el puntero al mensaje
	mov rax, 1
	syscall	
	mov rax, 60
	mov rdi, 0

	inc r9
	jmp .ciclo

	.contador:
	cmp r9, 0
	jne .fin

	.fin: 


	pop r12
	pop r11
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
    push rbp
    mov rbp, rsp

    xor r9, r9
    xor rax,rax
	xor r8,r8

    .ciclo:
    mov r8b, byte [rdi]

    cmp r8, 0
    je .fin

    inc rdi
    inc r9

    jmp .ciclo

    .fin:
    mov eax,r9d

	pop rbp
    ret