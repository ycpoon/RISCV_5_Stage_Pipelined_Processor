        li      t0, 123
        li      s2, 45
        sw      s2, 128(zero)
loop:
        addi    t0, t0, -1
        bne     t0, s2, loop
        lw      t2, 128(zero)
        lw      zero, 128(zero)
        xor     s3, zero, zero
        andi    s5, zero, 123
        mulh    s7, s5, s5
        bne     zero, t2, final
        wfi
final:
        wfi