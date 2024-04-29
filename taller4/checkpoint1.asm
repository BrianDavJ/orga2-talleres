
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto

;rdi->p=[1,2,3,4,5,5,6,7 ,7,8,9,5,2,3,5,64,3]; rsi->q = [1,2,3,4,5,5,6,7 ,7,8,9,5,2,3,5,64,3]; edx->lenth
dot_product_asm:
	push rbp
	mov rbp, rsp

	xor rax, rax

	xor ecx, ecx
	
	.ciclo:
	movdqu xmm0, [rdi] ;cargamos los (128/16 == 8) primeros numeros de p a xmm0 y se guarda la parte baja
	movdqu xmm1, [rsi] ;cargamos los (128/16 == 8) primeros numeros de q a xmm1
	movdqu xmm2, [rdi] ;para guardar la parte alta
	
	pmullw xmm0, xmm1 ;En xmm0 queda la parte baja de la multiplicacion entre xmm0 y xmm1
	pmulhw xmm2, xmm1 ;En xmm2 queda la parte alta de la multiplicacion entre xmm2 y xmm1 (xmm2 == xmm0)

	movdqu xmm1, xmm0 ;para la parte baja  
	PUNPCKLWD xmm0, xmm2 ;los siguientes 4 numeros resultados de la multiplicacion

	PUNPCKHWD xmm1, xmm2 ;los siguientes cuatro numeros resultados de la multiplicacion
	
	PHADDD xmm0, xmm1 ;
	PHADDD xmm0, xmm0
	PHADDD xmm0, xmm0
	
	movd r8d , xmm0

	add eax, r8d

	add rdi, 16 ; aumentamos rdi en el numero de bytes correspondiente a la cantidad de digitos de 16 bits de p operados 
	add rsi, 16 ; aumentamos rsi en el numero de bytes correspondiente a la cantidad de digitos de 16 bits de q operados 
	
	add ecx, 8

	cmp ecx, edx
	jne .ciclo

	

	pop rbp
	ret
