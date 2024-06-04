;section .rodata
shuffle_img: db 0x01, 0x02, 0x00, 0x03, 0x05, 0x06, 0x04, 0x07, 0x09, 0x0A, 0x08, 0x0B, 0x0D, 0x0E, 0x0C, 0x0F
tres: times 2 dq 3.0

;Mascaras usadas para asegurarnos de como estan los pixeles en memoria y en registros
blue: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
green: db 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00
red: db 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00
transparency: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
;disposicion en memoria: blue, green, red, transparencia
;disposicion en registros: transparencia, red, green, blue

menorA32: db 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
mascara128: db 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00

menorA96: db 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00
mascara32: db 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00
mascara255: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00

menorA160: db 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00
mascara96: db 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00

menorA224: db 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00
mascara160: db 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00, 0xA0, 0x00, 0x00, 0x00

sino: dw 0x0100, 0x0000, 0x0100, 0x0000, 0x0100, 0x0000, 0x0100, 0x0000
mascara224: db 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00, 0xE0, 0x00, 0x00, 0x00

transparenciaFinal: db 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF

global temperature_asm

section .data



section .text

;rdi: src; rsi: dst; rdx: width; rxc: height; r8: rowSize; r9: colSize
temperature_asm:
    push rbp
    mov rbp, rsp

    ;Resguardo los registros no volátiles
    push rbx
    push rbp
    push r12
    push r13
    push r14
    push r15
    
    push rdx        ;Hacemos esto porque mul modifica rdx y lo queremos resguardar

    mov rax,rdx
    mul rcx         ;rax = Cantidad de pixeles

    pop rdx

    mov r10, rax    ;r10 = rax
    shr r10, 2      ;r10 = cantidad de iteraciones totales (tomamos de a 4 pixeles)

    .ciclo:
                                    ;        F E D C | B A 9 8 | 7 6 5 4 | 3 2 1 0
                                    ;        pixel 3 | pixel 2 | pixel 1 | pixel 0
        movdqu xmm0, [rdi]          ;xmm0 = [a r g b | a r g b | a r g b | a r g b]
        movdqu xmm1, xmm0           ;xmm1 = xmm0

        pshufb xmm1, [shuffle_img]  ;xmm1 = [a b r g | a b r g | a b r g | a b r g]
        movdqu xmm2, xmm1           ;xmm2 = xmm1

        pshufb xmm2, [shuffle_img]  ;xmm2 = [a g b r | a g b r | a g b r | a g b r]

;--------------------------------------------------------------------------------------------------------------
                                    ;       [               pixel 0               ]
        pmovzxbd xmm3, xmm0         ;xmm3 = [0 0 0 a | 0 0 0 r | 0 0 0 g | 0 0 0 b]
        psrldq xmm0, 4              ;xmm0 = [0 0 0 0 | pixel 3 | pixel 2 | pixel 1]

                                    ;       [               pixel 1               ]
        pmovzxbd xmm4, xmm0         ;xmm4 = [0 0 0 a | 0 0 0 r | 0 0 0 g | 0 0 0 b]
        psrldq xmm0, 4              ;xmm0 = [0 0 0 0 | 0 0 0 0 | pixel 3 | pixel 2]
        
                                    ;       [               pixel 2               ]
        PMOVZXBd xmm5, xmm0         ;xmm5 = [0 0 0 a | 0 0 0 r | 0 0 0 g | 0 0 0 b]
        psrldq xmm0, 4              ;xmm0 = [0 0 0 0 | 0 0 0 0 | 0 0 0 0 | pixel 3]

                                    ;       [               pixel 3               ]
        pmovzxbd xmm6, xmm0         ;xmm5 = [0 0 0 a | 0 0 0 r | 0 0 0 g | 0 0 0 b]


