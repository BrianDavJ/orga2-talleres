
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto

;RDI: p, RSI: q, RDX: lenght
dot_product_asm:
	push rbp
	mov rbp, rsp

	xor rax, rax
	xor ecx, ecx
	
	.ciclo:
		movdqu xmm0, [rdi]	;xmm0 = [p7,p6,p5,p4,p3,p2,p1,p0]
		movdqu xmm1, [rsi]	;xmm1 = [q7,q6,q5,q4,q3,q2,q1,q0]							
		movdqu xmm2, [rdi]	;xmm2 = [p7,p6,p5,p4,p3,p2,p1,p0]

		pmullw xmm0, xmm1	;xmm0 = en cada word la parte baja de [p7*q7,p6*q6,p5*q5,p4*q4,p3*q3,p2*q2,p1*q1,p0*q0]
		pmulhw xmm2, xmm1	;xmm2 = en cada word la parte alta de [p7*q7,p6*q6,p5*q5,p4*q4,p3*q3,p2*q2,p1*q1,p0*q0]

		movdqu xmm1, xmm0	;Para la parte baja

		PUNPCKLWD xmm0, xmm2	;xmm0 = en cada dword el resultado de [p3*q3, p2*q2, p1*q1, p0*q0]
		PUNPCKHWD xmm1, xmm2	;xmm1 = en cada dword el resultado de [p7*q7, p6*q6 ,p5*q5 ,p4*q4]
		
		PHADDD xmm0, xmm1	;xmm0 = [p3*q3 + p2*q2, p1*q1 + p0*q0, p7*q7 + p6*q6, p5*q5 + p4*q4]
		PHADDD xmm0, xmm0	;xmm0 = [p3*q3 + p2*q2 + p1*q1 + p0*q0, p7*q7 + p6*q6 + p5*q5 + p4*q4, p3*q3 + p2*q2 + p1*q1 + p0*q0, p7*q7 + p6*q6 + p5*q5 + p4*q4]
		PHADDD xmm0, xmm0	;xmm0 = [p3*q3 + p2*q2 + p1*q1 + p0*q0 + p7*q7 + p6*q6 + p5*q5 + p4*q4, ...]
		
		movd r8d, xmm0	 ;r8d = [p3*q3 + p2*q2 + p1*q1 + p0*q0 + p7*q7 + p6*q6 + p5*q5 + p4*q4]

		add eax, r8d	;eax = [p3*q3 + p2*q2 + p1*q1 + p0*q0 + p7*q7 + p6*q6 + p5*q5 + p4*q4]

		add rdi, 16		;Aumentamos rdi en el numero de bytes correspondiente a la cantidad de digitos de 16 bits de p operados 
		add rsi, 16		;Aumentamos rsi en el numero de bytes correspondiente a la cantidad de digitos de 16 bits de q operados 
		
		add ecx, 8	 ;Aumentamos el contador en la cantidad de numeros con los que acabamos de operar

		cmp ecx, edx	;Hacemos la comparacion entre el contador y el lenght
	jne .ciclo	 ;Si no son iguales vuelve al ciclo
	;Una vez que el contador sea igual a lenght sale del ciclo y continua con el prologo
	

	pop rbp
	ret
