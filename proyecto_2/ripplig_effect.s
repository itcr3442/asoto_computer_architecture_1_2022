! Memoria:
!   00  Lx
!   04  Ly
!   08  Ax
!   0c  Ay
!   10  y
!   14  x
!   18  divisor

start:
    imm r1, 0x100                 ! Posicion de memoria (?)
    imm r2, 75                
    stw [r1], r2                  ! Lx
    imm r2, 75                
    inc r1, 4       
    stw [r1], r2                  ! Ly
    inc r1, 4
    stw [r1], r0                  ! Contador = Ax
    inc r1, 4
    stw [r1], r0                  ! Ay
    inc r1, 4
    stw [r1], r0                  ! Height (y): Cantidad de filas de la imagen
    inc r1, 4
    stw [r1], r0                  ! Width  (x): Cantidad de columnas de la imagen

mainloop:
    imm r1, 0x108
    ldw r2, [r1]                  ! Cargar Ax
    inc r2, 5                     ! Sumar 5 al contador
    stw [r1], r2
    imm r1, 0x10c
    ldw r2, [r1]                  ! Cargar Ay
    inc r2, 5                     ! Sumar 5 al contador
    stw [r1], r2
    imm r3, 201
    bne r2, r3, rippling          ! Realizar el efecto
    bal HLT                       ! Finalizó

rippling:
    imm r1, 0x110
    ldw r2, [r1]                  ! Cargar y
    inc r2, 1                     ! y += 1
    stw [r1], r2
    imm r3, 301
    beq r2, r3, mainloop          ! Si y llegó al máximo de filas
    
nextcolumn:
    imm r1, 0x114
    ldw r2, [r1]                  ! Cargar x
    inc r2, 1                     ! x += 1
    stw [r1], r2
    imm r3, 301
    beq r2, r3, rippling          ! Si x llegó al máximo de columnas

!======= Cálculo de nuevo x =======!

    imm r1, 0x110
    ldw r2, [r1]                  ! r2 = y
    blk sin                       ! r2 = sin(2*pi*y/L)
    imm r1, 
    and r2, r2, r1                ! Aplicar máscara
    imm r1, 0x108
    ldw r3, [r1]                  ! r3 = Ax
    mul r2, r3                    ! r2 = Ax*sin(2*pi*y/Lx)
    imm r1, 0x114
    ldw r3, [r1]                  ! r3 = x
    add r2, r2, r3                ! r2 = x +  Ax*sin(2*pi*y/Lx)
    imm r4, 300                   ! r4 = 300
    blk division                  ! r10 = mod(r2, r4) 
    add r11, r0, r10              ! r11 = r10 (Nuevo valor de x)

!======= Cálculo de nuevo y =======!

    imm r1, 0x114
    ldw r2, [r1]                  ! r2 = x
    blk sin                       ! r2 = sin(2*pi*x/L)
    imm r1, 0x10c
    ldw r3, [r1]                  ! r3 = Ay
    mul r2, r3                    ! r2 = Ay*sin(2*pi*x/Ly)
    imm r1, 0x110
    ldw r3, [r1]                  ! r3 = y
    add r2, r2, r3                ! r2 = y + Ay*sin(2*pi*x/Ly)
    imm r4, 300                   ! r4 = 300
    blk division                  ! r10 = mod(r2, r4) (Nuevo valor de y)
    
    !if

    bal nextcolumn


HLT:

    


               
! sin(x) =  4x (180 − x) / [40500 − x (180 − x)]
! r2 = sin(r2)

sin:
    imm r14, 360
    add r3, r0, r2
    mul r3, r14                   ! r3 = x en grados y multiplicado por 2
    ! div r5/L
    imm r14, 180
    sub r2, r14, r3               ! r2 = (180 - x)
    mul r2, r3                    ! r2 = x (180 - x)
    imm r14, 40500
    sub r4, r14, r2               ! r3 = 40500 - x(180 - x)
    imm r14, 4
    mul r2, r14                   ! r2 = 4x (180 - x)
    sli r2, 8
    blk division                  ! div (r2<<8)/r4
    ret

 

! r2  = r2/r4
! r10 = r2%r4
division:
    xor r3, r3, r3                ! r3 = 0
    beq r2, r3, divdone           ! Si dividendo es cero => q = 0
    xor r5, r5, r5                ! r5 = 0
    beq r4, r5, divzero           ! Si el divisor es cero => ?
    add r3, r0, r4                ! r3 = r4
    blt r2, r3, divtriv
    imm r1, 0x118
    stw [r1], r4

    add r4, r0, r2                ! r4 = r2
    imm r5, 1                     ! Contador
    beq r4, r5, logdone           ! Si ya es 1
    logloop:
        sri r4, r4, 1             ! Shift right
        inc r5, 1                 ! Incrementar contador
        bne r4, r5, logloop       ! Verificar que no sea 1
    logdone:                      ! r5 = cantidad de bits
    add r3, r0, r5                ! r3 = r5
    dec r3, 1                     ! r3 = cantidad de bits - 1

    imm r4, 1                     ! r4 guarda la máscara
    xor r7, r7, r7                ! r7 = 0
    add r6, r0, r3                ! r6 = r3
    generatemask:
        beq r6, r7, continue   
        sli r4, r4, 1             ! r4 << 1
        inc r4, 1                ! Poner 1 en LSB
        dec r6, 1                 ! Decrementar el contador
        bal generatemask

    continue:
    add r6, r0, r5                 ! r6 = r5
    imm r1, 0x118
    ldw r11, [r1]                  ! r11 = divisor
    add r8, r0, r8
    
! Reservados: 
!   r2: dividendo
!   r3: n-1
!   r4: máscara
!   r6: n
!   r7: 0
!   r8: 1
!   r11: divisor

divloop:
    beq r6, r7, divdone  
    dec r6, 1                     ! Decrementar contador
    shr r5, r5, r3                ! r5 = MSB de Q
    sli r10, r10, 1               ! A << 1 (r10 = A)
    add r10, r10, r5              ! Colocar LSB de A
    sli r2, r2, 1                 ! Q << 1
    and r2, r2, r4                ! Aplicar máscara 
    add r9, r0, r10               ! Guardar A en r9
    sub r9, r9, r11               ! r9 = A-M 
    add r12, r0, r9               ! Guardar nuevo A en r12
    and r9, r9, r4                ! Aplicar máscara
    shr r9, r9, r3                ! r9 = MSB de A
    beq r8, r9, divloop           ! Si r9 == 1, no hacer nada
    inc r2, 1                     ! Sino agregar 1 al final de Q
    add r10, r0, r12

divtriv:
    add r10, r0, r2               ! El residuo es el dividendo
    add r2, r0, r0                ! El cociente es cero
    bal divdone

divzero:
    ! Error

divdone:
    ! r2: Cociente
    ! r10: Residuo
    ret


! r2 = round(r2)
round:
    imm r1, 64                  ! Máscara de bit 8
    add r13, r0, r2             ! r13 = r2
    and r13, r13, r1            ! Aplicar máscara a r13
    imm r12, 1                  ! r12 = 1
    sri r2, r2, 8               ! Quitar decimales
    bne r12, r13, ready         ! Si el bit 8 es 0
    inc r2, 1 
    ready


    








