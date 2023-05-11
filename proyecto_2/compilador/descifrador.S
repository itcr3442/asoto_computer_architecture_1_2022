! Ejecutar con:
! ./obj/conspiracion/Vconspiracion obj/descifrakk.bin --no-tty --dump-regs --load=65536,obj/out_file --const=805699584,255 --cycles 0
!
! Donde out_file está en el repo viejo, image_processing/

reset:

! IO utilizado:
!  5 switches para la llave
!  1 switch de selección de algoritmo (xor o not)
!  1 botón de inicio

! Dirección inicial de lectura, contador y tamaño de la imagen
imm r1, 0x00010000
imm r11, 0x38000000
imm r7, 0x0
imm r8, 307200

init:
  ldw  r4, [r1]       ! Guarda en r4 el dato en la posición de memoria de start
  stw  [r11], r4      ! Vuelve a guardar en memoria ya modificado
  inc  r7, 1      	  ! Incrementa contador de tamaño de la imagen
  inc  r1, 4
  inc  r11, 4
  add  r9, r7, r0
  bne  r8, r9, init ! Compara contador con tamaño de la imagen 640 * 480

imm r1, 0x00010000
imm r11, 0x38000000
imm r7, 0x0

!Esperar botón
imm r2, 0x30050000
imm r3, 0x30060000 

idle:
  !ldr r5, [r2]  ! Lee valor del botón
  ldw r6, [r3]  ! Lee valores de los switches 
  !tst r5, #1    ! Si el botón de inicio es 1, se salta a start
  !beq idle

! Verificar el algoritmo seleccionado
! tst r6, #1    	! Si el valor es 1, se salta a xor, si es 0 a not
bal xor
  
! Recorrer la memoria desde 0x00010000 y hacer not al valor en cada posicion
! y volverlo a guardar
!not:
  !Procesar la mask
  !imm r0, 0x00ffffff
  !b loop

xor:
!Procesar la llave
	sli r5, r6, 8
	sli r10, r6, 16
	orr r13, r5, r10
	orr r9, r6, r13

loop:
  ldw  r4, [r1] 	! Guarda en r4 el dato en la posición de memoria de start
  xor  r4, r4, r9  	  ! Hace XOR entre r4 
  stw  [r1], r4       ! Vuelve a guardar en memoria ya modificado
  inc  r1, 4
  inc  r7, 1          ! Incrementa contador de tamaño de la imagen
  add  r14, r7, r0
  add  r15, r8, r0
  bne  r14, r15, loop ! Compara contador con tamaño de la imagen 640 * 480

!release:
!  ldr r5, [r2]  ! Lee valor del botón
!  tst r5, #1    ! Si el botón de inicio es 1, se salta a start
!  bne release

  bal reset
