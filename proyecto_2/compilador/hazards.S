imm r1, 70
imm r5, 4
imm r4, 3
sli r4, r4, 3

loop:
inc r5, 1
bne r4, r5, loop

imm r10, 10
bal .
