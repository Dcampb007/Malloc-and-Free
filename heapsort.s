# Andre Campbell 
# Gedare Bloom#
# heapsort.s
# An implementation of heapsort algorithm #
.data
# the array that holds unordered data
array: .word 54, 23, 56, 32, 99, 7, 4, 2, 88, 9, 11, 21, 39, 55, 100, 101, 43, 1, 3, 69, -5, -24, -17, 0
size: .word 24
space: .asciiz " "
newline: .asciiz "\n"
.text
.globl main
main:
	addi $sp, $sp, -4
	sw $ra, 0($sp) # save return address on stack
	la $a0, array	# a0 = &array
    la $t0, size
    lw $a1, 0($t0) # a1 = size(array)
    jal heapsort
    move $t0, $a0  # print the array
    add $t1, $zero, $zero
	printloop:
	    li $v0, 1
	    lw $a0, 0($t0)
	    addi $t0, $t0, 4
	    addi $t1, $t1, 1
	    syscall
	    li $v0, 4
	    la $a0, space 
	    syscall  
	    bne $t1, $a1, printloop	# while( t1 != size )
	    li $v0, 4
	    la $a0, newline
	    syscall
	done:
	    lw $ra, 0($sp) # restore return address in $ra
	    addi $sp, $sp, 4 # restore stack
	    jr $ra
heapsort: # a0 = &array, a1 = size(array)
    addi $sp, $sp, -12  # was -8, 
    sw $a1, 0($sp)  # save size
    sw $a2, 4($sp)  # save a2
    sw $ra, 8($sp)  # save return address
    move $a2, $a1  # n will be stored in a2
    addi $a2, $a2, -1    # n = size - 1
    ble $a2,$zero, end_heapsort  # if (n <= 0 ) return;
    jal make_heap  # a0 = arr, a1 = size
	heapsort_loop:
	    # swap(array[0],array[n])
	    lw $t0, 0($a0)
	    sll $t1, $a2, 2  #t1 = bytes(n)
	    add $t1, $t1, $a0
	    lw $t2, 0($t1)
	    sw $t0, 0($t1)   # array[n] = array[0]
	    sw $t2, 0($a0)   # array[0] = array[n]
	    addi $a2, $a2, -1 # n--
	    add $a1, $zero, $zero # clear $a1
	    jal bubble_down  # a0 = &array, a1 = 0, a2 = n
	    bnez $a2, heapsort_loop
	end_heapsort:
	    lw $ra, 8($sp)
	    lw $a2, 4($sp)
	    lw $a1, 0($sp)
	    addi $sp, $sp, 12  # was 8, but changed to 12
	    jr $ra
make_heap: # a0 = &array, a1 = size
	addi $sp, $sp, -12
	sw $a1, 0($sp)
	sw $a2, 4($sp)
	sw $ra, 8($sp)
	addi $a2, $a1, -1  # a2 = size - 1
  	ori $t0, $zero, 2   # put 2 in a register
  	div $a1,$a1,$t0    # start_index = (size) / 2 (quotient in $a1)
  	addi $a1, $a1, -1  # start_index = start_index - 1
	blt $a1, $zero, end_make_heap  # if(start_index < 0) return
	make_heap_loop:
		jal bubble_down # a0 = &array, a1 = start_index, a2 = n (size- 1)
		addi $a1, $a1, -1
		bge $a1, $zero, make_heap_loop  # branch if $a1 >= 0
	end_make_heap:
		lw $ra, 8($sp)
		lw $a2, 4($sp)
		lw $a1, 0($sp)
		addi $sp, $sp, 12
		jr $ra
	#bubble_down is a leaf in the call graph
bubble_down: # a0 = &array, a1 = start_index, a2 = end_index    #ra = make_heap_loop
	move $t0, $a1  # parent = start_index
	sll $t1, $t0, 1  # child = (parent * 2) + 1
	addi $t1, $t1, 1
	bgt $t1, $a2, end_bubble_down   # branch if child > end
	bubble_down_loop:
		#if ( end >= child + 1 && arr[child+1] > arr[child] )
		addi $t4, $t1, 1         # t4 = child + 1
		blt $a2, $t4, skipinc    # branch if end < child +1   
		sll $t3, $t1, 2  # get bytes(child)  left child
		add $t3, $t3, $a0                     
		lw $t3, 0($t3)  # t3 = arr[child]
		sll $t4, $t1, 2 #get bytes(child)   right child
		addi $t4, $t4, 4 #t4 = bytes(child+1)  
		add $t4, $t4, $a0
		lw $t4, 0($t4)  #t4 = arr[child+1]
		ble $t4, $t3, skipinc   # branch if array[child+1]  is <= array[child]
		addi $t1, $t1, 1  # child++
		skipinc:
		    sll $t3, $t0, 2  # get bytes(parent)  
		    add $t3, $t3, $a0
		    lw $t4, 0($t3)  #t4 = arr[parent], t3 = &arr[parent]
		    sll $t5, $t1, 2  # get bytes(child)
		    add $t5, $t5, $a0
		    lw $t6, 0($t5)  #t6 = arr[child], t5 = &arr[child]
		    ble $t6, $t4, increment_parent_child   # branch if array[child] <= array[parent]
		    # swap(arr[parent],arr[child]
		    # note: t4 = arr[parent], t6 = arr[child], t3 = &arr[parent], t5 = &arr[child]
		    sw $t4, 0($t5)
		    sw $t6, 0($t3)
		  	increment_parent_child:
		    move $t0, $t1  # parent = child
		    sll $t1, $t0, 1  # child = parent*2+1
		    addi $t1, $t1, 1
		    ble $t1, $a2, bubble_down_loop   # branch if child <= end
	end_bubble_down:
	  jr $ra   # make_heap_loop