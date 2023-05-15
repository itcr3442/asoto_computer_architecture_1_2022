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

! Stack pointer
imm sp, 0x00002000

!equ START_BUTTON, 0x30050000       Dirección de memoria del botón
!equ START, 0x00010000              Dirección de memoria de los pixeles
!equ VRAM, 0x38000000 

imm t0, 0x00002000
mov t1, zero
imm t2, 640
x_sin_loop:
inc t1, 1
mov a0, t1
imm a1, 75
blk sin
stw [t0], o0
inc t0, 4
blt t1, t2, x_sin_loop

! Esto duplica trabajo pero es un safeback durante la
! defensa por si al profe se le ocurre que Lx != Ly
imm t0, 0x00003000
mov t1, zero
imm t2, 480
y_sin_loop:
inc t1, 1
mov a0, t1
imm a1, 75
blk sin
stw [t0], o0
inc t0, 4
blt t1, t2, y_sin_loop

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

    imm r3, 200
    blt r2, r3, rippling          ! Realizar el efecto
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
! imm a0, 'x'    ! print  \
! blk dbg_char   ! se pierde a0, a1, s0, s1, o0, o1
    imm r1, 0x00001010            ! cargar dirección de y
    ldw a0, [r1]                  ! a0 = y
    imm r1, 0x00002000
    ldw a1, [r1]                  ! r4 = Lx
	dec a1, 1
	sli a1, a1, 2
	add a1, a1, r1
	ldw r2, [a1]
!psh a0, a1, s0, s1, o0, o1
!mov a0, o0                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    mov r2, o0                    ! resultado de seno se guarda en r2
    imm r1, 0x00001008            ! cargar dirección de Ax
    ldw r3, [r1]                  ! r3 = Ax
    mul r2, r2, r3                ! r2 = Ax*sin(2*pi*y/Lx)
    imm r1, 0x00001014            ! cargar dirección de memoria de x
    ldw r3, [r1]                  ! r3 = x
!psh a0, a1, s0, s1, o0, o1
!mov a0, r3                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    sli r3, r3, 8
    add a0, r2, r3                ! r2 = x + Ax*sin(2*pi*y/Lx)
!psh a0, a1, s0, s1, o0, o1
!mov a0, r2                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    blk round                     ! o0 = round(a0)
!psh a0, a1, s0, s1, o0, o1
!mov a0, o0                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    mov a0, o0 
    imm a1, 640                   ! r4 = 640
    blk division                  ! o1 = mod(a0, a1)
    mov r10, o1
    imm r1, 0x00001024            ! cargar direccion de memoria de nuevo x
    stw [r1], r10                 ! r10 = Nuevo valor de x
!psh a0, a1, s0, s1, o0, o1
!mov a0, r10                       ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1

!======= Cálculo de nuevo y =======!
    imm r1, 0x00001014
    ldw a0, [r1]                  ! r2 = x
    imm r1, 0x00003000
	dec a0, 1
	sli a0, a0, 2
	add a1, a0, a1
	ldw r2, [a1]

    imm r1, 0x0000100c
    ldw r3, [r1]                  ! r3 = Ay
    mul r2, r2, r3                ! r2 = Ay*sin(2*pi*x/Ly)
    imm r1, 0x00001010
    ldw r3, [r1]                  ! r3 = y
!psh a0, a1, s0, s1, o0, o1
!mov a0, r3                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    sli r3, r3, 8
    add a0, r2, r3                ! r2 = y + Ay*sin(2*pi*x/Ly)
    blk round                     ! r2 = round(r2)
    mov a0, o0
    imm a1, 480                   ! r4 = 480
    blk division                  ! r10 = mod(r2, r4) (Nuevo valor de y)
    mov r10, o1
!psh a0, a1, s0, s1, o0, o1
!mov a0, r10                       ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
!psh a0, a1, s0, s1, o0, o1
!imm a0, '-'                       ! print  \
!blk dbg_char                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1

