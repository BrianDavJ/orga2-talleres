
section .text

global dot_product_asm

; uint32_t dot_product_asm(uint16_t *p, uint16_t *q, uint32_t length);
; implementacion simd de producto punto
; p -> rdi, q->rsi, length -> rdx
dot_product_asm:
	push rbp
	mov rbp,rsp
	xor rax, rax
	xor rcx,rcx
	
	.ciclo:
		
		movdqu xmm0, [rdi] ; tiene p y parte baja de la multi
		movdqu xmm1, [rsi] ; tiene q
		movdqu xmm2, xmm0 ; parte alta de la multi

		pmullw xmm0,xmm1 ;parte baja
		pmulhw xmm2,xmm1 ;parte alta
		movdqu xmm1,xmm0 ;copia de la parte baja para desempaquetar

		punpcklwd xmm0,xmm2 ; armo la primera parte de los resultados (la mitad de los nums se multiplicaron) y lo guardo en xmm0
		punpckhwd xmm1,xmm2 ; armo la sagunda parte de los resultados y los guardo en xmm1
		phaddd xmm0, xmm1
		phaddd xmm0, xmm0
		phaddd xmm0, xmm0

		movd	r8d, xmm0
		add	eax, r8d
		
		add rdi,16
		add rsi,16

		add rcx, 8
		cmp rcx,rdx
		jne .ciclo

	
	.fin:
	pop rbp
	ret
