.text

.global main
main:
	push         %rbp
	movq         %rsp, %rbp
	subq         $32, %rsp
	andq         $-32, %rsp
	subq         $64, %rsp
	push         %rbx
	push         %r12

	cmpl         $4, %edi
	jne          .usage
	movq         24(%rsi), %r12
	movq         8(%rsi), %rax
	movq         %rax, -16(%rbp)
	leaq         -8(%rbp), %rbx

	movq         16(%rsi), %rdi
	cmpb         $0, (%rdi)
	je           .usage
	movq         %rbx, %rsi
	xorl         %edx, %edx
	call         strtoul
	movq         (%rbx), %rcx
	cmpb         $0, (%rcx)
	jne          .usage
	cmpl         $256, %eax
	jb           .usage
	cmpl         $(1 << 16), %eax
	jae          .usage
	movl         %eax, -28(%rbp)

	movq         %r12, %rdi
	movq         %rbx, %rsi
	xorl         %edx, %edx
	call         strtoul
	movq         (%rbx), %rcx
	cmpb         $0, (%rcx)
	jne          .usage
	cmpl         $1, %eax
	jbe          .usage
	cmpl         $(1 << 16), %eax
	jae          .usage
	movl         %eax, -32(%rbp)

	movq         -16(%rbp), %rdi
	movq         %rbx, %rsi
	xorl         %edx, %edx
	call         strtoul
	movq         (%rbx), %rcx
	cmpb         $0, (%rcx)
	jne          .usage
	testl        $15, %eax
	jnz          .bad_size
	movl         %eax, %r12d
	shll         $2, %r12d

	xorl         %edi, %edi
	shrl         $(5 - 2), %eax
	addl         $1, %eax
	movl         %eax, %esi
	movl         $32, %edx
	call         reallocarray
	leaq         reallocarray_fn, %rdi
	testq        %rax, %rax
	jz           .exit_perror
	movq         %rax, -16(%rbp)
	addq         $31, %rax
	andq         $-32, %rax
	movq         %rax, %rbx
	movq         %rax, -8(%rbp)

	addq         %rax, %r12
.load_buf:
	leaq         scanf_format(%rip), %rdi
	leaq         1(%rbx), %rsi
	movq         %rbx, %rdx
	leaq         5(%rbx), %rcx
	leaq         4(%rbx), %r8
	xorl         %eax, %eax
	call         scanf
	cmpl         $4, %eax
	jne          .bad_load
	addq         $8, %rbx
	cmpq         %r12, %rbx
	jb           .load_buf

	movl         $((1 << (16 + 2 - 5)) + 1), %edi
	movl         $32, %esi
	call         calloc
	leaq         calloc_fn, %rdi
	testq        %rax, %rax
	jz           .exit_perror
	movq         %rax, -24(%rbp)
	addq         $31, %rax
	andq         $-32, %rax
	movq         %rax, %rbx

	movl         -28(%rbp), %esi
	movl         %esi, 16(%rsp)
	bsrl         %esi, %ecx
	movl         $1, %edi
	shll         %cl, %edi
	addl         %esi, %edi
	subl         $1, %edi
	bsrl         %edi, %edi
	testb        %dil, %dil
	setnz        %al
	movzbl       %al, %eax
	movl         %eax, 32(%rsp)
	movl         %edi, %ecx
	subl         %eax, %ecx
	movl         %ecx, 24(%rsp)
	movl         $1, %edx
	movb         %dil, %cl
	shll         %cl, %edx
	subl         %esi, %edx
	xorl         %eax, %eax
	divl         %esi
	addl         $1, %eax
	movl         %eax, 40(%rsp)

	movq         %rbx, %rax
	movq         -8(%rbp), %rbx
	vpxor        %ymm5, %ymm5, %ymm5
	movl         $1, 48(%rsp)
	vpbroadcastd 48(%rsp), %ymm8
	vpbroadcastd 40(%rsp), %ymm9
	vpbroadcastd 32(%rsp), %ymm10
	vpbroadcastd 24(%rsp), %ymm11
	vpbroadcastd 16(%rsp), %ymm12