;-------Hasta acá los pixeles de originales ahora hago lo mismo pero para los que tienen un shuffle------------
                                    ;       [               pixel 0               ]
        pmovzxbd xmm7, xmm1         ;xmm7 = [0 0 0 a | 0 0 0 b | 0 0 0 r | 0 0 0 g]
        psrldq xmm1, 4              ;xmm1 = [0 0 0 0 | a b r g | a b r g | a b r g]

                                    ;       [               pixel 1               ]
        PMOVZXBd xmm8, xmm1         ;xmm8 = [0 0 0 a | 0 0 0 b | 0 0 0 r | 0 0 0 g]
        psrldq xmm1, 4              ;xmm1 = [0 0 0 0 | 0 0 0 0 | a b r g | a b r g]
        
                                    ;       [               pixel 2               ]
        PMOVZXBd xmm9, xmm1         ;xmm9 = [0 0 0 a | 0 0 0 b | 0 0 0 r | 0 0 0 g]
        psrldq xmm1, 4              ;xmm1 = [0 0 0 0 | 0 0 0 0 | 0 0 0 0 | a b r g]

                                    ;       [               pixel 3               ]
        pmovzxbd xmm10, xmm1        ;xmm10 = [0 0 0 a | 0 0 0 b | 0 0 0 r | 0 0 0 g]


;-------Hago la primer suma entre permutaciones----------------------------------------------------------------
        PADDd xmm7, xmm3            ;xmm7 = [0 0 0 2a| 0 0 0 b+r| 0 0 0 g+r | 0 0 0 g+b] pixel 0
        PADDd xmm8, xmm4            ;xmm8 = [0 0 0 2a| 0 0 0 b+r| 0 0 0 g+r | 0 0 0 g+b] pixel 1
        paddd xmm9, xmm5            ;xmm9 = [0 0 0 2a| 0 0 0 b+r| 0 0 0 g+r | 0 0 0 g+b] pixel 2
        paddd xmm10, xmm6           ;xmm10 = [0 0 0 2a| 0 0 0 b+r| 0 0 0 g+r | 0 0 0 g+b] pixel 3


;-------Ahora hago lo mismo pero para los que tienen dos shuffle-----------------------------------------------
                                    ;       [               pixel 0               ]
        pmovzxbd xmm3, xmm2         ;xmm3 = [0 0 0 a | 0 0 0 g | 0 0 0 b | a 0 0 r]
        psrldq xmm2, 4              ;xmm2 = [0 0 0 0 | a g b r | a g b r | a g b r]

                                    ;       [               pixel 1               ]
        PMOVZXBd xmm4, xmm2         ;xmm4 = [0 0 0 a | 0 0 0 g | 0 0 0 b | a 0 0 r]
        psrldq xmm2, 4              ;xmm2 = [0 0 0 0 | 0 0 0 0 | a g b r | a g b r]

                                    ;       [               pixel 2               ]
        PMOVZXBd xmm5, xmm2         ;xmm5 = [0 0 0 a | 0 0 0 g | 0 0 0 b | a 0 0 r]
        psrldq xmm2, 4              ;xmm2 = [0 0 0 0 | 0 0 0 0 | 0 0 0 0 | a g b r]

                                    ;       [               pixel 3               ]
        pmovzxbd xmm6, xmm2         ;xmm6 = [0 0 0 a | 0 0 0 g | 0 0 0 b | a 0 0 r]


;-------Hago la segunda suma entre permutaciones---------------------------------------------------------------
        PADDd xmm3, xmm7            ;xmm3 = [3a | r+g+b | r+g+b | r+g+b]
        PADDd xmm4, xmm8            ;xmm4 = [3a | r+g+b | r+g+b | r+g+b]
        paddd xmm5, xmm9            ;xmm5 = [3a | r+g+b | r+g+b | r+g+b]
        paddd xmm6, xmm10           ;xmm6 = [3a | r+g+b | r+g+b | r+g+b]

        pxor xmm7,  xmm7
        pxor xmm8,  xmm8
        pxor xmm9,  xmm9
        pxor xmm10, xmm10

        CVTDQ2PD xmm0, xmm3         ; convierto D1 a double Precision float
        CVTDQ2PD xmm1, xmm4         ; convierto D2 a double Precision float
        CVTDQ2PD xmm2, xmm5         ; convierto D3 a double Precision float
        cvtdq2pd xmm7, xmm6         ; convierto D4 a double Precision float

        divpd xmm0, [tres]          ;xmm0 = [t0 en float]
        divpd xmm1, [tres]          ;xmm1 = [t1 en float]
        divpd xmm2, [tres]          ;xmm2 = [t2 en float]
        divpd xmm7, [tres]          ;xmm3 = [t3 en float]

        CVTTPD2DQ xmm4, xmm0        ;xmm4 = [t0 en int]
        CVTTPD2DQ xmm5, xmm1        ;xmm5 = [t1 en int]
        CVTTPD2DQ xmm6, xmm2        ;xmm6 = [t2 en int]
        CVTTPD2DQ xmm3, xmm7        ;xmm3 = [t3 en int]

        PACKUSDW xmm4, xmm5         ;xmm4 = [0 0 0 t1 0 0 0 t0]
        packusdw xmm6, xmm3         ;xmm6 = [0 0 0 t3 0 0 0 t2]

        packuswb xmm4, xmm6         ;xmm4 = [0 0 t3 t3 | 0 0 t2 t2 | 0 0 t1 t1 | 0 0 t0 t0]

        movdqu xmm0, xmm4           ;xmm0 = [0 0 t3 t3 | 0 0 t2 t2 | 0 0 t1 t1 | 0 0 t0 t0]

        psrlw xmm0, 8               ;xmm0 = [0 0 0 t3 | 0 0 0 t2 | 0 0 0 t1 | 0 0 0 t0]

        ;Limpiamos los registros que vamos a usar
        pxor xmm2, xmm2
        pxor xmm3, xmm3
        pxor xmm4, xmm4
        pxor xmm5, xmm5
        pxor xmm6, xmm6
        pxor xmm14, xmm14
        pxor xmm15, xmm15


