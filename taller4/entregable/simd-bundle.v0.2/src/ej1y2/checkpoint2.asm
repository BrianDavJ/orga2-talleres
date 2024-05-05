section .text
							;   0    1     2    3	  4    5     6    7  
masc_uno:  times 8 db 0x0, 0x1  ;0000 0001, 0000 0001, 0000 0001, 0000 0001   
		   ;100100000000
masc_dos :  times 8 db 0x0, 0x02 ;00000000_00100000_00100000_00000000_00100000_00000000_00100000_00000000_00100000_00000000_00100000_00000000_00100000_00000000_00100000_00000000  
masc_tres: times 8 db 0x0,  0x03 
masc_cuatro : times 8 db 0x0, 0x04
masc_cinco : times 8 db 0x0,  0x05
masc_seis : times 8 db 0x0, 0x06
masc_siete : times 8 db 0x0, 0x07
masc_ocho : times 8 db 0x0, 0x08
masc_nueve : times 8 db 0x0,0x09
masc_diez : times 8 db 0x0,  0x0A
masc_once : times 8 db 0x0,   0x0B
masc_doce : times 8 db 0x0,   0x0C
masc_trece : times 8 db 0x0,   0x0D
masc_iguales: times 2 dq 0x01,0x01


masc_limpiamos : dw 0x00, 0x00, 0x00, 0xff


global four_of_a_kind_asm

; uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);

four_of_a_kind_asm:
	push rbp
	mov rbp, rsp
	
	xor rdx,rdx
	xor r8, r8
	xor rcx, rcx
	xor rax, rax

	pxor xmm1, xmm1
	pxor xmm2, xmm2
	pxor xmm9,xmm9

	.ciclo:
	cmp r8,  rsi
	je .fin

	
	pxor xmm1, xmm1
	pxor xmm2, xmm2

	; (127-0) = [ value -suit  -6 2 -5 0 - 9 1]
	movdqu xmm0, [rdi] ; en xmm0 tenemos las primeras 16 cartas



	punpcklbw xmm1,xmm0 
	punpckhbw xmm2,xmm0

	; 00011001 (1 - 9)
	; 10010000
	PSLLW xmm1, 4	; nos corremos 12 bits
	PSLLW xmm2, 4

	PSRLW xmm1, 4
	PSRLW xmm2, 4
	; (127 - 0)   [1 3 - 9 0]	

	; registros de mascaras de palos/tipos
	movdqu xmm3,[masc_uno]
	movdqu xmm4,[masc_dos]
	movdqu xmm5,[masc_tres]
	movdqu xmm6,[masc_cuatro]
	movdqu xmm7, [masc_cinco]
	movdqu xmm8, [masc_seis]
	movdqu xmm9, [masc_siete]
	movdqu xmm10, [masc_ocho]
	movdqu xmm11, [masc_nueve]
	movdqu xmm12, [masc_diez]
	movdqu xmm13, [masc_once]
	movdqu xmm14, [masc_doce]
	movdqu xmm15, [masc_trece]
	
	

	PCMPEQQ xmm3, xmm1
	PCMPEQQ xmm4, xmm1
	PCMPEQQ xmm5, xmm1
	PCMPEQQ xmm6, xmm1
	PCMPEQQ xmm7, xmm1
	PCMPEQQ xmm8, xmm1
	PCMPEQQ xmm9, xmm1
	PCMPEQQ xmm10, xmm1
	PCMPEQQ xmm11, xmm1
	PCMPEQQ xmm12, xmm1
	PCMPEQQ xmm13, xmm1
	PCMPEQQ xmm14, xmm1
	PCMPEQQ xmm15, xmm1

	pand xmm3, [masc_iguales]
	pand xmm4, [masc_iguales]
	pand xmm5, [masc_iguales]
	pand xmm6, [masc_iguales]
	pand xmm7, [masc_iguales]
	pand xmm8, [masc_iguales]
	pand xmm9, [masc_iguales]
	pand xmm10,[masc_iguales]
	pand xmm11,[masc_iguales]
	pand xmm12,[masc_iguales]
	pand xmm13,[masc_iguales]
	pand xmm14,[masc_iguales]
	pand xmm15,[masc_iguales]


					


	PHADDD xmm4, xmm3
	PHADDD xmm4, xmm4
	PHADDD xmm4, xmm4

	pand xmm4, [masc_limpiamos]		


	PHADDD xmm5, xmm4
	PHADDD xmm5, xmm5
	PHADDD xmm5, xmm5

	pand xmm5, [masc_limpiamos]		
	; ejemplos
	; xmm6 = [ 0 0 0 1| 0 0 0 0 ] 
	; xmm5 = [ 0 0 0 0| 0 0 0 1 ]

	
	; xmm6 = [ 0 0 | 0 1| 0 0 | 0 0 ] 
	; xmm5 = [ 0 0 | 0 0| 0 0 |  0 1 ] 

	; res = xmm6 =  [01 | 00 | 00 | 01]   [00 | 01| 01| 00 ]
	PHADDD xmm6, xmm5
	; res = xmm6 = [01| 01 | 01 | 01]
	PHADDD xmm6, xmm6
	; res = xmm6 = [2 | 2 | 2| 2]
	PHADDD xmm6, xmm6

	pand xmm6, [masc_limpiamos]

	;xmm 6 = [0 0 2 0]
	;xmm 7[0 1 0 1]
