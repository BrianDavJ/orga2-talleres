section .rodata
blanco: times 16 db 0xff
lateral_izq: db 0x0,0x0,0x00,0x00,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff
lateral_der: db 0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0x00,0x00,0x00,0x00
global Pintar_asm

section .text
;void Pintar_asm(unsigned char *src,
;              unsigned char *dst,
;              int width,
;              int height,
;              int src_row_size,
;              int dst_row_size);

;NO VOLATILES RBX, RBP, R12, R13, R14 y R15			  


;rdi: *src, rsi: *dst, rdx: width, rcx: height, r8: src_row_size, r9: dst_row_size
Pintar_asm:
	push rbp
	mov rbp, rsp


	xor r9, r9		;Limpio r9 porque ahi vamos a guardar la cantidad de iteraciones
	xor r10, r10	;Para guardar puntero a la fuente
	xor r11, r11	;Para guardar puntero a destino
	xor rax, rax	;Limpio rax para usar la funcion mul

	mov rax, rdx	;Cargamos WIDTH en rax para multiplicarlo con height a traves de mul
	mul rcx			;Cantidad de pixeles de la imagen queda en rax
	shr rax, 2		;Cantidad de iteraciones, porque la funcion trabaja con 4 pixeles a la vez
	mov r9, rax		;En r9 esta la cantidad de iteraciones para recorrer toda la imagen

	mov r10, rdi	;R10 = Puntero a la FUENTE
	mov r11, rsi	;R11 = Puntero a la DESTINO
	
	.cicloBlanco:				      ;127	  						    0
		movdqu xmm0, [r10]		;xmm0 = [a r g b a r g b a r g b a r g b]
		
		movdqu xmm1, [blanco]	;Guardo la mascara en xmm1
		
		paddusb xmm0, xmm1		;xmm0 = [ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff]

		movdqu [r11], xmm0		;Escribo el resultado en la correspondiente posicion de memoria

		add r10, 16		;Aumento el puntero a FUENTE en 16 bytes == cantidad de bytes operados
		add r11, 16		;Aumento el puntero a DESTINO en 16 bytes == cantidad de bytes operados

		sub r9, 1		;Resto 1 a la cantidad de iteraciones
		cmp r9, 0		;Comparo la cantidad de iteraciones faltantes con 0
	jne .cicloBlanco

	;--------------- techo -----------------------------
	mov r10, rsi		;recupero puntero al inicio de dst
	xor r9,r9			;iteraciones actuales
	shl r8,1 			;cantidad de bytes hasta prox 2 filas
						;
	.ciclo_techo:
		
		pxor xmm0,xmm0
		movdqu [r10], xmm0

		add r10, 16
		add r9, 16
		cmp r9,r8
		jne .ciclo_techo
	;---------------- laterales ------------------------
						;r10 esta parado en (3,0) la 3er fila columna 0
						;r9 tiene 2 iteraciones ya hechas del techo
	
	shr r8,1			;cantidad de bytes hasta prox fila
	sub r8,16
	xor r9,r9
	add r9,2			;Cuento las it del techo
	sub rcx,2
						;
	.ciclo_laterales:

		.izq:

		movdqu xmm0, [lateral_izq]
		movdqu [r10], xmm0
	
		add r10, r8
		
		.der:
		movdqu xmm0, [lateral_der]
		movdqu [r10], xmm0

		add r10, 16
		inc r9
		cmp r9,rcx
		jne .ciclo_laterales


	;--------------		piso	------------------------
	xor r9,r9			;nuevo contador para ver cuando llego al borde de la fila
	shl r8,1			;r8 en bytes
	add r8,32
	.ciclo_piso:
		pxor xmm0,xmm0
		movdqu [r10], xmm0

		add r10, 16
		add r9, 16		;cada iter tomo 16 bytes
		cmp r8,r9
		jg .ciclo_piso

	

	pop rbp
	ret