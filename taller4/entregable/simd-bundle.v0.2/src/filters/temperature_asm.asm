shuffle_img: db 0x01,0x02,0x00,0x03,0x05,0x06,0x04,0x07,0x09,0x0A,0x08,0x0B,0x0D,0x0E,0x0C,0x0F

shuffle_casos: db 0x00,0x00,0x00,0x00,0x04,0x04,0x04,0x04,0x08,0x08,0x08,0x08,0x0C,0x0C,0x0C,0x0C
todos_128: db 128,0x00,0x00,0x00,128,0x00,0x00,0x00,128,0x00,0x00,0x00,128,0x00,0x00,0x00
tres: times 2 dq 3.0
caso1: times 4 dd 32
caso2: times 4 dd 96
caso3: times 4 dd 160
caso4: times 4 dd 224
res1: db 0x80,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00
res2: db 0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00
res3: db 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00
res4: db 0x00,0xFF, 0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x0
res5: db 0x00,0x00, 0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00
resto_32: db 0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00

resto_96: db 96,0x00, 0x00,0x00,96,0x00, 0x00,0x00,96,0x00, 0x00,0x00,96,0x00,0x00,0x00
resto_160: db 0x00,160,0x00, 0x00,0x00,160,0x00, 0x00,0x00,160,0x00, 0x00,0x00,160,0x00,0x00
resto_224: db 224,0x00, 0x00,0x00,224,0x00, 0x00,0x00,224,0x00, 0x00,0x00,224,0x00,0x00,0x00
and1: dd 0x00,0x00,0xFF,0x00        ; [0,0,algo,transp]
transparecia_final: db 0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF
global temperature_asm
menor_32: dd 0,1,2,3
menor_96: dd 33,34,35,36
menor_160: dd 96,97,98,99
menor_224: dd 160,161,162,163
mayor_224: dd 224,225,226,227
section .data

