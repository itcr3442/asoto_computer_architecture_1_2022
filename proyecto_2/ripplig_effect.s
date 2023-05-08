; Memoria:
;   00  Lx
;   04  Ly
;   08  Ax
;   0c  Ay
;   10  y
;   14  x
;   18  divisor

start:
    imm r1, 0x100                 ; Posicion de memoria (?)

    add r2, r0, 75                
    stw r2, [r1]                  ; Lx
    add r2, r0, 75                
    inc r1, 4       
    stw r2, [r1]                  ; Ly
    inc r1, 4
    stw r0, [r1]                  ; Contador = Ax
    inc r1, 4
    stw r0, [r1]                  ; Ay
    inc r1, 4
    stw r0, [r1]                  ; Height (y): Cantidad de filas de la imagen
    inc r1, 4
    stw r0, [r1]                  ; Width  (x): Cantidad de columnas de la imagen

main_loop:
    imm r1, 0x108
    ldw [r1], r2                  ; Cargar Ax
    inc r2, 5                     ; Sumar 5 al contador
    stw r2, [r1]
    imm r1, 0x10c
    ldw [r1], r2                  ; Cargar Ay
    inc r2, 5                     ; Sumar 5 al contador
    stw r2, [r1]
    imm r3, 201
    bne r2, r3, rippling          ; Realizar el efecto
    bal HLT                       ; Finalizó

rippling:
    imm r1, 0x110
    ldw [r1], r2                  ; Cargar y
    add r2, r2, 1                 ; y += 1
    stw r2, [r1]
    imm r3, 301
    beq r2, r3, main_loop         ; Si y llegó al máximo de filas
    
next_column:
    imm r1, 0x114
    ldw [r1], r2                  ; Cargar x
    add r2, r2, 1                 ; x += 1
    stw r2, [r1]
    imm r3, 301
    beq r2, r3, rippling          ; Si x llegó al máximo de columnas

;======= Cálculo de nuevo x =======;

    imm r1, 0x110
    ldw [r1], r2                  ; r2 = y
    pcr r13, return_x             
    bal sin                       ; r2 = sin(2*pi*y/L)

return_x:
    imm r1, 0x108
    ldw r3, [r1]                  ; r3 = Ax
    mul r2, r2, r3                ; r2 = Ax*sin(2*pi*y/Lx)
    imm r1, 0x114
    ldw r3, [r1]                  ; r3 = x
    add r2, r2, r3                ; r2 = x +  Ax*sin(2*pi*y/Lx)
    imm r4, 300                   ; r4 = 300
    pcr r14, return_mod_x 
    bal division                  ; r10 = mod(r2, r4) 

return_mod_x:
    add r11, r0, r10              ; r11 = r10 (Nuevo valor de x)

;======= Cálculo de nuevo y =======;

    imm r1, 0x114
    ldw [r1], r2                  ; r2 = x
    pcr r13, return_y             
    bal sin                       ; r2 = sin(2*pi*x/L)

return_y:
    imm r1, 0x10c
    ldw r3, [r1]                  ; r3 = Ay
    mul r2, r2, r3                ; r2 = Ay*sin(2*pi*x/Ly)
    imm r1, 0x110
    ldw r3, [r1]                  ; r3 = y
    add r2, r2, r3                ; r2 = y + Ay*sin(2*pi*x/Ly)
    imm r4, 300                   ; r4 = 300
    pcr r14, return_mod_y 
    bal division                  ; r10 = mod(r2, r4) (Nuevo valor de y)

return_mod_y:
    
    ;if

    bal next_column


HLT

    


               
; sin(x) =  4x (180 − x) / [40500 − x (180 − x)]
; r2 = sin(r2)
; return: r13

sin:
    imm r15, 360
    mul r3, r2, r15               ; r3 = x en grados y multiplicado por 2
    ; div r5/L
    imm r15, 180
    sub r2, r15, r3               ; r2 = (180 - x)
    mul r2, r2, r3                ; r2 = x (180 - x)
    ldw r15, =40500
    sub r4, r15, r2               ; r3 = 40500 - x(180 - x)
    add r15, r0, 4
    mul r2, r2, r15               ; r2 = 4x (180 - x)
    pcr r14, return_sin
    bal division                  ; div r2/r4
return_sin:
    jr r13
 


; r2  = r2/r4
; r10 = r2%r4
division:
    xor r3, r3, r3                ; r3 = 0
    beq r2, r3, div_done          ; Si dividendo es cero => q = 0
    xor r5, r5, r5                ; r5 = 0
    beq r4, r5, div_zero          ; Si el divisor es cero => ?
    add r3, r0, r4                ; r3 = r4
    blt r2, r3, div_triv
    imm r1, 0x118
    stw r4, [r1]

    add r4, r0, r2                ; r4 = r2
    add r5, r0, 1                 ; Contador
    beq r4, r5, log_done          ; Si ya es 1
    log_loop:
        shr r4, r4, 1             ; Shift right
        inc r5, 1                 ; Incrementar contador
        bne r4, r5, log_loop      ; Verificar que no sea 1
    log_done:                     ; r5 = cantidad de bits
    add r3, r0, r5                ; r3 = r5
    dec r3, 1                     ; r3 = cantidad de bits - 1

    add r4, r0, 1                 ; r4 guarda la máscara
    xor r7, r7, r7                ; r7 = 0
    add r6, r0, r3                ; r6 = r3
    generate_mask:
        beq r6, r7, continue   
        shl r4, r4, 1             ; r4 << 1
        inc r14, 1                ; Poner 1 en LSB
        dec r6, 1                 ; Decrementar el contador
        b generate_mask

    continue:
    add r6, r0, r5                ; r6 = r5
    imm r1, 0x118
    ldw [r1], r11                  ; r11 = divisor
    add r8, r0, r8
    
; Reservados: 
;   r2: dividendo
;   r3: n-1
;   r4: máscara
;   r6: n
;   r7: 0
;   r8: 1
;   r11: divisor

div_loop:
    beq r6, r7, div_done  
    dec r6, 1                     ; Decrementar contador
    shr r5, r5, r3                ; r5 = MSB de Q
    shl r10, r10, 1               ; A << 1 (r10 = A)
    add r10, r10, r5              ; Colocar LSB de A
    shl r2, r2, 1                 ; Q << 1
    and r2, r2, r4                ; Aplicar máscara 
    add r9, r0, r10               ; Guardar A en r9
    sub r9, r9, r11               ; r9 = A-M 
    add r12, r0, r9               ; Guardar nuevo A en r12
    and r9, r9, r4                ; Aplicar máscara
    shr r9, r9, r3                ; r9 = MSB de A
    beq r8, r9, div_loop          ; Si r9 == 1, no hacer nada
    inc r2, 1                     ; Sino agregar 1 al final de Q
    add r10, r12

div_triv:
    add r10, r0, r2               ; El residuo es el dividendo
    add r2, r0, r0                ; El cociente es cero
    b div_done

div_zero:
    ; Error

div_done:
    ; r2: Cociente
    ; r10: Residuo
    jr r14







