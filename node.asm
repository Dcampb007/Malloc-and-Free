.data

str: .asciiz "Enter the amount of elements"
insert_num: .asciiz " Enter a number thats non-zero." 
.text
main:
	la $a0, str   
	li $v0, 4
	syscall    # Output string message
	li $v0, 5
	syscall # Read in int
	or  $a0, $v0, $zero 
	ori $s0, $zero, 16
	mul $a0 $s0, $a0   # create enough space for x nodes plus 2 special (beginning and end)  
	li $v0, 9   # allocate memory 
	syscall
	or $s0, $v0, $zero   # Move root pointer to $s0
	add $s1, $a0, $s0    # Move end pointer to $s1 [MAYBE WRONG]
	la $a0, insert_num
	li $v0, 4
	syscall           # Output string
	li $v0, 5
	syscall           # read int
	or $a0, $v0, $zero  # Move number into argument register
	ori $a1, $zero, 1
	jal add_node
	
add_node:
	beq $a1, $zero, not_first  # $a1 is the flag for the first call to malloc
	or $a1, $zero, $zero   # Reset a1 to zero (NO LONGER FIRST CALL)
	or $t0, $zero, $s0     # Put starting memory address in $t0
	ori $t4, $zero, 18     # 
	sw $t4, 0($t0)       # Save [size] in first first 4 bytes of node
	sw $zero, 4($t0)     # Save [0] in Prev* PTR
	sw $zero, 8($t0)     # Save [0] in Next* PTR
	sw $a0, 12($t0)      # Save [number] in Number 
	j $ra
	not_first:
		move $t1, $s0, $zero   # move temp node address in $t1
		while_loop:
		lw $t2, 8($t1)        # load Next*PTR
		beq $t2, $zero, found_end
		or $t1, $t2, $zero    # Move Next*PTR into $t1
		j while_loop
	found_end:
		addi $t3, $t1, 18     # Next node start address
		sw $t3, 8($t1)        # Save Next Node address in Next* PTR
		sw $t4, 0($t3)        # Save new Node's size in first 4 bytes of node
		sw $t1, 4($t3)        # Save Current Node address in Prev*PTR of next node
		sw $zero, 8($t3)      # Make Next*PTR of the new Node  = NULL
		sw $a0, 12($t3)       # Save [number] in Number of Node 


# Accessing Node data members:
	# Accessing node size: node*ptr  
	# Accessing previousPTR: node* ptr + 4 
	# Accessing nextPTR: node* ptr + 8
	# Accessing Number: node* ptr + 12