section .text
;void temperature_asm(unsigned char *src, rdi
;              unsigned char *dst,  rsi
;              int width,   rdx
;              int height, rcx
;              int src_row_size, r8
;              int dst_row_size, r9

temperature_asm:
    push rbp
    mov rbp,rsp
    
    push r12
    push rbx
    
    push rdi
    push rsi
    push r8
    push r9 

    mov rax,rdx
    mul rcx     ;en rax tengo la cantida de pixeles
    
    pop r9
    pop r8
    pop rsi
    pop rdi
    
    mov r8,rax 
    shr r8,2   ;en rbx iteraciones totales (tomamos de a 4 pixeles)
    
    shl rax,2   ;en rax me quedan cantidad de pixeles por tamaño de pixeles bytes (4bytes por pixel)

    ;add rsi,rax ;movemos el puntero del destino al final para armar  la imagen al revés
    ;Ya que el formato BPM procesa la imagen desde abajo
    ;sub rsi,16  ;voy al último pixel pq sino me paso

    .ciclo:        
        xor r10,r10
        xor r11,r11
        pxor xmm10,xmm10
        pxor xmm9,xmm9                   ; F E D C B A 9 8 7 6 5 4 3 2 1 0

        movdqu xmm0, [rdi]      ;xmm0 =  [ a r g b a r g b a r g b a r g b]
        movdqu xmm1,xmm0          ;         +    |   +   |   +   |    +
        
        pshufb xmm1,[shuffle_img] ;xmm1= [ a b r g a b r g a b r g a b r g]
        movdqu xmm2,xmm1
        pshufb xmm2, [shuffle_img] ;xmm2= [ a g b r a g b r a g b r a g b r]
        
        pmovzxbd xmm3,xmm0        ;muevo los primeros 4 bytes (1 pixel) de xmm0 a xmm3 extendiendo de Byte a Word
        psrldq xmm0,4             ;en xmm3 tengo el primer pixel voy al que sigue
        PMOVZXBd xmm4, xmm0
        psrldq xmm0,4
        PMOVZXBd xmm5, xmm0
        psrldq xmm0,4
        pmovzxbd xmm6, xmm0
        ;hasta acá los pixeles de xmm0 lo mismo para xmm1 
        pmovzxbd xmm7,xmm1      ;muevo los primeros 4 bytes de xmm0 a xmm3 extendiendo de Byte a dWord
        psrldq xmm1,4           ;en xmm7 tengo el primer pixel permutado voy al que sigue
        PMOVZXBd xmm8, xmm1
        psrldq xmm1,4
        PMOVZXBd xmm9, xmm1
        psrldq xmm1,4
        pmovzxbd xmm10, xmm1
        ;hago la primer suma entre permutaciones
        PADDd xmm7, xmm3           ; en cada lugar queda la suma en dwords de r+g+b y 3a
        PADDd xmm8, xmm4           ; de los primeros 2 pixeles en xmm7
        paddd xmm9, xmm5
        paddd xmm10, xmm6

        pmovzxbd xmm3,xmm2       ;muevo los primeros 4 bytes de xmm2 a xmm3 extendiendo de Byte a dword
        psrldq xmm2,4            ;en xmm3 tengo el primer pixel permutado 2 veces voy al que sigue
        PMOVZXBd xmm4, xmm2
        psrldq xmm2,4
        PMOVZXBd xmm5, xmm2
        psrldq xmm2,4
        pmovzxbd xmm6, xmm2

        PADDd xmm3,xmm7           ; en cada xmmi queda la suma en dwords de r+g+b y 3a de un pixel 4 veces
        PADDd xmm4,xmm8           
        paddd xmm5,xmm9
        paddd xmm6,xmm10

        pxor xmm7,xmm7
        pxor xmm8,xmm8
        pxor xmm9,xmm9
        pxor xmm10,xmm10

        CVTDQ2PD xmm0,xmm3      ; convierto D1 a double Precision float  
        CVTDQ2PD xmm1,xmm4      ; convierto D2 a double Precision float  
        CVTDQ2PD xmm2,xmm5      ; convierto D3 a double Precision float  
        cvtdq2pd xmm7,xmm6      ; convierto D4 a double Precision float  

        divpd xmm0, [tres]
        divpd xmm1, [tres]
        divpd xmm2, [tres]
        divpd xmm7, [tres]
        
        CVTTPD2DQ xmm4,xmm0
        CVTTPD2DQ xmm5,xmm1
        CVTTPD2DQ xmm6,xmm2
        CVTTPD2DQ xmm3,xmm7

        PACKUSDW xmm4,xmm5      ;primeros 2 pixeles en xmm4
        packusdw xmm6,xmm3      ;segundos 2 pixeles en xmm6

        packuswb xmm4,xmm6

        pextrb r10, xmm4, 0
        pextrb r11, xmm4, 4
        
        pinsrb xmm9,r10b,0
        pinsrb xmm9,r11b,4
        
        xor r10,r10 
        xor r11, r11

        pextrb r10, xmm4, 8
        pextrb r11, xmm4, 12
        

        pinsrb xmm9,r10b,8
        pinsrb xmm9,r11b,12        
;------ Casos de comparacion
        pxor xmm2,xmm2               ;acá voy a ir armando la respuesta final
        movdqu xmm9,[menor_224]
;------ calculamos los resultados del 1er caso
        movdqu xmm1, xmm9           ;placeholder para cuentas
        movdqu xmm11, [caso1]       ;armamos la masc de los que cumplen
        
        PCMPGTw xmm11,xmm1         ;usamos la mascara
        pand xmm1,xmm11           ;los que son más chicos que 32
        pshufb xmm11, [shuffle_casos]   ;ponemos 1s en todo el pixel que cumpla así hacemos las cuentas y nos olvidamos
        pand xmm1,xmm11            ;los que son más chicos que 32

        PSLLD xmm1,2                ;multiplicamos por 4 haciendo shift left
        movdqu xmm3,[res1]          ;ponemos la cte que queremos (128)
        pand xmm3,xmm11             ;nos quedamos con las ctes en lugares que nos sirven

        PADDD xmm1,xmm3             ;operamos 
        
        por xmm2,xmm1               ;agrego a los que ya cumplieron 

        movdqu xmm11,[caso1]        ;máscara para los que pasan al siguiente caso 
        PCMPGTw xmm11,xmm9          ;comparo 
        pandn xmm11,xmm9            ;saco los que ya cumplen. Hace primero el not al primer operando y desp el and
        movdqu xmm9,xmm11           
        
        ;xmm2=[C1,0,0,0]
        ;xmm2=[C1,0,0,0] or xmm1=[0 C2 0 0] =>[C1,C2,0,0]
;------ calculamos los resultados del 2do caso
        movdqu xmm1, xmm9           
        movdqu xmm11, [caso2]       ;armamos la masc de los que cumplen     [96,96,96,96]=xmm1
        
        PCMPGTw xmm11,xmm1          ;usamos la mascara [0,0,0,T][0,0,0,T][0,0,0,T][0,0,0,T] 
                                        ;              [0,0,0,96][0,0,0,96][0,0,0,96][0,0,0,96]
        
        pshufb xmm11, [shuffle_casos]   ;ponemos 1s en todo el pixel que cumpla así hacemos las cuentas y nos olvidamos
        pand xmm1,xmm11            ;los que son más chicos que 96
        

        movdqu xmm4,[res2]          ;agrego la cte 255         
        pand xmm4,xmm11
        
        PSLLD xmm1,8                ; tenemos [0,0,0,T] movemos a [0,0,T,0]
        
        movdqu xmm5,[resto_32]      ;un registro con el 32 para restar
        pand xmm5,xmm11
        
        psubd xmm1,xmm5             ;hacemos t-32
        PSLLD xmm1,2                ;4(t-32)
        paddd xmm4,xmm1             ;ahora si pongo la cte 255: [0,0,4(t-32),255] el resultado queda en xmm4
                                        ;[0,0,4(t-32),255][0,0,0,0][0,0,0,0][0,0,0,0]
      
        pand xmm4,xmm11
        por xmm2,xmm4               ;agrego a los que ya cumplieron 

        movdqu xmm11,[caso2]        ;máscara para los que pasan al siguiente caso 
        PCMPGTw xmm11,xmm9          ;comparo 
        pshufb xmm11, [shuffle_casos]

        pandn xmm11,xmm9            ;saco los que ya cumplen. Hace primero el not al primer operando y desp el and
        movdqu xmm9,xmm11
        
       
;------ calculamos los resultados del 3er caso
        movdqu xmm1, xmm9
        movdqu xmm11,[caso3]

        PCMPGTw xmm11,xmm1          ;usamos la mascara
        pshufb xmm11, [shuffle_casos]   ;ponemos 1s en todo el pixel que cumpla así hacemos las cuentas y nos olvidamos
        pand xmm1,xmm11            ;los que son más chicos que 160

        ;[0,0,T,A,|0,0,T,A,|0,0,T,A,|0,0,T,A]
        ;[0,0,96,0,|0,0,96,0,|0,0,96,0,|0,0,96,0]
        movdqu xmm5,[resto_96]
        psubb xmm1,xmm5     ; T-96
        pslld xmm1,2        ;4(t-96)

        movdqu xmm5,[res3]
        psubb xmm5,xmm1         ;[0, 255 , 255-4(t-96) , 0|0, 255 , 255-4(t-96), 0|0, 255 ,  255-4(t-96) , 0]
                                ;[T,A,0,0,|T,A,0,0,|T,A,0,0,|T,A,0,0]
        
        pslld xmm1,16           ;[T,0,0,0,|T,0,0,0,|T,0,0,0,|T,0,0,0] lo dejo separado para que sea más legible
        
        paddd xmm1,xmm5         ;[4(t-96) , 255, 255-4(t-96) , 0 | 4(t-96) ,255 , 255-4(t-96) ,0 | 4(t-96) ,255 , 255-4(t-96) , 0 ]
        movdqu xmm5,xmm1        ;el resultado queda en xmm5


        pand xmm5,xmm11
        por xmm2,xmm5               ;agrego a los que ya cumplieron 
        movdqu xmm11,[caso3]        ;máscara para los que pasan al siguiente caso 
        PCMPGTw xmm11,xmm9          ;comparo 
        pandn xmm11,xmm9            ;saco los que ya cumplen. Hace primero el not al primer operando y desp el and
        movdqu xmm9,xmm11
;------ calculamos los resultados del 4to caso
        movdqu xmm1,xmm9
        movdqu xmm11,[caso4]

        PCMPGTw xmm11,xmm1          ;usamos la mascara
        pshufb xmm11, [shuffle_casos]   ;ponemos 1s en todo el pixel que cumpla así hacemos las cuentas y nos olvidamos
        pand xmm1,xmm11            ;los que son más chicos que 224

        movdqu xmm6,[res4]
        pslld xmm1,8
        movdqu xmm7, [resto_160]
        psubd xmm1,xmm7  ;resto la cte

        pslld xmm1, 2           ;multiplico por 4
        pslld xmm1,8
        psubd xmm6,xmm1         ;el resultado que quiero me queda en xmm6
        
        pand xmm6,xmm11
        por xmm2,xmm6               ;agrego a los que ya cumplieron 
        movdqu xmm11,[caso4]        ;máscara para los que pasan al siguiente caso (mayor a 224)
        PCMPGTw xmm11,xmm9          ;comparo 
        pandn xmm11,xmm9             ;saco los que ya cumplen.
        movdqu xmm9,xmm11

;------ calculamos los resultados del 5to caso
        movdqu xmm1,xmm9        ;en xmm9 solo los que cumplen
        movdqu xmm8,[res5]


        psubd xmm1,[resto_224]
        pslld xmm1,2
        pslld xmm1, 16
        psubd xmm8,xmm1 
        movdqu xmm11,[caso4]
        PCMPGTw xmm11,xmm9
        pslld xmm11, 16
        pandn xmm11,xmm8         ;en xmm8 solo los que eran más grandes que 224 (pasaron el caso 4)
        movdqu xmm8,xmm11

        por xmm2,xmm8               ;agrego a los que ya cumplieron 


        ;en xmmm2 tengo TODOS los resultados, tengo que escribir la foto final
        paddd xmm2,[transparecia_final]

        movdqu [rsi],xmm2
        add rsi,16
        add rdi,16
		
        dec r8
	cmp r8,0
	jne .ciclo
    
    pop r12
    pop rbx
    pop rbp
    ret