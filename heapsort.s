# Lethal Interjection
# Gedare Bloom#
# heapsort.s
# An implementation of heapsort algorithm #
.data
# the array that holds unordered data
elements_prompt: .asciiz "Please enter how many elements you would like to be sorted:"
number_prompt: .asciiz "Please enter and integer"
SbrkSize: .word 50
MetadataSize: .word 12
HeadNode: .space 32
array: .word 54, 23, 56, 32, 99, 7, 4, 2, 88, 9, 11, 21, 39, 55, 100, 101, 43, 1, 3, 69, -5, -24, -17, 0 #24 numbers
size: .word 24
space: .asciiz " "
newline: .asciiz "\n"
.text
.globl main
main:
	# first prompt
	la $a0, elements_prompt
	addi $v0, $0, 4
	syscall
	# storing numelements
	addi $v0, $0, 5
	syscall
	addi $s0, $v0, 0 # store num elements as first argument for malloc
	addi $a0, $s0, 1 # extra element for null terminating 0
	addi $t2, $0, 4
	mul $a0, $a0, $t2 # multiply by four to get number of bytes necessary
	addi $a1, $0, 1 # 1 for first call to malloc
	# call to malloc
	addi $sp, $sp, -4
	sw $ra, 0($sp) # save return address on stack
	jal Malloc
	lw $ra, 0($sp) # restore return address in $ra
	addi $sp, $sp, 4 # restore stack
	addi $t0, $v0, 0 # store array pointer at t0
	# loop for elements and store
	addi $t1, $t1, 0 # counter
	addi $t3, $t0, 0 # address counter
storeloop:
	slt $t2, $t1, $s0
	beq $t2, $0, endstoreloop
	#prompt
	la $a0, number_prompt # prompt for number
	addi $v0, $0, 4
	syscall
	addi $v0, $0, 5 # read interger
	syscall
	sw $v0, 0($t3)
	addi $t3, $t3, 4 # update t4 to next location
	addi $t1, $t1, 1
	j storeloop
