# fir.S
# Assembly language implementation of FIR filter

# a0: base address of x[]
# a1: base address of c[]
# a2: base address of y[]
# a3: n
# a4: m

# t0: i (inner loop counter)
# t1: j (outer loop counter)
# t2: loop limit (n - m + 1)
# t3: temporary (offset / c[i] / y[j])
# t4: pointer to y[j]
# t5: index / x value / product
# t6: temporary for (m - 1)

.global fir

fir:

    li   t1, 0 # j = 0

    sub  t2, a3, a4 # t2 = n - m
    addi t2, t2, 1# t2 = n - m + 1  (outer loop limit)

outer_loop:
    bge  t1, t2, donej# if j >= limit → exit

    # Compute &y[j]
    slli t3, t1, 2  # t3 = j * 4
    add t4, a2, t3 # t4 = &y[j]
    sw zero, 0(t4) # y[j] = 0

    li t0, 0 # i = 0

inner_loop:
    bge t0, a4, next_j # if i >= m → exit inner loop

    # Load c[i]
    slli t3, t0, 2 # t3 = i * 4
    add t3, a1, t3 # &c[i]
    lw t3, 0(t3) # t3 = c[i]

    # Compute index = j - i + (m - 1)
    sub t5, t1, t0  # t5 = j - i
    addi t6, a4, -1  # t6 = m - 1
    add t5, t5, t6  # t5 = j - i + (m - 1)

    # Load x[index]
    slli t5, t5, 2 # index * 4
    add t5, a0, t5 # &x[index]
    lw t5, 0(t5) # t5 = x[j - i + (m - 1)]

    # Q1.31 Multiply: (c[i] * x[index]) >> 31
    mul t5, t5, t3  # 32-bit multiply
    srai t5, t5, 31  # arithmetic shift right by 31

    # Accumulate into y[j]
    lw t3, 0(t4)  # load current y[j]
    add t3, t3, t5  # y[j] += product
    sw t3, 0(t4) # store updated y[j]

    addi t0, t0, 1 # i++
    j    inner_loop

next_j:
    addi t1, t1, 1             # j++
    j    outer_loop

donej:
    ret
