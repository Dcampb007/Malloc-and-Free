.data
.text
main:
    jal free
    jr $ra
free:
    beq $a0, $0, nullptr
#else
    #store address of start of node meta in t0
    addi $t0, $a0, -12 #a0 stores argument pointer to be freed
    addi $t1, $t0, 4 #previous address is stored here
    addi $t2, $t0, 8 #next address is stored here
    lw $t3, 0($t1)   #previous node
    lw $t4, 0($t2)   #next node
    addi $t3, $t3, 8 #location of previous node next
    sw $t4, 0($t3) #update previous node next to current node next
    addi $t4, $t4, 4 #location of next node previous
    addi $t3, $t3, -8 #restore location of previous node next to previous node
    sw $t3 ,0($t4) #store location of current node previous to next node previous
nullptr:
    jr $ra

#Potential Optimization
#For phase two of testing
#addi $t0, $a0, -12 # current node
#lw $t3, 4($t0)   #previous node
#lw $t4, 8($t0)   #next node
#sw $t4, 8($t3)  #store current next node in previous node -> next
#sw $t3, 4($t4)   #previous node