;
	;1 1 0 2 = xmmm6 +xmm7 
	;2 2 2 2 xmm7 + xmm7
	;4 4 4 4 xmm7 + xmm7


	PHADDD xmm7, xmm6
	PHADDD xmm7, xmm7
	PHADDD xmm7, xmm7

	pand xmm7, [masc_limpiamos]

	PHADDD xmm8, xmm7
	PHADDD xmm8, xmm8
	PHADDD xmm8, xmm8

	pand xmm8, [masc_limpiamos]

	PHADDD xmm9, xmm8
	PHADDD xmm9, xmm9
	PHADDD xmm9, xmm9

	pand xmm9, [masc_limpiamos]


	PHADDD xmm10, xmm9
	PHADDD xmm10, xmm10
	PHADDD xmm10, xmm10

	pand xmm10, [masc_limpiamos]


	PHADDD xmm11, xmm10
	PHADDD xmm11, xmm11
	PHADDD xmm11, xmm11

	pand xmm11, [masc_limpiamos]



	PHADDD xmm12, xmm11
	PHADDD xmm12, xmm12
	PHADDD xmm12, xmm12

	pand xmm12, [masc_limpiamos]


	PHADDD xmm13, xmm12
	PHADDD xmm13, xmm13
	PHADDD xmm13, xmm13

	pand xmm13, [masc_limpiamos]


	PHADDD xmm14, xmm13
	PHADDD xmm14, xmm14
	PHADDD xmm14, xmm14

	pand xmm14, [masc_limpiamos]



	PHADDD xmm15, xmm14
	PHADDD xmm15, xmm15
	PHADDD xmm15, xmm15

	pand xmm15, [masc_limpiamos]


	movd edx, xmm15 ; aca esta el res final


	movdqu xmm3,[masc_uno]
	movdqu xmm4,[masc_dos]
	movdqu xmm5,[masc_tres]
	movdqu xmm6,[masc_cuatro]
	movdqu xmm7, [masc_cinco]
	movdqu xmm8, [masc_seis]
	movdqu xmm9, [masc_siete]
	movdqu xmm10, [masc_ocho]
	movdqu xmm11, [masc_nueve]
	movdqu xmm12, [masc_diez]
	movdqu xmm13, [masc_once]
	movdqu xmm14, [masc_doce]
	movdqu xmm15, [masc_trece]

	PCMPEQQ xmm3, xmm2
	PCMPEQQ xmm4, xmm2
	PCMPEQQ xmm5, xmm2
	PCMPEQQ xmm6, xmm2
	PCMPEQQ xmm7, xmm2
	PCMPEQQ xmm8, xmm2
	PCMPEQQ xmm9, xmm2
	PCMPEQQ xmm10, xmm2
	PCMPEQQ xmm11, xmm2
	PCMPEQQ xmm12, xmm2
	PCMPEQQ xmm13, xmm2
	PCMPEQQ xmm14, xmm2
	PCMPEQQ xmm15, xmm2
					
	pand xmm3, [masc_iguales]
	pand xmm4, [masc_iguales]
	pand xmm5, [masc_iguales]
	pand xmm6, [masc_iguales]
	pand xmm7, [masc_iguales]
	pand xmm8, [masc_iguales]
	pand xmm9, [masc_iguales]
	pand xmm10,[masc_iguales]
	pand xmm11,[masc_iguales]
	pand xmm12,[masc_iguales]
	pand xmm13,[masc_iguales]
	pand xmm14,[masc_iguales]
	pand xmm15,[masc_iguales]

	PHADDD xmm4, xmm3
	PHADDD xmm4, xmm4
	PHADDD xmm4, xmm4

	pand xmm4, [masc_limpiamos]		


	PHADDD xmm5, xmm4
	PHADDD xmm5, xmm5
	PHADDD xmm5, xmm5

	pand xmm5, [masc_limpiamos]		
	; ejemplos
	; xmm6 = [ 0 0 0 1| 0 0 0 0 ] 
	; xmm5 = [ 0 0 0 0| 0 0 0 1 ]

	
	; xmm6 = [ 0 0 | 0 1| 0 0 | 0 0 ] 
	; xmm5 = [ 0 0 | 0 0| 0 0 |  0 1 ] 

	; res = xmm6 =  [01 | 00 | 00 | 01]   [00 | 01| 01| 00 ]
	PHADDD xmm6, xmm5
	; res = xmm6 = [01| 01 | 01 | 01]
	PHADDD xmm6, xmm6
	; res = xmm6 = [2 | 2 | 2| 2]
	PHADDD xmm6, xmm6

	pand xmm6, [masc_limpiamos]

	;xmm 6 = [0 0 2 0]
	;xmm 7[0 1 0 1]
