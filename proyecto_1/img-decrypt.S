//TODO: 640x480
#define PLAINTEXT_WIDTH  320
#define PLAINTEXT_HEIGHT 320
#define PLAINTEXT_SIZE   (PLAINTEXT_WIDTH * PLAINTEXT_HEIGHT)
#define CIPHERTEXT_SIZE  (PLAINTEXT_SIZE * 2)
#define bUFFER_SIZE      (PLAINTEXT_SIZE * 4)

.text

.global main
main:
	push  %rbp
	movq  %rsp, %rbp
	subq  $8, %rsp
	andq  $-32, %rsp
	push  %rbx
	push  %r12

	movl  $((BUFFER_SIZE >> 5) + 1), %edi
	movl  $32, %esi
	call  calloc
	movq  %rax, -8(%rbp)
	addq  $32, %rax
	andq  $-32, %rax
	movq  %rax, %rbx

	leaq  CIPHERTEXT_SIZE(%rbx), %r12
.load_buf:
	leaq  scanf_format(%rip), %rdi
	leaq  1(%rbx), %rsi
	movq  %rbx, %rdx
	leaq  5(%rbx), %rcx
	leaq  4(%rbx), %r8
	xorl  %eax, %eax
	call  scanf
	addq  $8, %rbx
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
