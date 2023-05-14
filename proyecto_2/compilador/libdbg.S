! Recordar inicializar stack pointer
imm sp, 0x1000

! Modo de uso
imm a0, 0x12ab56cd
blk dbg_word
imm a0, '\n'
blk dbg_char
hlt

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
	ret

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