;-------LO QUE GUARDAN LOS REGISTROS HASTA ACÁ--------------------------------------------------------------------------------
        ;rdi: src; rsi: dst; rdx: width; rxc: height; r8: rowSize; r9: colSize
        ;r10 = cantidad de iteraciones
        ;xmm0 = [0 0 0 t3 | 0 0 0 t2 | 0 0 0 t1 | 0 0 0 t0]


;------ CASOS DE COMPARACIÓN-------------------------------------------------------------------------------        
;-------CASO 1----------------------------------------------------------------------------------------------------------------------
        movdqu xmm2, [menorA32]         ;xmm2 = [0 0 | 0 32 | 0 0 | 0 32 | 0 0 | 0 32 | 0 0 | 0 32]
        movdqu xmm3, xmm0               ;xmm3 = [0 0 | 0 p3 | 0 0 | 0 p2 | 0 0 | 0 p1 | 0 0 | 0 p0]

        pcmpgtw xmm2, xmm3              ;xmm2 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]

        movdqu xmm4, xmm2               ;xmm4 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]
        psrlw xmm4, 8                   ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)]

        pand xmm2, xmm3                 ;xmm2 = los que son más chicos que 32 en sus respectivos lugares

        psllw xmm2, 2                   ;xmm2 = [0 | 1/0(t*4) | 0 | 1/0(t*4) | 0 | 1/0(t*4) | 0 | 1/0(t*4)]     FUNCIONA PORQUE ES EL CASO <32
        paddb xmm2, [mascara128]        ;xmm2 = [0 | 1/0(t*4)+128 | 0 | 1/0(t*4)+128 | 0 | 1/0(t*4)+128 | 0 | 1/0(t*4)+128] FUNCIONA PORQUE ES EL CASO <32
        
        pand xmm2, xmm4                 ;xmm2 = [0 0 0 (0/res) | 0 0 0 (0/res) | 0 0 0 (0/res) | 0 0 0 (0/res)]

        paddb xmm14, xmm4               ;xmm14 = va a pasar a ser la mascara anterior (esta va a ser la mascara del caso anterior que va a ir actualizandose a medida que pasemos por los distintos casos)
        paddb xmm15, xmm2               ;xmm15 = res final (hasta ahora solo caso 1)


