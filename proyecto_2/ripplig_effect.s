

start:
    add r1, r0, #0x100            ; Posicion de memoria (?)

    add r1, r0, #75               ; Lx
    str r1, [r1]
    add r1, r0, #75               ; Lx
    str r1, [r1+4]

    str r0, [r1+8]                ; Contador = Ax(Ay)
    str r0, [r1+12]               ; Height (y): Cantidad de filas de la imagen
    str r0, [r1+16]               ; Width  (x): Cantidad de columnas de la imagen

main_loop:
    ldr [r1+8], r2
    add r2, r2, #5                ; Sumar 5 al contador
    str r2, [r1+8]
    add r3, r0, #201
    bne r2, r3, rippling          ; Realizar el efecto
    bal HLT                       ; Finalizó

rippling:
    ldr [r1+12], r2
    add r2, r2, #1                ; y += 1
    str r2, [r1+12]
    add r3, r0, #301
    beq r2, r3, main_loop         ; Si y llegó al máximo de filas
    
next_column:
    ldr [r1+16], r2
    add r2, r2, #1                ; x += 1
    str r2, [r1+16]
    add r3, r0, #301
    beq r2, r3, rippling          ; Si x llegó al máximo de columnas

;======= Cálculo de nuevo x =======;

    ldr [r1+12], r2               ; r2 = y
    pcr r13, return_x             
    jmp sin                       ; r2 = sin(2*pi*y/L)

return_x:
    ldr r3, [r1+8]                ; r3 = Ax
    mul r2, r2, r3                ; r2 = Ax*sin(2*pi*y/Lx)
    ldr r3, [r1+16]               ; r3 = x
    add r2, r2, r3                ; r2 = x +  Ax*sin(2*pi*y/Lx)
    add r4, r0, #300              ; r4 = 300
    pcr r14, return_mod_x 
    jmp division                  ; r10 = mod(r2, r4) 

return_mod_x:
    add r11, r0, r10              ; r11 = r10 (Nuevo valor de x)

;======= Cálculo de nuevo y =======;

    ldr [r1+16], r2               ; r2 = x
    pcr r13, return_y             
    jmp sin                       ; r2 = sin(2*pi*x/L)

return_y:
    ldr r3, [r1+8]                ; r3 = Ay
    mul r2, r2, r3                ; r2 = Ay*sin(2*pi*x/Ly)
    ldr r3, [r1+12]               ; r3 = y
    add r2, r2, r3                ; r2 = y + Ay*sin(2*pi*x/Ly)
    add r4, r0, #300              ; r4 = 300
    pcr r14, return_mod_y 
    jmp division                  ; r10 = mod(r2, r4) (Nuevo valor de y)

return_mod_y:
    
    ;if

    jmp next_column


HLT

    



;               4x (180 − x)
; sin(x) =  -------------------
;           40500 − x (180 − x)

; r2 = sin(r2)
; return: r13

sin:
    add r15, r0, #360
    mul r3, r2, r15               ; r3 = x en grados y multiplicado por 2
    ; div r5/L
    add r15, r0, #180
    sub r2, r15, r3               ; r2 = (180 - x)
    mul r2, r2, r3                ; r2 = x (180 - x)
    ldr r15, =40500
    sub r4, r15, r2               ; r3 = 40500 - x(180 - x)
    add r15, r0, #4
    mul r2, r2, r15               ; r2 = 4x (180 - x)
    pcr r14, return_sin
    jmp division                  ; div r2/r4
return_sin:
    jr r13
 


; r2  = r2/r4
; r10 = r2%r4
division:
    add r3, r0, r0                ; r3 = 0
    beq r2, r3, div_done          ; Si dividendo es cero => q = 0
    add r5, r0, r0                ; r5 = 0
    beq r4, r5, div_zero          ; Si el divisor es cero => ?
    add r3, r0, r4                ; r3 = r4
    blt r2, r3, div_triv 
    str r4, [r1+20]

    add r4, r0, r2                ; r4 = r2
    add r5, r0, #1                ; Contador
    beq r4, r5, log_done          ; Si ya es 1
    log_loop:
        shr r4, r4, #1            ; Shift right
        add r5, r5, #1            ; Incrementar contador
        bne r4, r5, log_loop      ; Verificar que no sea 1
    log_done:                     ; r5 = cantidad de bits
    add r3, r0, r5                ; r3 = r5
    sub r3, r3, #1                ; r3 = cantidad de bits - 1

    add r4, r0, #1                ; r4 guarda la máscara
    add r7, r0, r0                ; r7 = 0
    add r6, r0, r3                ; r6 = r3
    generate_mask:
        beq r6, r7, continue   
        shl r4, r4, #1            ; r4 << 1
        add r4, r4, #1            ; Poner 1 en LSB
        sub r6, r6, #1 
        b generate_mask

    continue:
    add r6, r0, r5                ; r6 = r5
    ldr [r1+20], r9               ; r11 = divisor
    add r8, r0, #1

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
    sub r6, r6 #1                 ; r6 = r6-1
    shr r5, r5, r3                ; r5 = MSB de Q
    shl r10, r10, #1              ; A << 1 (r10 = A)
    add r10, r10, r5              ; Colocar LSB de A
    shl r2, r2, #1                ; Q << 1
    and r2, r2, r4                ; Aplicar máscara 
    add r9, r0, r10               ; Guardar A en r9
    sub r9, r9, r11               ; r9 = A-M 
    add r12, r0, r9               ; Guardar nuevo A en r12
    shr r9, r9, #TAMAÑO DEL REG   ; r13 = MSB de A
    beq r8, r9, div_loop          ; Si r13 == 1, no hacer nada
    add r2, r2, #1                ; Sino agregar 1 al final de Q
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







