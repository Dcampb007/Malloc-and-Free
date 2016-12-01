.data

str: .asciiz "Enter the amount of elements"
insert_num: .asciiz " Enter a number thats non-zero." 
LAST_NODE: .space 20
.text
main:
	la $a0, str   
	li $v0, 4
	syscall    # Output string message
	li $v0, 5
	syscall # Read in int
	or  $a0, $v0, $zero 
	ori $s0, $zero, 20
	mul $a0 $s0, $a0   # create enough space for x nodes plus 2 special (beginning and end)  
	li $v0, 9   # allocate memory 
	syscall
	or $s0, $v0, $zero   # Move root pointer to $s0
	add $s1, $a0, $s0    # Move end pointer to $s1 [MAYBE WRONG]
	or $s1, $a0, $zero   # Move space in s1
	la $a0, insert_num
	li $v0, 4
	syscall           # Output string
	li $v0, 5
	syscall           # read int
	#or $a0, $v0, $zero  # Move number into argument register
	or $a0, $s1, $zero   # Move space back into a0
	ori $a1, $zero, 1
	jal add_node
	
add_node:
	beq $a1, $zero, not_first  # $a1 is the flag for the first call to malloc
	or $a1, $zero, $zero   # Reset a1 to zero (NO LONGER FIRST CALL)
	or $t0, $zero, $s0     # Put starting memory address in $t0
	ori $t4, $zero, 24     # 
	sw $t4, 0($t0)       # Save [size] in first first 4 bytes of node
	sw $zero, 4($t0)     # Save [0] in Prev* PTR
	sw $zero, 8($t0)     # Save [0] in Next* PTR
	subi $t1, $a0, 24    # Subtract full size of node from sbrk size
	sw $zero, 12($t0)     # Store 0 in head->left-FreeSpace(bytes)
	sw $t1, 16($t0)       # Store free space in head->Right-FreeSpace (bytes)
	#sw $a0, 16($t0)      # Save [number] in Number 
	or $v0, $t0, $zero    # Store address of node in $v0
	la $t1, LAST_NODE     # Load address of the last node in LL
	or $v0, $t1, $zero           # Save the pointer to the last node in the space in memory for the last node
	jr $ra
	not_first:
		or $t1, $s0, $zero   # move head node address in $t1 (temp)
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