;
	;1 1 0 2 = xmmm6 +xmm7 
	;2 2 2 2 xmm7 + xmm7
	;4 4 4 4 xmm7 + xmm7


	PHADDD xmm7, xmm6
	PHADDD xmm7, xmm7
	PHADDD xmm7, xmm7

	pand xmm7, [masc_limpiamos]

	PHADDD xmm8, xmm7
	PHADDD xmm8, xmm8
	PHADDD xmm8, xmm8

	pand xmm8, [masc_limpiamos]

	PHADDD xmm9, xmm8
	PHADDD xmm9, xmm9
	PHADDD xmm9, xmm9

	pand xmm9, [masc_limpiamos]


	PHADDD xmm10, xmm9
	PHADDD xmm10, xmm10
	PHADDD xmm10, xmm10

	pand xmm10, [masc_limpiamos]


	PHADDD xmm11, xmm10
	PHADDD xmm11, xmm11
	PHADDD xmm11, xmm11

	pand xmm11, [masc_limpiamos]



	PHADDD xmm12, xmm11
	PHADDD xmm12, xmm12
	PHADDD xmm12, xmm12

	pand xmm12, [masc_limpiamos]


	PHADDD xmm13, xmm12
	PHADDD xmm13, xmm13
	PHADDD xmm13, xmm13

	pand xmm13, [masc_limpiamos]


	PHADDD xmm14, xmm13
	PHADDD xmm14, xmm14
	PHADDD xmm14, xmm14

	pand xmm14, [masc_limpiamos]



	PHADDD xmm15, xmm14
	PHADDD xmm15, xmm15
	PHADDD xmm15, xmm15

	pand xmm15, [masc_limpiamos]


	movd ecx, xmm15

	add rax, rdx
	add rax, rcx

	add rdi, 16
	sub rsi, 16

	jmp .ciclo

	.fin:


	pop rbp
	ret