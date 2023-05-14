! Memoria:
!   00  Lx
!   04  Ly
!   08  Ax
!   0c  Ay
!   10  y
!   14  x
!   1c  Contador memoria
!   20  
!   24  nuevo x
!   28  divisor


reset:

!equ START_BUTTON, 0x30050000       Dirección de memoria del botón
!equ START, 0x00010000              Dirección de memoria de los pixeles
!equ VRAM, 0x38000000 

imm r1, 0x00010000                ! r1 = direccion de los pixeles
imm r2, 0x38000000                ! r2 = direccion a VRAM
imm r4, 307200                    ! r4 = (640*480)
imm r5, 0                         ! r5 = 0

init:
    ldw r3, [r1]    	          ! r3 = pixel
    inc r1, 4
    stw [r2], r3                  ! Guardar pixel en VRAM
    inc r2, 4
    inc r5, 1         	          ! Incrementa contador de tamaño de la imagen
    bne r4, r5, init

imm r4, 0x30050000                ! r4 = direccion del boton (pin AA14)
imm r7, 0                         ! r7 = 0
idle:
    ldw r6, [r4]                  ! Leer valor del botón 
    beq r6, r7, idle              ! Botón != 1, esperar

start:
    imm r1, 0x00001000            ! Direccion para guardar variables
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
    inc r1, 4
    stw [r1], r0                  ! Contador memoria

mainloop:
    imm r1, 0x0000101c            ! Reiniciar
    stw [r1], r0                  ! Posicionarse al inicio de los pixeles (x)

    imm r1, 0x00001010            ! Reiniciar
    stw [r1], r0                  ! Posicionarse al inicio de los pixeles (y)
    imm r4, 307200                ! r4 = (640*480)
    imm r5, 0                     ! r5 = 0
    imm r2, 0x38000000            ! r2 = direccion a VRAM
    clearVRAM:
        stw [r2], r0              ! Guardar pixel en VRAM
        inc r2, 4
        inc r5, 1         	      ! Incrementa contador de tamaño de la imagen
        bne r4, r5, clearVRAM

    imm r1, 0x00001008
    ldw r2, [r1]                  ! Cargar Ax
    inc r2, 5                     ! Sumar 5 al contador
    stw [r1], r2
    imm r1, 0x0000100c
    ldw r2, [r1]                  ! Cargar Ay
    inc r2, 5                     ! Sumar 5 al contador
    stw [r1], r2

    imm r3, 201
    bne r2, r3, rippling          ! Realizar el efecto
    hlt                           ! Finalizó

rippling:
    imm r1, 0x00001014
    stw [r1], r0                  ! Reiniciar x
    imm r1, 0x00001010
    ldw r2, [r1]                  ! Cargar y
    inc r2, 1                     ! y += 1
    stw [r1], r2
    imm r3, 481
    beq r2, r3, mainloop          ! Si y llegó al máximo de filas
    
nextcolumn:
    imm r1, 0x00001014
    ldw r2, [r1]                  ! Cargar x
    inc r2, 1                     ! x += 1
    stw [r1], r2
    imm r3, 641
    beq r2, r3, rippling          ! Si x llegó al máximo de columnas

!======= Cálculo de nuevo x =======!
    imm r1, 0x00001010
    ldw r2, [r1]                  ! r2 = y
    imm r1, 0x00001000
    ldw r4, [r1]                  ! r4 = Lx
    blk sin                       ! r2 = sin(2*pi*y/Lx)
    imm r1, 0x00001008
    ldw r3, [r1]                  ! r3 = Ax
    mul r2, r2, r3                ! r2 = Ax*sin(2*pi*y/Lx)
    imm r1, 0x00001014
    ldw r3, [r1]                  ! r3 = x
    add r2, r2, r3                ! r2 = x + Ax*sin(2*pi*y/Lx)
    blk round                     ! r2 = round(r2)
    imm r4, 640                   ! r4 = 640
    blk division                  ! r10 = mod(r2, r4)
    imm r1, 0x00001024 
    stw [r1], r10                 ! r10 = Nuevo valor de x