!======= Almacenar en VRAM =======!
    imm r1, 0x00001024            ! cargar dirección de memoria de nuevo x 
    ldw r5, [r1]                  ! r5 = nuevo x
    imm r1, 0x0000101c            ! cargar dirección de memoria de contador dememoria
    ldw r4, [r1] 	              ! r4 = Contador memoria
    imm r2, 0x00010000            ! cargar dirección de pixeles
    add r2, r2, r4                ! Sumar contador a esa dirección
    ldw r3, [r2]                  ! r3 = pixel (lo sacamos de dirección de pixleles)
    inc r4, 4                     ! Aumentar contador de memoria
    stw [r1], r4                  ! Guardar contador de memoria
    imm r1, 0x38000000            ! cargar dirección de vram
    dec r10, 1                    ! nuevo y -= 1
    dec r5, 1                     ! nuevo x -= 1
    imm r7, 640                   !               
    mul r10, r10, r7              ! Calcular offset de eje y
    add r5, r5, r10               ! Sumar offset + nuevo x
    sli r5, r5, 2                 ! Multiplicar por 4 para calcular posicion de memoria
    add r1, r1, r5                ! r1 = nueva posicion en VRAM 
!psh a0, a1, s0, s1, o0, o1
!mov a0, r1                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
!psh a0, a1, s0, s1, o0, o1
!mov a0, r3                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    stw [r1], r3                  ! Guardar pixel en su nueva posicion

    bal nextcolumn

               
! sin(x) =  4x (180 - x) / [40500 - x (180 - x)]
! rr = sin(2*pi*a0/a1) = sin(x/L)
sin:
    psh lr, t0, t1
    mov t0, a0
    mov t1, a1
!imm a0, 's'                     ! print  \
!blk dbg_char                    ! se pierde a0, a1, s0, s1, o0, o1
    imm a0, 360
    mul a0, a0, t0               ! a0 = 360 * pos
    mov a1, t1                  ! setup args for divition
!psh a0, a1, s0, s1, o0, o1
!mov a0, a0                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
!psh a0, a1, s0, s1, o0, o1
!mov a0, a1                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    blk division                  ! o0 = a0/a1 ^ o1 = a0%a1
!psh a0, a1, s0, s1, o0, o1
!mov a0, o0                        ! print  \
!blk dbg_word                      ! se pierde a0, a1, s0, s1, o0, o1
!pop a0, a1, s0, s1, o0, o1
    imm s0, 180
    sub s0, s0, o0               ! r2 = (180 - x)
    mul s0, s0, o0               ! r2 = x (180 - x)
    imm s1, 40500
    sub a1, s1, s0               ! r4 = 40500 - x(180 - x)
    sli a0, s0, 10                ! r2 = [4x (180 - x)] << 8
    blk division                  ! div (r2<<8)/r4
    pop lr, t0, t1
    ret


! o0 = a0/a1
! o1 = a0%a1
division:
    psh lr, t0, t1, t2, t3, t5, t6
    mov t0, a0
    mov t1, a1
! imm a0, 'd'    ! print  \
! blk dbg_char   ! se pierde a0, a1, s0, s1, o0, o1
    mov s0, t0                      ! s0 = t0
    mov s1, zero                    ! s1 = 0
    bne s0, s1, divnezero           ! Si dividendo es cero => q = 0
    diveqzero:
        mov o0, zero            ! El cociente es cero
        mov o1, zero            ! El residuo es cero
        bal divdone
    divnezero:
    mov s0, t1                  ! s0 = t1
    beq s0, s1, diveqzero       ! Si el divisor es cero => ?
    mov s0, t0                  ! s0 = t0
    mov s1, t1                  ! s1 = t1
    blt s0, s1, divtriv         ! si t0 < t1, se hace division trivial

    mov s0, t0                    ! s0 = t0
    imm s1, 1                     ! constante s1 = 1 
    imm t2, 1                     ! Cantidad de bits
    beq s0, s1, logdone           ! Si ya es 1
    logloop:
! psh s0, s1     !
! imm a0, '6'    ! print  \
! blk dbg_char   ! se pierde a0, a1, s0, s1, o0, o1
! pop s0, s1     !
        sri s0, s0, 1             ! Shift right
        inc t2, 1                 ! Incrementar contador
        bne s0, s1, logloop       ! Verificar que no sea 1
    logdone:                      ! t2 = cantidad de bits
