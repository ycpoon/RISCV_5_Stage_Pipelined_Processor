        li      t0, 400      
        li      s1, 123
        sw      s1, 0(t0)      
        lw      s2, 0(t0)         
        or      s4, t0, s2      
        sw      s4, 0(s4)      
        lw      s5, 0(s4)      
        addi    s9, s5, 8      
        lw      s7, 0(s9)      
        xor     s7, s7, s7      
        bne     s7, t0, forw     
        add     a1, s7, s7      
        xor     a2, a1, s7      
forw:
        wfi