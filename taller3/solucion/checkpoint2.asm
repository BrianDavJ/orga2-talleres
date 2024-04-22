extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global product_9_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4:
	;prologo
	push rbp
	mov rbp, rsp 

	sub rdi,rsi
	add rdi,rdx
	sub rdi,rcx
	mov eax,edi

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	pop rbp
	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp
	; hay que preservar el resto de los registros
	; porque la funcion no me promete que me los preserve

	push rdx
	push rcx


	CALL restar_c
	mov rdi,rax
	mov rsi,[rbp-0x8]
	CALL sumar_c
	mov rdi,rax
	mov rsi,[rbp-0x10]
	CALL restar_c


	;epilogo
	mov rsp, rbp ; restauramos la pila
	pop rbp
	ret



; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[?], x2[?], x3[?], x4[?]
alternate_sum_4_simplified:
	sub rdi,rsi
	add rdi,rdx
	sub rdi,rcx
	mov eax,edi

	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+10], x8[rbp+18]
alternate_sum_8:
	
	;prologo
	push rbp
	mov rbp,rsp
	

	; COMPLETAR
	sub rdi,rsi
	add rdi,rdx
	sub rdi,rcx
	add rdi,r8
	sub rdi,r9
	add rdi,[rbp+0x10]
	sub rdi, [rbp+0x18]
	mov eax,edi

	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[esi], f1[xmm0]
product_2_f:
	push rbp
	mov rbp,rsp

	cvtsi2ss xmm1,esi ;ConVerT Single precision Integer  precision 2(to) ScalarSingle
	mulss xmm0,xmm1
	cvttss2si esi,xmm0   ;(C)on(V)er(T) (T)runcate (S)calar(S)ingle precision to(2) (S)ingle precision Integer ;  0.55-> 0.5 
	mov dword[rdi], esi
	
	pop rbp
	ret

	

;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp+0x10], f6[xmm5], x7[rbp+0x18], f7[xmm6], x8[rbp+0x20], f8[xmm7],
;	, x9[rbp+0x28], f9[rbp+0x30]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; COMPLETAR
	cvtss2sd xmm0,xmm0
	cvtss2sd xmm1,xmm1
	cvtss2sd xmm2,xmm2
	cvtss2sd xmm3,xmm3
	cvtss2sd xmm4,xmm4
	cvtss2sd xmm5,xmm5
	cvtss2sd xmm6,xmm6
	cvtss2sd xmm7,xmm7
	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0,xmm1
	mulsd xmm0,xmm2
	mulsd xmm0,xmm3
	mulsd xmm0,xmm4
	mulsd xmm0,xmm5
	mulsd xmm0,xmm6
	mulsd xmm0,xmm7
	cvtss2sd xmm1,[rbp+0x30]
	mulsd xmm0,xmm1


	
	; COMPLETAR
	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; hay que limpiar la parte alta y despues convertimos
	; el convert es con signo
	mov esi, esi ; asi se limpia lo dice el manual
	cvtsi2sd xmm1,rsi
	cvtsi2sd xmm2,rdx
	cvtsi2sd xmm3,rcx
	cvtsi2sd xmm4,r8
	cvtsi2sd xmm5,r9
	cvtsi2sd xmm6,[rbp+0x10]
	cvtsi2sd xmm7,[rbp+0x18]
	mulsd xmm0,xmm1
	mulsd xmm0,xmm2
	mulsd xmm0,xmm3
	mulsd xmm0,xmm4
	mulsd xmm0,xmm5
	mulsd xmm0,xmm6
	mulsd xmm0,xmm7
	cvtsi2sd xmm1,[rbp+0x20]
	mulsd xmm0,xmm1
	cvtsi2sd xmm1,[rbp+0x28]
	mulsd xmm0,xmm1
	movsd [rdi],xmm0
	
	; COMPLETAR

	; epilogo
	pop rbp
	ret