! psh s1         !
! imm a0, 'l'    ! print  \
! blk dbg_char   ! se pierde a0, a1, s0, s1, o0, o1
! pop s1         !
    mov s0, t2
    dec s0, 1                     ! s0 = cantidad de bits - 1

    mov a1, zero ! setup para \   ! a1 = 0
    mov a0, s0   ! comparar       ! a0 = s0
    generatemask:
        beq a0, a1, continuediv  
        sli s1, s1, 1             ! s1 << 1
        inc s1, 1                 ! Poner 1 en LSB
        dec a0, 1                 ! Decrementar el contador
        bal generatemask
    
continuediv:
    mov a0, t2
    mov a1, zero
    imm t6, 1
    imm o1, 0
    mov o0, t0

! Reservados: 
!  t0: dividendo
!  s0: n-1 (cantidad de bits - 1)
!  s1: máscara
!  a0: n (cantidad de bits)
!  a1: 0
!  t1: divisor
!  t6 = 1
!  o1 = 0
!  o0 = t0

divloop:
!psh a0, a1, s0, s1, s2, s3
!mov a0, o0
!blk dbg_word
!pop a0, a1, s0, s1, s2, s3
    beq a0, a1, divdone           ! si la cantidad de bits es 0, terminar
    dec a0, 1                     ! Decrementar contador
    shr t3, o0, s0                ! t3 = MSB de Q
    sli o1, o1, 1                 ! A << 1 (o1 = A) 
    orr o1, o1, t3                ! Colocar LSB de A
    sli o0, o0, 1                 ! Q << 1
    and o0, o0, s1                ! Aplicar máscara 
    mov t5, o1                    ! Guardar A en t5
    sub t5, t5, t1                ! t5 = A-M
    mov t3, t5                    ! Guardar nuevo A en t3
    and t5, t5, s1                ! Aplicar máscara
    shr t5, t5, s0                ! t5 = MSB de A
    beq t5, t6, divloop           ! Si t5 == 1, no hacer nada
    inc o0, 1                     ! Sino agregar 1 al final de Q
    mov o1, t3
    bal divloop

divtriv:
    mov o1, t0                  ! El residuo es el dividendo
    mov o0, zero                ! El cociente es cero

divdone:
    ! o0: Cociente
    ! o1: Residuo
! psh o0, o1     !
! imm a0, 'e'    ! print  \
! blk dbg_char   ! se pierde a0, a1, s0, s1, o0, o1
! pop o0, o1     !
    pop lr, t0, t1, t2, t3, t5, t6
    ret


! o0 = round(a0)
round:
    imm s0, 128               ! Máscara de bit 8
    add s1, r0, a0            ! s1 = r2
    and s1, s1, s0            ! Aplicar máscara a s1
    sri s1, s1, 7             ! Obtener bit 8
    imm s0, 1                 ! s0 = 1
    sri o0, a0, 8             ! Quitar decimales
    bne s0, s1, round_ready   ! Si el bit 8 es 0
    inc o0, 1 
round_ready:
    ret

dbg_word:
	psh lr, t1
	mov t1, a0
	imm a0, '0'
	blk dbg_char
	imm a0, 'x'
	blk dbg_char
	psh t0, t2
	imm t0, 28
	imm t2, 0b1111
dbg_word_loop:
	shr s0, t1, t0
	and s0, s0, t2
	imm a0, '0'
	imm s1, 10
	add a0, a0, s0
	blt s0, s1, dbg_word_digit
	imm a1, 39 ! 'a' - '0' - 10
	add a0, a0, a1
dbg_word_digit:
	blk dbg_char
	beq zero, t0, dbg_word_exit
	dec t0, 4
	bal dbg_word_loop
dbg_word_exit:
    pop lr, t1, t0, t2
    imm a0, '\n'
    bal dbg_char

dbg_char:
	imm s0, 0x30000000
	mov s1, s0
	inc s1, 4
	mov s2, zero
dbg_char_wait_tx:
	ldw s3, [s1]
	sri s3, s3, 16
	beq s2, s3, dbg_char_wait_tx
	stw [s0], a0
	ret
