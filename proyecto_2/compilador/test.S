! hello world
bal julian 
ext 0x1
mul r4, r7
bin r15
soto:
sys 1
imm r6, 0x12345678
beq r6, r7, julian
blk julian
bne r6, r7, julian
blt r6, r7, julian
adr r5, soto
and r7, r6, r0
julian:
orr r7, r6, r0
xor r7, r6, r0
ret
ldw r5, [r6]
stw [r5], r6
shl r10, r11, r14
shr r10, r11, r14
sli r10, r4, 1
sri r10, r4, 31
add r4, r7, r14
sub r4, r7, r14
inc r9, 1
dec r9, 9
fabian:
bal fabian
