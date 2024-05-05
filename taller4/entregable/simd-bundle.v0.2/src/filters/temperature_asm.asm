shuffle_img: db 0x01,0x02,0x00,0x03,0x05,0x06,0x04,0x07,0x09,0x0A,0x08,0x0B,0x0D,0x0E,0x0C,0x0F
todos_128: db 128,0x00,0x00,0x00,128,0x00,0x00,0x00,128,0x00,0x00,0x00,128,0x00,0x00,0x00
tres: times 2 dq 3.0
caso1: times 4 dd 32
caso2: times 4 dd 96
caso3: times 4 dd 160
caso4: times 4 dd 224
res1: db 0x80,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00,0x80,0x00,0x00, 0x00
res2: db 0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00
res3: db 0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00
res4: db 0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00,0x00, 0xFF,0xFF,0x00
res5: db 0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00,0xFF, 0x00,0x00,0x00
resto_32: db 0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x20,0x00,0x00
and1: db 0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00,0xFF,0x00,0x00,0x00
dos55: db 255,0x00,0x00,0x00,255,0x00,0x00,0x00,255,0x00,0x00,0x00,255,0x00,0x00,0x00
global temperature_asm

section .data

section .text
;void temperature_asm(unsigned char *src, rdi
;              unsigned char *dst,  rsi
;              int width,   rdx
;              int height, rcx
;              int src_row_size, r8
;              int dst_row_size); r9

temperature_asm:
    push rbp
    mov rbp,rsp
    
    push r12
    push rbx
    

    
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
        PADDB xmm1,xmm0           ; en cada lugar queda la suma en bytes de r+g+b y un byte de 3a
        PADDB xmm1,xmm2   
                                  ;llamo D=r+g+n ;xmm2= [ 3a_4 D4 D4 D4 3a_3 D3 D3 D3 3a_2 D2 D2 D2 3a_1 D1 D1 D1]   
        PEXTRB r10, xmm1,0        ; extraigo en r10<-- D1
        PEXTRB r11, xmm1,4        ; extraigo en r11<-- D2

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
        movdqu xmm4,[todos_128]      ;sumamos 128 porque los nuestros son sin signo
        PADDD xmm1,xmm4
        PCMPGTQ xmm11,xmm1          ;usamos la mascara
        pand xmm1,xmm11             ;me quedo con el valor de los que cumplieron

        PSLLD xmm1,2                ;multiplicamos por 4 haciendo shift left
        movdqu xmm4,[res1]          ;aponemos el num que queremos
        pand xmm4,xmm11

        PADDD xmm1,xmm4             ;operamos (checkear si tiene que saturar)
        
        movdqu xmm2,[and1]          
        pand   xmm1,xmm2            ;Ponemos ceros en los lugares 1 y 2 de los bytes
        
        
        por xmm2,xmm1
        pandn xmm11,xmm9            ; saco los que ya cumplen
        movdqu xmm9,xmm11
        
        ;xmm2=[C1,0,0,0]
        ;xmm2=[C1,0,0,0] or xmm1=[0 C2 0 0] =>[C1,C2,0,0]
;------ calculamos los resultados del 2do caso

        movdqu xmm1, xmm9           
        movdqu xmm11, [caso2]        ;;armamos la masc de los que cumplen
        PADDD xmm1,[todos_128]      ;sumamos 128 porque los nuestros son sin signo
        
        PCMPGTQ xmm11,xmm1  
        pand xmm1,xmm11
        PSLLD xmm1,8
        PSLLD xmm11,8
        movdqu xmm4,[resto_32]       ;un registro con el 32 para restar
        pand xmm4,xmm11
        psubd xmm1,xmm4
        PSLLD xmm1,2
        
        PSRLD xmm11,8
        movdqu xmm4,[res2]          
        pand xmm4,xmm11
        PADDD xmm1,xmm4
        
       
       
        
        movdqu xmm3,[dos55]
        pand xmm3,xmm11
        pand xmm1,xmm11             ;me quedo con el valor de los que cumplieron
        pandn xmm11,xmm9            ; saco los que ya cumplen
        movdqu xmm9,xmm11
        
       
;------ calculamos los resultados del 3er caso
        movdqu xmm6,[res3]
;------ calculamos los resultados del 4to caso
        movdqu xmm7,[res4]
;------ calculamos los resultados del 5to caso
        movdqu xmm8,[res5]

         movdqu xmm11, [caso1]
        PCMPEQQ xmm11,xmm9
                                    ;|   3    |    2   |   1    |    0   |
                                    ;    0         1       1         0
        movdqu xmm12, [caso2]
        PCMPEQQ xmm12,xmm9          

        movdqu xmm13, [caso3]
        PCMPEQQ xmm13,xmm9
        
        movdqu xmm14, [caso4]
        PCMPEQQ xmm14,xmm9
        
        
        
        movdqu xmm8,[todos_128]


		
		cmp rdi,0
	jne .ciclo
    
    pop r12
    pop rbx
    pop rbp
    ret