;-------CASO 2----------------------------------------------------------------------------------------------------------------------
        movdqu xmm2, [menorA96]         ;xmm2 = [0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96]
        movdqu xmm3, xmm0               ;xmm3 = [0 0 | 0 p3 | 0 0 | 0 p2 | 0 0 | 0 p1 | 0 0 | 0 p0]

        pcmpgtw xmm2, xmm3              ;xmm2 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]

        movdqu xmm4, xmm2               ;xmm4 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]
        psrlw xmm4, 8                   ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan todos los menores a 96

        pxor xmm4, xmm14                ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan solo los x tal que 32 <= x < 96
                                        ;si entro en el caso anterior y en este caso no lo uso
                                        ;si entro en el caso actual pero no en el caso anterior si lo uso
                                        ;si entro en el caso anterior y no en el actual ABSURDO! anterior <32 antual <96 si <32 ---> tambien <96

        pand xmm2, xmm3                 ;xmm2 = los que son más chicos que 96 en sus respectivos lugares

        psubusb xmm2, [mascara32]       ;xmm2 = [0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32)]     FUNCIONA PORQUE ES EL CASO <32
        psllw xmm2, 2                   ;xmm2 = [0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4]
        psllw xmm2, 8                   ;xmm2 = [0 0 1/0(t-32) 0 | 0 0 1/0(t-32) 0 | 0 0 1/0(t-32) 0 | 0 0 1/0(t-32) 0]

        movdqu xmm5, xmm4
        psllw xmm5, 8                   ;xmm4 = [0 0 (1/0) 0 | 0 0 (1/0) 0 | 0 0 (1/0) 0 | 0 0 (1/0) 0] quedan solo los que son x tal que 32 <= x < 96
        pand xmm2, xmm5                 ;xmm2 = [0 0 (0/res) 0 | 0 0 (0/res) 0 | 0 0 (0/res) 0 | 0 0 (0/res) 0]

        movdqu xmm6, [mascara255]       ;xmm6 = [0 0 0 255 | 0 0 0 255 | 0 0 0 255 | 0 0 0 255]
        pand xmm6, xmm4                 ;xmm6 = [0 0 0 (1/0)255 | 0 0 0 (1/0)255 | 0 0 0 (1/0)255 | 0 0 0 (1/0)255]

        paddb xmm2, xmm6                ;xmm2 = [0 0 (0/res) (1/0)255 | 0 0 (0/res) (1/0)255 | 0 0 (0/res) (1/0)255 | 0 0 (0/res) (1/0)255]

        paddb xmm14, xmm4               ;Mascara actualizada
        paddb xmm15, xmm2               ;Resultado hasta ahora


;-------CASO 3----------------------------------------------------------------------------------------------------------------------
        movdqu xmm2, [menorA160]        ;xmm2 = [0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96]
        movdqu xmm3, xmm0               ;xmm3 = [0 0 | 0 p3 | 0 0 | 0 p2 | 0 0 | 0 p1 | 0 0 | 0 p0]

        pcmpgtw xmm2, xmm3              ;xmm2 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]

        movdqu xmm4, xmm2               ;xmm4 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]
        psrlw xmm4, 8                   ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan todos los menores a 96

        pxor xmm4, xmm14                ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan solo los x tal que 32 <= x < 96
                                        ;si entro en el caso anterior y en este caso no lo uso
                                        ;si entro en el caso actual pero no en el caso anterior si lo uso
                                        ;si entro en el caso anterior y no en el actual ABSURDO! anterior <32 antual <96 si <32 ---> tambien <96

        pand xmm2, xmm3                 ;xmm2 = los que son más chicos que 96 en sus respectivos lugares

        psubusb xmm2, [mascara96]       ;xmm2 = [0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32)]     FUNCIONA PORQUE ES EL CASO <32
        psllw xmm2, 2                   ;xmm2 = [0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4]
        
        pand xmm2, xmm4

        movdqu xmm5, xmm4
        psllw xmm5, 8
        paddb xmm5, xmm4

        psubb xmm5, xmm2

        pslld xmm2, 16
        
        paddb xmm2, xmm5       

        paddb xmm14, xmm4               ;xmm14 = la mascara anterior (esta va a ser la mascara del caso anterior que va a ir creciendo a medida que pasemos por los distintos casos)
        paddb xmm15, xmm2               ;xmm15 = res final (hasta ahora solo caso 1)


