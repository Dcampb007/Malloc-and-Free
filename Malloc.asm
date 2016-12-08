.data
SbrkSize: .word 50
MetadataSize: .word 12
HeadNode: .space 32
.text
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
  	or $t1, $s2, $zero     # Move $s2 into t1
  	mul $a0,$t1,$a0        # Multiply user_size * SbrkSize
  	or $t6, $a0, $zero     # put user_size * SbrkSize in $t6
  	li $v0, 9              # allocate memory for heap
  	syscall
  	ble $v0, $zero, bad_size_or_sbrk_failed # Branch if sbrk didn't work
  	or $a0, $t0, $zero     # Put user_size back into $a0
  	or $t1, $v0, $zero     # Put start_metadata node address in $t1
  	or $s1, $t1, $zero     # put $t1 into HeadNode
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


# Accessing Node data members:
	# Accessing node size: node*ptr + 0
	# Accessing previousPTR: node* ptr + 4
	# Accessing nextPTR: node* ptr + 8
	# Accessing element: node* ptr + 12
