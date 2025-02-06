        li      t0, 5
        li      t1, 10
        add     t2, t0, t1     # Data dependency (forwarding)
        sub     t3, t2, t0     # Uses t2 immediately
        sw      t3, 0(zero)    # Structural hazard (memory access)
        lw      t4, 0(zero)    # Load-use hazard
        addi    t5, t4, 1      # Depends on lw
        beq     t5, t3, branch # Control hazard
        mul     t0, t1, t2     # Structural hazard (ALU)
        xor     t1, t0, t3     # Forwarding check
branch:
        bne     t1, t0, end    # Control hazard
        wfi
end:
        wfi