endstoreloop:
	#add the null terminating 0
	sw $0, 0($t3)
	addi $sp, $sp, -4
	sw $ra, 0($sp) # save return address on stack
	addi $a0, $v0, 0
    addi $a1, $s0, 0
    jal heapsort
	lw $ra, 0($sp) # restore return address in $ra
	addi $sp, $sp, 4 # restore stack
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

  Malloc:
    # start_metadata = $t1, end_metadata = $t2, $a0 contains user_size, $a1 contains first sbrk flag
    	ble $a0, $zero, bad_size_or_sbrk_failed
  	la $s0, MetadataSize   # Load MetadataSize
  	lw $s0, 0($s0)         # Load actual MetadataSize in $s0
  	la $s1, HeadNode       # Load HeadNode
  	la $s2, SbrkSize       # Load SbrkSize
  	lw $s2, 0($s2)
  	beq $a1, $zero, not_first  # $a1 is the flag for the first call to malloc
  	or $a1, $zero, $zero   # Reset a1 to zero (NO LONGER FIRST CALL)
  	or $t0, $a0, $zero     # store user_size in a temp register
  	lw $t1, 0($s2)         # load integer into $t1 (50) from SbrkSize
  	mul $a0,$t1,$a0        # Multiply user_size * SbrkSize
  	or $t6, $a0, $zero     # put user_size * SbrkSize in $t6
  	li $v0, 9              # allocate memory for heap
  	syscall
  	ble $v0, $zero, bad_size_or_sbrk_failed # Branch if sbrk didn't work
  	or $a0, $t0, $zero     # Put user_size back into $a0
  	or $t1, $v0, $zero     # Put start_metadata node address in $t1
  	sw $t1, 0($s1)         # Save node into HeadNode memory location
  	sw $zero, 0($t1)       # Save 0 in start_metadata->size
  	sw $zero, 4($t1)       # node->prev = NULL
  	add $t2, $t1, $s0      # new_node = start_metadata + 12
  	sw $t2, 8($t1)         # start_metadata->next = new_node
  	sw $t1, 4($t2)         # new_node->prev = start_metadata
  	sw $a0, 0($t2)         # new_node->size = user_size
  	add $t0, $t1, $t6      # add start_metadata + user_size * SbrkSize
  	sub $t0, $t0, $s0      # end_metadata = start_metadata + (user_size * SbrkSize) - METADATASIZE
  	or $t1, $t2, $zero     # move new_node into $t1
  	add_end_metadata:
  		nor $t2, $zero, $zero # put -1 in $t2
  		sw $t2, 0($t0)      # end_metadata->size = -1
  		sw $t1, 4($t0)      # end_metadata->prev = new_node
  		sw $zero, 8($t0)    # end_metadata->next = NULL
  		sw $t0, 8($t1)      # node->next = end_metadata
  		add $t1, $t1, $s0   # get address of new_node->element
  		or $v0, $t1, $zero  # put new_node->element into $v0
  		jr $ra
  	not_first:
  		la $t1, HeadNode     # Load first start_metadata into $t1 (temp)
  		while_loop:     # While current->next != NULL
  		lw $t2, 8($t1)        # load current->next*PTR
  		beq $t2, $zero, make_sbreak
  		lw $t3, 0($t1)        # load current->size into $t3
  		add $t4, $t3, $t1     # $t4 = current->size + &(current)
  		add $t4, $t4, $s0     # $t4 = $t4 + METADATASIZE
  		sub $t4, $t2, $t3     # $t4 = current->next - $t4
  		add $t5, $a0, $s0     # $t5 = user_size + METADATASIZE
  		bge $t4, $t5, space_available  # Branch if enough Space is available to add node (in between 2 nodes)
  		or $t1, $t2, $zero    # Move next*PTR into $t1
  		j while_loop
  	space_available:
  		add $t4, $t1, $t3     # $t4 = &(current) + current->size
  		add $t4, $t4, $s0     # new_node = &(current) + current->size + METADATASIZE
  		sw $a0, 0($t4)        # new_node->size = $a0
  		sw $t2, 8($t4)        # save new_node->next = current->next
  		sw $t4, 4($t2)        # Save current->next->prev = new_node
  		sw $t1, 4($t4)        # new_node->prev = current
  		sw $t4, 8($t1)        # current->next = new_node
  		add $v0, $t4, $s0     # $v0 = new_node->&(element)
  		jr $ra


  	make_sbreak:
  		# $t1 = temp, $t2 = temp->next
  		or $t0, $a0, $zero    # $t0 = user_size
  		mul $a0, $a0, $s2     # $a0 = user_size * SbrkSize
  		or $t6, $a0, $zero    # $t6 = user_size * SbrkSize
  		li $v0, 9             # Load sbrk code
  		syscall
  		ble $v0, $zero, bad_size_or_sbrk_failed
  		or $t4, $v0, $zero    # Load new sbrk address into $t4 (start_metadata)
  		sw $zero, 0($t4)      # start_metadata->size = 0
  		sw $t1, 4($t4)        # start_metadata->prev = temp
  		or $t5, $t4, $s0      # new_node = &(start_metadata) + 12
  		sw $t5, 8($t4)        # start_metadata->next = new_node
  		or $a0, $t0, $zero    # $a0 = user_size
  		sw $a0, 0($t5)        # new_node->size = user_size
  		sw $t4, 4($t5)        # new_node->prev = start_metadata
  		sw $t4, 8($t1)        # temp->next = start_metadata
  		add $t0, $t4, $t6     # add start_metadata + (user_size *SbrkSize)
  		sub $t0, $t0, $s0     # end_metadata = [start_metadata + (user_size *SbrkSize)] - METADATASIZE
  		or $t1, $t5, $zero    # $t1 = new_node
  		j add_end_metadata

  bad_size_or_sbrk_failed:
  	or $v0, $zero, $zero      # Load zero into return register
  	jr $ra
