.data 
SbrkSize: .word 50
MetadataSize: .word 12
HeadNode: .space 32
.text
Malloc:
  # start_metadata = $t1, end_metadata = $t2, 
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
	li $v0, 9              # allocate memory for heap
	syscall 
	nor $t2, $zero, $zero   # put -1 in $t2
	beq $v0, $t2, error_happened # Branch if sbrk didn't work
	or $a0, $t0, $zero     # Put user_size back into $a0
	or $t1, $v0, $zero     # Put start_metadata node address in $t1
	sw $t1, 0($s1)         # Save node into HeadNode memory location
	sw $zero, 0($t1)       # Save 0 in start_metadata->size 
	sw $zero, 4($t1)       # node->prev = NULL
	add $t2, $t1, $s0      # new_node = start_metadata + 12
	sw $t2, 8($t1)         # start_metadata->next = new_node
	sw $t1, 4($t2)         # new_node->prev = start_metadata
	sw $a0, 0($t2)         # new_node->size = user_size
	add $t0, $t1, $a0      # add start_metadata + $a0
	sub $t0, $t0, $s0      # end_metadata = start_metadata + $a0 - METADATASIZE
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
		
	error_happened:           
		
	make_sbreak:
		addi $t3, $t1, 20     # Next node start address
		sw $t3, 8($t1)        # Save Next Node address in nextPTR
		sw $t4, 0($t3)        # Save new Node's size in first 4 bytes of node
		sw $t1, 4($t3)        # Save Current Node address in Prev*PTR of next node
		sw $zero, 8($t3)      # Make Next*PTR of the new Node  = NULL
		sw $a0, 12($t3)       # Save [number] in Number of Node 
	
		

# Accessing Node data members:
	# Accessing node size: node*ptr + 0
	# Accessing previousPTR: node* ptr + 4 
	# Accessing nextPTR: node* ptr + 8
	# Accessing element: node* ptr + 12

