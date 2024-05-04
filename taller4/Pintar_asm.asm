section .rodata
blanco: times 16 db 0xff
negro: times 16 db 0xff
global Pintar_asm
	  

section .text
	;rdi: *SRC,		 rsi: *DST, 	rdx: WIDTH, 	rcx: HEIGHT,	 r8: src_row_size,	 r9: dst_row_size
Pintar_asm:
	push rbp
	mov rbp, rsp

	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9


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



;Hasta aca ya esta pintada toda la imagen de blanco
;-----------------------------------------------------------------------------------------------------------
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	
	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9

	;rdi: *SRC,		 rsi: *DST, 	rdx: WIDTH, 	rcx: HEIGHT,	 r8: src_row_size,	 r9: dst_row_size

	por xmm0, xmm0
	por xmm1, xmm1

	xor r9, r9		;Limpio r9 porque lo vamos a usar como contador de iteraciones
	xor r10, r10	;Para guardar puntero a la FUENTE
	xor r11, r11	;Para guardar puntero a DESTINO
	xor rax, rax	;Para calcular la cantidad de iteraciones

	mov rax, rdx	;Guardo en rax el ancho en pixeles de la imagen
	shl rax, 1		;Multiplico la cantidad de pixeles por dos (porque queremos pintar dos lineas de pixeles)
	;En rax esta guardada la cantidad de pixeles que tengo que pintar de negro en el techo

	mov r10, rdi	;r10 = Puntero a la FUENTE
	mov r11, rsi	;r11 = Puntero a la DESTINO
	
	;NO VOLATILES RBX, RBP, R12, R13, R14 y R15
	
	.cicloTecho:
		movdqu xmm0, [r10]		;Agarro los primeros 4 pixeles a pintar, 16 bytes
		
		movdqu xmm1, [negro]	;Guardo la mascara en un registro xmm

		psubusb xmm0, xmm1		;Pinto los 4 pixeles agarrados

		movdqu [r11], xmm0		;Guardo los pixeles pintados en DESTINO

		add r10, 16		;Aumento el puntero a FUENTE en 16 bytes == cantidad de bytes operados
		add r11, 16		;Aumento el puntero a DESTINO en 16 bytes == cantidad de bytes operados

		add r9, 1		;Aumento en 4 la cantidad de pixeles pintados DFISANDOFAOSNGFMKAEIWUNCDJIEFBHASFSDFNDJNVDFVKSDVJKSDFVKSDFKNVSDFVNJDSFVKSJDFVNDFNVNKSKDJFJVSFDNKVJKDSFNVFDVNJDSFNKVKDFKVNSFN
		cmp r9, rax		;Comparo la cantidad de iteraciones con r8 == src_row_size
	jne .cicloTecho

;Hasta aca ya esta pintada toda la imagen de blanco y el techo de negro
;-----------------------------------------------------------------------------------------------------------
	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi
	
	push rdi
	push rsi
	push rdx
	push rcx
	push r8
	push r9

	;rdi: *SRC,		 rsi: *DST, 	rdx: WIDTH, 	rcx: HEIGHT,	 r8: src_row_size,	 r9: dst_row_size
	
	por xmm0, xmm0
	por xmm1, xmm1

	xor r9, r9		;Limpio r9 porque lo vamos a usar como contador de iteraciones
	xor r10, r10	;Para guardar puntero a la FUENTE
	xor r11, r11	;Para guardar puntero a la DESTINO
	xor rax, rax	;Para guardar la direccion del ultimo pixel de la imagen

	mov r9, rdx		;Guardo en r9 el ancho en pixeles de la imagen
	shl r9, 1		;Multiplico la cantidad de pixeles por dos (porque queremos pintar dos lineas de pixeles)

	mov rax, rdx	;Cargamos WIDTH en rax para multiplicarlo con HEIGHT a traves de mul
	mul rcx			;Cantidad de pixeles de la imagen queda en rax
	shl rax, 2		;Cantidad de bytes que ocupa la imagen queda en rax

	mov r10, rdi	;FUENTE
	add r10, rax	;Direccion del ultimo byte de la imagen FUENTE
	sub r10, 16		;Direccion donde empiezan los ultimos 4 pixeles de la imagen FUENTE

	mov r11, rsi
	add r11, rax	;Direccion del ultimo byte de la imagen DESTINO
	sub r11, 16		;Direccion donde empiezan los ultimos 4 pixeles de la imagen DESTINO

	;NO VOLATILES RBX, RBP, R12, R13, R14 y R15
	
	.cicloPiso:
		movdqu xmm0, [r10]		;Agarro los 4 pixeles que voy a pintar
		
		movdqu xmm1, [negro]	;Pongo la mascara en un registro xmm

		psubusb xmm0, xmm1		;Pinto los pixeles agarrados

		movdqu [r11], xmm0		;Guardo los pixeles pintados en la direccion DESTINO

		sub r10, 16		;Disminuyo el puntero a FUENTE en 16 bytes == cantidad de bytes operados
		sub r11, 16		;Disminuyo el puntero a DESTINO en 16 bytes == cantidad de bytes operados

		sub r9, 1		;Resto 1 a la cantidad de iteraciones AFKJAJFFAOFAMFAMFDMFVFODSDVMKOFSDMFSDMIOFVMIOFSDIOMFDSMIOOIMFIOMIDOMFVF
		cmp r9, 0		;Comparo la cantidad de iteraciones con r8 == src_row_size
	jne .cicloPiso


	pop r9
	pop r8
	pop rcx
	pop rdx
	pop rsi
	pop rdi

	pop rbp
	ret