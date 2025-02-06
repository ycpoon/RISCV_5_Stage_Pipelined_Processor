        li      t0, 321
        li      s1, 800
        li      s2, 21
        sw      s2, 0(s1)
        lw      s3, 0(s1)
        addi    s4, t0, 19
        lh      s6, 0(s1)
        addi    s6, s6, 1
        lbu     s8, 2(s1)
        sb      s8, 0(s1)
        jal     t2, skip
skip:
        jal     t3, end
end:
        wfi