!======= Cálculo de nuevo y =======!
    imm r1, 0x00001014
    ldw r2, [r1]                  ! r2 = x
    imm r1, 0x00001004
    ldw r4, [r1]                  ! r4 = Ly
    blk sin                       ! r2 = sin(2*pi*x/Ly)
    imm r1, 0x0000100c
    ldw r3, [r1]                  ! r3 = Ay
    mul r2, r2, r3                ! r2 = Ay*sin(2*pi*x/Ly)
    imm r1, 0x00001010
    ldw r3, [r1]                  ! r3 = y
    add r2, r2, r3                ! r2 = y + Ay*sin(2*pi*x/Ly)
    blk round                     ! r2 = round(r2)
    imm r4, 480                   ! r4 = 480
    blk division                  ! r10 = mod(r2, r4) (Nuevo valor de y)
    
!======= Almacenar en VRAM =======!
    imm r1, 0x00001024 
    ldw r5, [r1]                  ! r5 = nuevo x
    imm r1, 0x0000101c 
    ldw r4, [r1] 	              ! r4 = Contador memoria
    imm r2, 0x00010000
    add r2, r2, r4                ! Sumar offset al contador
    ldw r3, [r2]                  ! r3 = pixel
    inc r4, 4                     ! Aumentar contador de memoria
    stw [r1], r4                  ! Guardar contador de memoria
    imm r1, 0x38000000                 
    add r6, r0, r5                ! r6 = r5
    dec r10, 1                    ! nuevo y -= 1
    imm r7, 640                   
    mul r10, r10, r7              ! Calcular offset de eje y
    add r6, r6, r10               ! Sumar offset + nuevo x
    sli r6, r6, 2                 ! Multiplicar por 4 para calcular posicion de memoria
    add r1, r1, r6                ! r1 = nueva posicion en VRAM 
    stw [r1], r3                  ! Guardar pixel en su nueva posicion

    bal nextcolumn

               
! sin(x) =  4x (180 - x) / [40500 - x (180 - x)]
! r2 = sin(r2/r4) = sin(x/L)

sin:
imm r1, 0x30000000             ! print
imm r13, 0x52                  ! print(S)
stw [r1], r13                  ! print
    imm r14, 360
    mul r2, r2, r14               ! r2 = x en grados y multiplicado por 2
    blk division                  ! r2 = r2/r4 = x/L
    add r3, r0, r2                ! r3 = r2 = 2*pi*x*180/(L*pi)
    imm r14, 180
    sub r2, r14, r3               ! r2 = (180 - x)
    mul r2, r2, r3                ! r2 = x (180 - x)
    imm r14, 40500
    sub r4, r14, r2               ! r4 = 40500 - x(180 - x)
    imm r14, 4
    sli r2, r2, 10                ! r2 = [4x (180 - x)] << 8
    blk division                  ! div (r2<<8)/r4
    ret


! r2  = r2/r4
! r10 = r2%r4
division:
    xor r3, r3, r3                ! r3 = 0
    beq r2, r3, diveqzero         ! Si dividendo es cero => q = 0
    xor r5, r5, r5                ! r5 = 0
    beq r4, r5, divbyzero         ! Si el divisor es cero => ?
    add r3, r0, r4                ! r3 = r4
    blt r2, r3, divtriv
    imm r1, 0x00001028
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
        inc r4, 1                 ! Poner 1 en LSB
        dec r6, 1                 ! Decrementar el contador
        bal generatemask

    continue:
    add r6, r0, r5                 ! r6 = r5
    imm r1, 0x00001028
    ldw r11, [r1]                  ! r11 = divisor
    xor r10, r10, r10
    imm r8, 1
    
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
    bal divloop

divtriv:
    add r10, r0, r2               ! El residuo es el dividendo
    add r2, r0, r0                ! El cociente es cero
    bal divdone

divbyzero:
    ! Error

diveqzero:
    add r10, r0, r0               ! El residuo es cero
    add r2, r0, r0                ! El cociente es cero
    bal divdone

divdone:
    ! r2: Cociente
    ! r10: Residuo
    ret


! r2 = round(r2)
round:
    imm r1, 128                 ! Máscara de bit 8
    add r13, r0, r2             ! r13 = r2
    and r13, r13, r1            ! Aplicar máscara a r13
    sri r13, r13, 7             ! Obtener bit 8
    imm r12, 1                  ! r12 = 1
    sri r2, r2, 8               ! Quitar decimales
    bne r12, r13, ready         ! Si el bit 8 es 0
    inc r2, 1 
    ready:
        ret
