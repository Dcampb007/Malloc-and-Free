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
	beq $v0, $t1, error_happened # Branch if sbrk didn't work
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
		sw $zero, 8($t0)    # end_metadata->next = NULL
		sw $t1, 4($t0)      # end_metadata->prev = new_node
		sw $t0, 8($t1)      # node->next = end_metadata
		add $t1, $t1, $s0   # get address of new_node->element
		or $v0, $t1, $zero  # put new_node->element into $v0
		jr $ra
	not_first:
		or $t1, $s1, $zero   # move head node address in $t1 (temp)
		while_loop:     # While current->next != NULL 
		lw $t2, 8($t1)        # load current->next*PTR
		beq $t2, $zero, found_end
		lw $t3, 16($t1)       # Load current->right-FreeSpace
		ori $t4, $zero, 24    # Put size of node in $t4
		bge $t3, $t4, space_available  # Branch if enough Space is available to add node (in between 2 nodes)
		or $t1, $t2, $zero    # Move next*PTR into $t1
		j while_loop
	space_available:
		sw $zero, 12($t1)     # Save 0 in current->right-FreeSpace
		addi $t1, $t1, 24     # Current = new Node
		addi $t2, $zero, 24   # Store 24 in $t2
		sw $t2, 0($t1)        # Save size in current->size
		la $t4, LAST_NODE     # Load address of Last Node
		sw $t4, 4($t1)        # Save Last Node address in current->previousPTR
		sw $zero, 8($t1)      # Save 0 (NULL) in current->nextPTR
		sw $zero, 12($t1)      # Save 0 in current->left-FreeSpace 
		sub $t3, $t3, $t2     # Subtract size of new node from current->right-FreeSpace (FS-24)
		sw $t3, 16($t1)       # Save FreeSpace in Current->right-FreeSpace (new node)
		or $v0, $t1, $zero    # Store Current& in $v0
		jr $ra                 
		
		
		
		
		
		
		
	found_end:
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
	# Accessing Left Free Space (bytes): node* ptr + 12
	# Accessing Right Free Space (bytes): node* ptr + 16
	# Accessing Number: node* ptr + 20
