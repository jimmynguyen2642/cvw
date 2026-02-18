# fir.S
# Assembly language implementation of FIR filter

# a0: base address of x[]
# a1: base address of c[]
# a2: base address of y[]
# a3: n
# a4: m

# t0: i (inner loop counter)
# t1: j (outer loop counter)
# t2: temporary for n - m
# t3: loop limit (n - m + 1)
# t4: temporary offset for y[j]
# t5: pointer to y[j]
# t6: value of c[i]
# t7: temporary index computation
# t8: product
# t9: accumulator (y[j])

.global fir

fir:

    li t1, 0                  # j = 0 (outer loop counter)

    sub t2, a3, a4            # t2 = n - m
    addi t3, t2, 1            # t3 = n - m + 1 (outer loop limit)

outer_loop:
    bge t1, t3, donej         # if j >= (n-m+1) → exit outer loop

    # Compute address of y[j]
    slli t4, t1, 2            # t4 = j * 4 (byte offset)
    add  t5, a2, t4           # t5 = &y[j]

    sw   zero, 0(t5)          # y[j] = 0 (initialize accumulator)

    li t0, 0                  # i = 0 (reset inner loop counter)

inner_loop:
    bge t0, a4, next_j        # if i >= m → exit inner loop

    # Load c[i]
    slli t6, t0, 2            # t6 = i * 4
    add  t6, a1, t6           # address of c[i]
    lw   t6, 0(t6)            # t6 = c[i]

    # Compute index = j - i + (m - 1)
    sub  t7, t1, t0           # t7 = j - i
    addi t8, a4, -1           # t8 = m - 1
    add  t7, t7, t8           # t7 = j - i + (m - 1)

    # Load x[index]
    slli t7, t7, 2            # multiply index by 4 (byte offset)
    add  t7, a0, t7           # address of x[index]
    lw   t7, 0(t7)            # t7 = x[j - i + (m - 1)]

    # Multiply c[i] * x[index]
    mul  t8, t7, t6           # t8 = product (NOTE: not Q31 corrected yet)

    # Accumulate into y[j]
    lw   t9, 0(t5)            # load current y[j]
    add  t9, t9, t8           # y[j] += product
    sw   t9, 0(t5)            # store updated y[j]

    addi t0, t0, 1            # i++
    j inner_loop              # repeat inner loop

next_j:
    addi t1, t1, 1            # j++
    j outer_loop              # repeat outer loop

donej:
    ret                       # return from function