;-------CASO 4----------------------------------------------------------------------------------------------------------------------
        movdqu xmm2, [menorA224]        ;xmm2 = [0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96]
        movdqu xmm3, xmm0               ;xmm3 = [0 0 | 0 p3 | 0 0 | 0 p2 | 0 0 | 0 p1 | 0 0 | 0 p0]

        pcmpgtw xmm2, xmm3              ;xmm2 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]

        movdqu xmm4, xmm2               ;xmm4 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]
        psrlw xmm4, 8                   ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan todos los menores a 96

        pxor xmm4, xmm14                ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan solo los x tal que 32 <= x < 96
                                        ;si entro en el caso anterior y en este caso no lo uso
                                        ;si entro en el caso actual pero no en el caso anterior si lo uso
                                        ;si entro en el caso anterior y no en el actual ABSURDO! anterior <32 antual <96 si <32 ---> tambien <96

        pand xmm2, xmm3                 ;xmm2 = los que son más chicos que 96 en sus respectivos lugares

        psubusb xmm2, [mascara160]      ;xmm2 = [0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32)]     FUNCIONA PORQUE ES EL CASO <32
        psllw xmm2, 2                   ;xmm2 = [0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4]
        
        pand xmm2, xmm4
        psllw xmm2, 8

        movdqu xmm5, xmm4
        psllw xmm5, 8
        paddb xmm5, xmm4
        pslld xmm5, 8

        psubb xmm5, xmm2

        movdqu xmm2, xmm5

        paddb xmm14, xmm4              ;xmm14 = la mascara anterior (esta va a ser la mascara del caso anterior que va a ir creciendo a medida que pasemos por los distintos casos)
        paddb xmm15, xmm2              ;xmm15 = res final (hasta ahora solo caso 1)


;-------CASO 5----------------------------------------------------------------------------------------------------------------------
        movdqu xmm2, [sino]             ;xmm2 = [0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96 | 0 0 | 0 96]
        movdqu xmm3, xmm0               ;xmm3 = [0 0 | 0 p3 | 0 0 | 0 p2 | 0 0 | 0 p1 | 0 0 | 0 p0]

        pcmpgtw xmm2, xmm3              ;xmm2 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]

        movdqu xmm4, xmm2               ;xmm4 = [0 | 1/0 | 0 | 1/0 | 0 | 1/0 | 0 | 1/0]
        psrlw xmm4, 8                   ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan todos los menores a 96

        pxor xmm4, xmm14                ;xmm4 = [0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0) | 0 0 0 (1/0)] quedan solo los x tal que 32 <= x < 96
                                        ;si entro en el caso anterior y en este caso no lo uso
                                        ;si entro en el caso actual pero no en el caso anterior si lo uso
                                        ;si entro en el caso anterior y no en el actual ABSURDO! anterior <32 antual <96 si <32 ---> tambien <96

        pand xmm2, xmm3                 ;xmm2 = los que son más chicos que 96 en sus respectivos lugares

        psubusb xmm2, [mascara224]      ;xmm2 = [0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32) | 0 | 1/0(t-32)]     FUNCIONA PORQUE ES EL CASO <32
        psllw xmm2, 2                   ;xmm2 = [0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4 | 0 | 1/0(t-32)*4]
        
        psubb xmm4, xmm2

        movdqu xmm2, xmm4

        pslld xmm2, 16

        paddb xmm14, xmm4              ;xmm14 = la mascara anterior (esta va a ser la mascara del caso anterior que va a ir creciendo a medida que pasemos por los distintos casos)
        paddb xmm15, xmm2              ;xmm15 = res final (hasta ahora solo caso 1)


;-------TENEMOS EL RESULTADO EN XMM15----------------------------------------------------------------------------------------------------------------------
        ;rdi: src; rsi: dst; rdx: width; rxc: height; r8: rowSize; r9: colSize
        ;r10 = cantidad de iteraciones
        ;xmm0 = [0 0 0 t3 | 0 0 0 t2 | 0 0 0 t1 | 0 0 0 t0]

        movdqu xmm13, [transparenciaFinal]      ;xmm13 = [255 00 00 00 | 255 00 00 00 | 255 00 00 00 | 255 00 00 00]
        paddusb xmm15, xmm13                    ;xmm15 = [255 r g b | 255 r g b | 255 r g b | 255 r g b]

        movdqu [rsi], xmm15     ;Escribimos el resultado en el destino

        add rsi, 16             ;Avanzamos el puntero a fuente 16 bytes == 4 pixeles
        add rdi, 16             ;Avanzamos el puntero a destino 16 bytes
        
        dec r10                 ;Decrementamos el contador de iteraciones
	cmp r10, 0              ;Comparamos la cantidad de iteraciones con 0
	jne .ciclo
    

    pop r15
    pop r14
    pop r13
    pop r12
    pop rbp
    pop rbx

    pop rbp
    ret