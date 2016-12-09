.data
.text
main:
    jal free
    jr $ra
free:
    beq $a0, $0, nullptr
#else
    #store address of start of node meta in t0
    addi $t0, $a0, -12 # current node
    lw $t3, 4($t0)   #previous node location in t3
    lw $t4, 8($t0)   #next node location in t4
    sw $t4, 8($t3)  #store current next node in previous node -> next
    sw $t3, 4($t4)   #store current previous node in next node -> previous
nullptr:
    jr $ra
