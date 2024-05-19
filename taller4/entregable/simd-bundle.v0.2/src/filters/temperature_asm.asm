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
res3: db 0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00
res4: db 0xFF, 0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x0,0x00
res5: db 0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00
resto_32: db 0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00

resto_96: db 0x00,0x00,96,0x00, 0x00,0x00,96,0x00, 0x00,0x00,96,0x00, 0x00,0x00,96,0x00
resto_160: db 0x00,0x00,160,0x00, 0x00,0x00,160,0x00, 0x00,0x00,160,0x00, 0x00,0x00,160,0x00
resto_224: db 0x00,0x00,224,0x00, 0x00,0x00,224,0x00, 0x00,0x00,224,0x00, 0x00,0x00,224,0x00
and1: dd 0x00,0x00,0xFF,0x00        ; [0,0,algo,transp]
transparecia_final: db 0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF
global temperature_asm

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
        
        pmovzxbw xmm3,xmm0

        PMOVZXBW xmm4, xmm1
        
        PMOVZXBW xmm5, xmm2
        
        PADDw xmm3,xmm4           ; en cada lugar queda la suma en words de r+g+b y un byte de 3a
        PADDw xmm5,xmm3           ; los primeros 2 pixeles en xmm5

        psrlq xmm0,8
        psrlq xmm1,8
        psrlq xmm2,8

        pmovzxbw xmm3,xmm0              

        PMOVZXBW xmm4, xmm1
        
        PMOVZXBW xmm6, xmm2
        
        PADDw xmm3,xmm4           ; en cada lugar queda la suma en words de r+g+b y un byte de 3a
        PADDw xmm4,xmm6           ; los segundo 2 pixeles en xmm4

                                  ;llamo D_i=r+g+n ;xmm5= [ 3a_2 D2 D2 D2 |3a_1 D1 D1 D1]   con D en words
        PEXTRw r10, xmm5,0        ; extraigo en r10<-- D1
        PEXTRw r11, xmm5,4        ; extraigo en r11<-- D2

        CVTSI2SD xmm2,r10         ; convierto D1 a float en la parte baja de xmm2  (QuadWord) 
        CVTSI2SD xmm3,r11         ; convierto D2 a float en la parte baja de xmm3  (QuadWord) 
        PEXTRQ r10,xmm2,0         ; muevo D1f  a r10 para el insert
        PINSRQ xmm3,r10,1

        divpd xmm3, [tres]
        PEXTRQ r10,xmm3,1           ;extraigo la quadword alta de xmm3 porque cvtt... solo trabaja con la parte baja de xmm3
        CVTTSD2SI rbx,xmm3          ;convierto D2 de float a integer truncado 
        PINSRD xmm3,r10d,0
        CVTTSD2SI r12,xmm3          ;convierto D1 de float a integer truncado 
        PINSRD xmm9,r12d,0          ;lo insertamos en la parte baja de la segunda QW de xmm10
        PINSRD xmm9,ebx,1           ;lo insertamos en la parte baja de la segunda QW de xmm10



;---------- segundos dos pixeles
        PEXTRB r10, xmm1,8          ; extraigo en r10<-- D1
        PEXTRB r11, xmm1,12         ; extraigo en r11<-- D2

        CVTSI2SD xmm2,r10           ; convierto D1 a float en la parte baja de xmm2  (QuadWord) 
        CVTSI2SD xmm3,r11           ; convierto D2 a float en la parte baja de xmm3  (QuadWord) 
        PEXTRQ r10,xmm2,0           ; muevo D1f  a r10 para el insert
        PINSRQ xmm3,r10,1

        divpd xmm3, [tres]          ;hago la division de floats
        PEXTRQ r10,xmm3,1           ;extraigo la quadword alta de xmm3 porque cvtt... solo trabaja con la parte baja de xmm3
        CVTTSD2SI rbx,xmm3          ;convierto D2 de float a integer truncado 
        PINSRD xmm3,r10d,0
        CVTTSD2SI r12,xmm3          ;convierto D1 de float a integer truncado 
        PINSRD xmm10,r12d,2          ;lo insertamos en la parte baja de la segunda QW de xmm10
        PINSRD xmm10,ebx,3          ;lo insertamos en la parte alta de la segunda QW d          
        PADDD xmm9,xmm10            ;juntamos los resultados en xmm9

