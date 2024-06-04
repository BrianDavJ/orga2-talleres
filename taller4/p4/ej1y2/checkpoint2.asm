section .rodata				

								;[masc + 0][masc + 1][masc + 2][masc + 3][masc + 4][masc + 5][masc + 6][masc + 7]...
masc1: times 8 db 0x01, 0x00	;   0x01      0x00      0x01      0x00     0x01       0x00      0x01      0x00   ... 0x01 0x00 0x01 0x00 0x01 0x00 0x01 0x00
masc2: times 8 db 0x02, 0x00	;   0x02      0x00      0x02      0x00     0x02       0x00      0x02      0x00   ... 0x02 0x00 0x02 0x00 0x02 0x00 0x02 0x00
masc3: times 8 db 0x03, 0x00	;   0x03      0x00      0x03      0x00     0x03       0x00      0x03      0x00   ... 0x03 0x00 0x03 0x00 0x03 0x00 0x03 0x00
masc4: times 8 db 0x04, 0x00	;   0x04      0x00      0x04      0x00     0x04       0x00      0x04      0x00   ... 0x04 0x00 0x04 0x00 0x04 0x00 0x04 0x00
masc5: times 8 db 0x05, 0x00	;   0x05      0x00      0x05      0x00     0x05       0x00      0x05      0x00   ... 0x05 0x00 0x05 0x00 0x05 0x00 0x05 0x00
masc6: times 8 db 0x06, 0x00	;...
masc7: times 8 db 0x07, 0x00	;...
masc8: times 8 db 0x08, 0x00
masc9: times 8 db 0x09, 0x00
masc10: times 8 db 0x0a, 0x00
masc11: times 8 db 0x0b, 0x00
masc12: times 8 db 0x0c, 0x00
masc13: times 8 db 0x0d, 0x00
extractorDeNumeros: times 16 db 0x0f

section .text

global four_of_a_kind_asm

; uint32_t four_of_a_kind_asm(card_t *hands, uint32_t n);
;rdi: hands; rsi: n
four_of_a_kind_asm:
	push rbp
	mov rsp, rbp

    xor rcx, rcx    ;Limpio el registro que voy a usar para contar las iteraciones
    mov rcx, rsi    ;Cargo el registro que voy a usar para contar las iteraciones
    shr rcx, 2      ;Divido la cantidad de iteraciones por 4 ya que la cantidad de iteraciones 
                    ;depende de la cantidad de manos y esta funcion analiza 4 manos por iteracion

    .ciclo:
        ;Limpio los registros
        pxor xmm0, xmm0
        pxor xmm1, xmm1
        pxor xmm15, xmm15

                            ;Así está en memoria
                            ;Dirección	   0x00     |      0x01     |       0x02    |        0x03   |        0x04
                            ;               0               1               2               3               4
                            ;[rdi] = [(value, suit)0, (value, suit)1, (value, suit)2, (value, suit)3, (value, suit)4, ...
        movdqu xmm0, [rdi]	; xmm0 = [(suit, value)15, (suit, value)14, (suit, value)13, (suit, value)12, (suit, value)11, ... ]

        movdqu xmm1, [extractorDeNumeros]
        movdqu xmm2, [masc8]                    
                            ;       [127:120] [119:112] ...
        pand xmm1, xmm0     ;xmm1 = [numero15, numero14, numero13, numero12, numero11, numero10, numero9, numero8,...]						


        pcmpeqd xmm1, xmm2


        psrld xmm1, 31

        sub rcx, 4      ;Disminuyo el contador de manos por 4
        cmp rcx, 0      ;Comparo la cantidad de manos restantes con 4
    jne .ciclo


    
    pop rbp
    ret