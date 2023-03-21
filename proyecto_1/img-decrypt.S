//TODO: 640x480
#define PLAINTEXT_WIDTH  320
#define PLAINTEXT_HEIGHT 320
#define PLAINTEXT_SIZE   (PLAINTEXT_WIDTH * PLAINTEXT_HEIGHT)
#define CIPHERTEXT_SIZE  (PLAINTEXT_SIZE * 2)

.text

.global main
main:
	push  %rbp
	movq  %rsp, %rbp
	subq  $16, %rsp
	push  %rbx
	push  %r12

	movl  $CIPHERTEXT_SIZE, %edi
	call  malloc
	movq  %rax, %rbx
	movq  %rax, -8(%rbp)

	leaq  CIPHERTEXT_SIZE(%rbx), %r12
.load_buf:
	leaq  scanf_format(%rip), %rdi
	leaq  1(%rbx), %rsi
	movq  %rbx, %rdx
	leaq  3(%rbx), %rcx
	leaq  2(%rbx), %r8
	xorl  %eax, %eax
	call  scanf
	addq  $4, %rbx
	cmpq  %r12, %rbx
	jb    .load_buf
	movq  -8(%rbp), %rdi
	call  free

	pop   %r12
	pop   %rbx
	xorl  %eax, %eax
	leave
	ret

.section .rodata
scanf_format:
	.asciz " %hhu %hhu %hhu %hhu"