;------ Casos de comparacion
        pxor xmm2,xmm2               ;acá voy a ir armando la respuesta final
;------ calculamos los resultados del 1er caso
        movdqu xmm1, xmm9           ;placeholder para cuentas
        movdqu xmm11, [caso1]       ;armamos la masc de los que cumplen
        
        PCMPGTB xmm11,xmm1         ;usamos la mascara
        pand xmm1,xmm11            ;los que son más chicos que 32

        PSLLD xmm1,2                ;multiplicamos por 4 haciendo shift left
        movdqu xmm3,[res1]          ;ponemos la cte que queremos (128)
        pand xmm3,xmm11             ;nos quedamos con las ctes en lugares que nos sirven

        PADDD xmm1,xmm3             ;operamos 
        
        movdqu xmm3,[todos_128]      ;sumamos 128 porque los nuestros son sin signo      
        PADDB xmm3,xmm1             ;ahora si tenemos el resultado en xmm3
        
        movdqu xmm12,[and1]          
        pand   xmm3,xmm12            ;Ponemos ceros en los lugares 1 y 2 de los bytes   queremos [0,0,128+4t]
        
        pand   xmm3,xmm11
        por xmm2,xmm3               ;agrego a los que ya cumplieron 

        movdqu xmm11,[caso1]        ;máscara para los que pasan al siguiente caso 
        pcmpgtb xmm11,xmm9          ;comparo 
        pandn xmm11,xmm9            ;saco los que ya cumplen. Hace primero el not al primer operando y desp el and
        movdqu xmm9,xmm11           
        
        ;xmm2=[C1,0,0,0]
        ;xmm2=[C1,0,0,0] or xmm1=[0 C2 0 0] =>[C1,C2,0,0]
;------ calculamos los resultados del 2do caso
        movdqu xmm1, xmm9           
        movdqu xmm11, [caso2]       ;armamos la masc de los que cumplen     [96,96,96,96]=xmm1
        
        PCMPGTb xmm11,xmm1          ;usamos la mascara [0,0,0,T][0,0,0,T][0,0,0,T][0,0,0,T] 
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
        paddd xmm1,xmm4             ;ahora si pongo la cte 255: [0,0,4(t-32),255] el resultado queda en xmm4
                                        ;[0,0,4(t-32),255][0,0,0,0][0,0,0,0][0,0,0,0]
        movdqu xmm4,[todos_128]      ;sumamos 128 porque los nuestros son sin signo      
        PADDUSB xmm4,xmm1             ;ahora si tenemos el resultado en xmm4

      
        pand xmm4,xmm11
        por xmm2,xmm4               ;agrego a los que ya cumplieron 

        movdqu xmm11,[caso2]        ;máscara para los que pasan al siguiente caso 
        pcmpgtb xmm11,xmm9          ;comparo 

        pandn xmm11,xmm9            ;saco los que ya cumplen. Hace primero el not al primer operando y desp el and
        movdqu xmm9,xmm11 
        
       
