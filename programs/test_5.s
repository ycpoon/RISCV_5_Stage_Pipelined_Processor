        li      s2, 21
        li      s1, 40
        sw      s2, 0(s1)
        lw      s6, 0(s1)
        beq     s6, s6, here
        addi    s6, s6, 1
        addi    s6, s6, 2
        addi    s6, s6, 3
here:
        addi    s6, s6, 1
        addi    s6, s6, 2
        addi    s6, s6, 3
        wfi
