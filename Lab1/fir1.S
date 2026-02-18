# fir.S 
# assembly language of Finite Impulse Response (FIR)

// a0: base address of x
// a1: base address of c
// a2: base address of y, later used as pointer to y[j] in j loop
// a3: n
// a4: m

// t0: &y[n-m+1] to check termination of j loop
// t1: &c[m] to check termination of i loop
// t2: &x[j+m-1]
// t3: sum
// t4: pointer to c[i] in i loop
// t5: pointer to x[j-i+(m-1)] 
// t6: value of c[i]
// a5: value of x[j-1+(m-1)]

.global fir


# just for brain fir ( a0, a1, a2, a3, a4) === fir (int x[], int c[], int y[], int n, int m)

fir:

li t0, 0    # t0 is our i..... i=0
li t1, 0    # t1 is our j..... j=0

sub t2, a3, a4  # n-m
addi t3, t2, 1   # (n-m)+1

for:

	bge t1, t3, donej  # checks if J < (n-m+1) 
	slli t4, t1, 2    # t4 = j * 4
	add t5, a2, t4    #this makes &y[j], the location of y
	sw zero, 0(t5)	  # stores y[j] with 0
	
	j next_loop

next_loop:
	
	bge t0, a4, next_j # if i >= m go to next inner loop

	slli t6, t0, 2 #t6 = i*4
	add t6, a1, t6 #address of c[i]
	lw t6, 0(t6) #t6 = c[i]

    add a5, t1, t0 #a5 = j + i
	addi t8, a4, -1 #t8 = m - i
	add a5, a5, t8 #a5 = j + i + (m-1)

	slli a5, a5, 2 #a5 = a5 * 4 
	add a5, a0, a5 #a5 = x + a5
	lw a5, 0(a5) #store a5 with x[j-i+(m-1)]

	mul t8, a5, t6  # multiplys c[i] and x[j-i+(m-1)]
	add t9, t5, t8  # adds the product from above with y[j]
	sw t5, t9       # stores the sum above to y[j]

	add t0, t0, 1    # this does i++
	j next_loop #Runs this loop until i >= m in which case we have the next_j to take us back to the first loop

next_j:
	addi t1, t1, 1      # this does the j++
	j for
donej:
    ret                 # all done; return	