;------ calculamos los resultados del 3er caso
        movdqu xmm1, xmm9
        movdqu xmm11,[caso3]
        

        PCMPGTQ xmm11,xmm1          ;usamos la mascara
        pshufb xmm11, [shuffle_casos]   ;ponemos 1s en todo el pixel que cumpla así hacemos las cuentas y nos olvidamos
        pand xmm1,xmm11            ;los que son más chicos que 160
        

        ;asumo que en xmm1 tengo la temperatura calculada con el filtro
        ;128                                0
        ;[0,0,T,A,|0,0,T,A,|0,0,T,A,|0,0,T,A]
        ;[0,0,96,0,|0,0,96,0,|0,0,96,0,|0,0,96,0]
        movdqu xmm5,[resto_96]
        psubd xmm1,xmm5     ; T-96
        pslld xmm1,2        ;4(t-96)

        movdqu xmm5,[res3]
        psubd xmm5,xmm1         ;[0, 255 , 255-4(t-96) , 0|0, 255 , 255-4(t-96), 0|0, 255 ,  255-4(t-96) , 0]
                                ;[T,A,0,0,|T,A,0,0,|T,A,0,0,|T,A,0,0]
        psrld xmm1,8            ;shift 1 byte para borrar la transparencia A de cada pixel
        pslld xmm1,8            ;[0,0,T,0,|0,0,T,0,|0,0,T,0,|0,0,T,0]
        pslld xmm1,16           ;[T,0,0,0,|T,0,0,0,|T,0,0,0,|T,0,0,0] lo dejo separado para que sea más legible
        
        paddd xmm1,xmm5         ;[4(t-96) , 255, 255-4(t-96) , 0 | 4(t-96) ,255 , 255-4(t-96) ,0 | 4(t-96) ,255 , 255-4(t-96) , 0 ]
        movdqu xmm5,xmm1        ;el resultado queda en xmm5

        movdqu xmm5,[todos_128]      ;sumamos 128 porque los nuestros son sin signo      
        PADDUSB xmm5,xmm1             ;ahora si tenemos el resultado en xmm5

        pand xmm5,xmm11
        por xmm2,xmm5               ;agrego a los que ya cumplieron 
        movdqu xmm11,[caso3]        ;máscara para los que pasan al siguiente caso 
        pcmpgtq xmm11,xmm9          ;comparo 
        pand xmm11,xmm9            ;saco los que ya cumplen. Hace primero el not al primer operando y desp el and
        movdqu xmm9,xmm11 
;------ calculamos los resultados del 4to caso
        movdqu xmm1,xmm9
        movdqu xmm11,[caso4]
        PCMPGTQ xmm11,xmm1          ;usamos la mascara
        pshufb xmm11, [shuffle_casos]   ;ponemos 1s en todo el pixel que cumpla así hacemos las cuentas y nos olvidamos
        pand xmm1,xmm11            ;los que son más chicos que 160
        pand xmm1,xmm11            ;los que son más chicos que 224
        
        movdqu xmm6,[res4]

        psubd xmm1,[resto_160]  ;resto la cte
        pslld xmm1, 2           ;multiplico por 4
        pslld xmm1,8
        psubd xmm6,xmm1         ;el resultado que quiero me queda en xmm6
        
        movdqu xmm6,[todos_128]      ;sumamos 128 porque los nuestros son sin signo      
        PADDUSB xmm6,xmm1             ;ahora si tenemos el resultado en xmm6
        pand xmm6,xmm11
        por xmm2,xmm6               ;agrego a los que ya cumplieron 
        movdqu xmm11,[caso4]        ;máscara para los que pasan al siguiente caso (mayor a 224)
        pcmpgtq xmm11,xmm1          ;comparo 
        pand xmm9,xmm11             ;saco los que ya cumplen.
        

;------ calculamos los resultados del 5to caso
        movdqu xmm1,xmm9        ;en xmm9 solo los que cumplen
        movdqu xmm8,[res5]


        psubd xmm1,[resto_224]
        pslld xmm1,2
        pslld xmm1, 16
        psubd xmm8,xmm1 
        movdqu xmm8,[todos_128] ;en xmm8 los resultados
        PADDUSB xmm8,xmm1             ;ahora si tenemos el resultado en xmm8
        pandn xmm11,xmm8         ;en xmm8 solo los que eran más grandes que 224
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