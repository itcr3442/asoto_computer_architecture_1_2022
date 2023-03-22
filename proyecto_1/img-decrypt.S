//TODO: 640x480
#define PLAINTEXT_WIDTH  320
#define PLAINTEXT_HEIGHT 320
#define PLAINTEXT_SIZE   (PLAINTEXT_WIDTH * PLAINTEXT_HEIGHT)
#define CIPHERTEXT_SIZE  (PLAINTEXT_SIZE * 2)
#define BUFFER_SIZE      (PLAINTEXT_SIZE * 4)

.text

.global main
main:
	push  %rbp
	movq  %rsp, %rbp
	subq  $16, %rsp
	andq  $-32, %rsp
	subq  $48, %rsp
	push  %rbx
	push  %r12

	movl  $((BUFFER_SIZE >> 5) + 1), %edi
	movl  $32, %esi
	call  calloc
	movq  %rax, -16(%rbp)
	addq  $32, %rax
	andq  $-32, %rax
	movq  %rax, %rbx
	movq  %rax, -8(%rbp)

	leaq  BUFFER_SIZE(%rbx), %r12
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

	movq         -8(%rbp), %rbx
	movl         $1, 48(%rsp)
	movl         $1605480816, 40(%rsp)
	movl         $1, 32(%rsp)
	movl         $12, 24(%rsp)
	movl         $5963, 16(%rsp)
	vpbroadcastd 48(%rsp), %ymm8
	vpbroadcastd 40(%rsp), %ymm9
	vpbroadcastd 32(%rsp), %ymm10
	vpbroadcastd 24(%rsp), %ymm11
	vpbroadcastd 16(%rsp), %ymm12

.macro pow_kernel ymma, ymmb
	vpmulld      %ymm0, \ymma, \ymma
	vpmulld      %ymm1, \ymmb, \ymmb
	vpmuludq     %ymm9, \ymma, %ymm6
	vpmuludq     %ymm9, \ymmb, %ymm7
	vpsrlq       $32, \ymma, %ymm4
	vpsrlq       $32, \ymmb, %ymm5
	vpsrlq       $32, %ymm6, %ymm6
	vpsrlq       $32, %ymm7, %ymm7
	vpmuludq     %ymm9, %ymm4, %ymm4
	vpmuludq     %ymm9, %ymm5, %ymm5
	vpblendd     $0b10101010, %ymm4, %ymm6, %ymm4
	vpblendd     $0b10101010, %ymm5, %ymm7, %ymm5
	vpsubd       %ymm4, \ymma, %ymm6
	vpsubd       %ymm5, \ymmb, %ymm7
	vpsrlvd      %ymm10, %ymm6, %ymm6
	vpsrlvd      %ymm10, %ymm7, %ymm7
	vpaddd       %ymm4, %ymm6, %ymm4
	vpaddd       %ymm5, %ymm7, %ymm5
	vpsrlvd      %ymm11, %ymm4, %ymm4
	vpsrlvd      %ymm11, %ymm5, %ymm5
	vpmulld      %ymm4, %ymm12, %ymm4
	vpmulld      %ymm5, %ymm12, %ymm5
	vpsubd       %ymm4, \ymma, \ymma
	vpsubd       %ymm5, \ymmb, \ymmb
.endm

.decrypt:
	vmovdqa      (%rbx), %ymm0
	vmovdqa      32(%rbx), %ymm1
	vmovdqa      %ymm8, %ymm2
	vmovdqa      %ymm8, %ymm3
	movl         $1631, %edx # d
.pow_mod:
	testl        $1, %edx
	jz           .skip_bit
	pow_kernel   %ymm2, %ymm3
.skip_bit:
	shrl         %edx
	jz           .next_block
	pow_kernel   %ymm0, %ymm1
	jmp          .pow_mod
.next_block:
	vmovdqa      %ymm2, (%rbx)
	vmovdqa      %ymm3, 32(%rbx)
	addq         $64, %rbx
	cmpq         %r12, %rbx
	jb           .decrypt
	jmp          .done

.done:
	vzeroall

	movq  -16(%rbp), %rdi
	call  free

	pop   %r12
	pop   %rbx
	xorl  %eax, %eax
	leave
	ret

.section .rodata
scanf_format:
	.asciz " %hhu %hhu %hhu %hhu"