.hot_loop:
	vmovdqa      (%rbx), %ymm0
	vmovdqa      32(%rbx), %ymm1
	vpcmpeqd     %ymm4, %ymm4, %ymm4
	vpgatherdd   %ymm4, (%rax, %ymm0, 4), %ymm2
	vpcmpeqd     %ymm4, %ymm4, %ymm4
	vpgatherdd   %ymm4, (%rax, %ymm1, 4), %ymm3
	vpcmpeqd     %ymm5, %ymm2, %ymm6
	vpcmpeqd     %ymm5, %ymm3, %ymm7
	vpor         %ymm6, %ymm7, %ymm6
	vptest       %ymm6, %ymm5
	jnc          .decrypt
.next_block:
	vmovdqa      %ymm2, (%rbx)
	vmovdqa      %ymm3, 32(%rbx)
	addq         $64, %rbx
	cmpq         %r12, %rbx
	jb           .hot_loop
	jmp          .done

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
	vmovdqa      %ymm8, %ymm2
	vmovdqa      %ymm8, %ymm3
	movl         -32(%rbp), %edx
.pow_mod:
	testl        $1, %edx
	jz           .skip_bit
	pow_kernel   %ymm2, %ymm3
.skip_bit:
	shrl         %edx
	jz           .end_block
	pow_kernel   %ymm0, %ymm1
	jmp          .pow_mod

.end_block:
	vmovdqa      %ymm2, 16(%rsp)
	vmovdqa      %ymm3, 48(%rsp)
	leaq         16(%rsp), %rsi
	movl         $60, %edx
.map_ciphertext:
	movl         (%rsi, %rdx), %r8d
	movl         (%rbx, %rdx), %r9d
	movl         %r8d, (%rax, %r9, 4)
	subl         $4, %edx
	jae          .map_ciphertext
	vpxor        %ymm5, %ymm5, %ymm5
	jmp          .next_block

.done:
	vzeroall

	movq         -8(%rbp), %rbx
.output:
	movl         (%rbx), %edi
	cmpl         $256, %edi
	jae          .bad_decrypt
	andl         $0xff, %edi
	call         putchar
	addq         $4, %rbx
	cmpq         %r12, %rbx
	jb           .output

	movq         -16(%rbp), %rdi
	call         free
	movq         -24(%rbp), %rdi
	call         free
	pop          %r12
	pop          %rbx
	xorl         %eax, %eax
	leave
	ret

.exit_perror:
	call         perror
	jmp          .exit_fail
.bad_size:
	leaq         bad_size_msg(%rip), %rdi
	jmp          .exit_stderr
.bad_load:
	leaq         bad_load_msg(%rip), %rdi
	jmp          .exit_stderr
.bad_decrypt:
	leaq         bad_decrypt_msg(%rip), %rdi
	jmp          .exit_stderr
.usage:
	leaq         usage_msg(%rip), %rdi
.exit_stderr:
	movq         stderr(%rip), %rsi
	call         fputs
.exit_fail:
	movl         $1, %edi
	jmp          exit

.section .rodata
scanf_format:
	.asciz " %hhu %hhu %hhu %hhu"
bad_size_msg:
	.asciz "Error: plaintext length must be a multiple of 16 bytes\n"
bad_load_msg:
	.asciz "Error: failed to load ciphertext: premature EOF, bad format, or I/O error\n"
bad_decrypt_msg:
	.asciz "Error: failed to decrypt (bad params?)\n"
usage_msg:
	.asciz "usage: img-decrypt <len> <n> <d> <CIPHERTEXT >PLAINTEXT\n\tlen: plaintext length\n\tn:   RSA modulus, 255 < n < 65536\n\td:   RSA private exponent, 1 < d < 65536\n"
reallocarray_fn:
	.asciz "reallocarray()"
calloc_fn:
	.asciz "calloc()"
