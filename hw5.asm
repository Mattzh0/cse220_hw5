.data
	space: .asciiz " "

.text

init_student:
	# 0th byte in record (bits 15-22 of ID)
	srl $t0, $a0, 14
    andi $t0, $t0, 0xFF
    sb $t0, 0($a3)

	# 1st byte in record (bits 7-15 of ID)
	srl $t0, $a0, 6
    andi $t0, $t0, 0xFF
    sb $t0, 1($a3)

	# 2nd byte in record (bits 1-6 of ID, 9-10 of credits)
	srl $t0, $a1, 8
	andi $t0, $t0, 0x03
	sll $t1, $a0, 2
    andi $t1, $t1, 0xFC
    or $t0, $t0, $t1
    sb $t0, 2($a3)
	
	# 3rd byte in record (bits 1-8 of credits)
	sll $t0, $a1, 0
	andi $t0, $t0, 0xFF
	sb $t0, 3($a3)

	# 4th byte in record (bits 25-32 of name pointer)
	srl $t0, $a2, 24
	andi $t0, $t0, 0xFF
	sb $t0, 4($a3)

	# 5th byte in record (bits 17-24 of name pointer)
	srl $t0, $a2, 16
	andi $t0, $t0, 0xFF
	sb $t0, 5($a3)

	# 6th byte in record (bits 9-16 of name pointer)
	srl $t0, $a2, 8
	andi $t0, $t0, 0xFF
	sb $t0, 6($a3)

	# 7th byte in record (bits 1-8 of name pointer)
	srl $t0, $a2, 0
	andi $t0, $t0, 0xFF
	sb $t0, 7($a3)

	jr $ra
	
print_student:
	# ID - all bytes will be loaded into $t0, which will be printed
	# byte 0
	lbu $t0, 0($a3)
	sll $t0, $t0, 14

	# byte 1
	lbu $t1, 1($a3)
	sll $t1, $t1, 6
	or $t0, $t0, $t1 # combine byte 0 with byte 1

	# byte 2 (ID part only)
	lbu $t1, 2($a3)
	srl $t1, $t1, 2
	or $t0, $t0, $t1 # combine part of byte 2 with (byte 0, byte 1)

	# print ID
	move $a0, $t0
	li $v0, 1
	syscall

	# space
	li $v0, 4
	la $a0, space
	syscall

	# credits
	# byte 2 (credits part only)
	lbu $t0, 2($a3)
	andi $t0, $t0, 0x03
	sll $t0, $t0, 8

	#byte 3
	lbu $t1, 3($a3)
	or $t0, $t0, $t1

	# print credits
	move $a0, $t0
	li $v0, 1
	syscall

	# space
	li $v0, 4
	la $a0, space
	syscall

	# name
	# first, load address into $t0
	# byte 4
	lbu $t0, 4($a3)
	sll $t0, $t0, 24

	# byte 5
	lbu $t1, 5($a3)
	sll $t1, $t1, 16
	or $t0, $t0, $t1 # combine byte 4 and 5

	#byte 6
	lbu $t1, 6($a3)
	sll $t1, $t1, 8
	or $t0, $t0, $t1 # combine byte 6 with (byte 4, byte 5)

	#byte 7
	lbu $t1, 7($a3)
	or $t0, $t0, $t1 # combine byte 7 with (byte 4, byte 5, byte 6)

	# print the string at the address (name)
	move $a0, $t0
	li $v0, 4
	syscall

	jr $ra
	
init_student_array:
	# save start address of records
    lw $t1, 0($sp)

	# save registers
    addi $sp, $sp, -28
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
	sw $s4, 8($sp)
	sw $s5, 4($sp)
	sw $ra, 0($sp)

	li $s0, 0 # loop counter
	move $s1, $a1 # store base address of ID array
	move $s2, $a2 # store base address of credits array
	move $s3, $a3 # store base address of name pointer array
	move $s4, $t1 # store the base address of the records struct array
	move $s5, $a0 # store num_students 

	loop:
		# go to end if loop counter = num_students
		beq $s0, $s5, end

		# load arguments to a registers for init_student function call
		lw $a0, 0($s1) # load current ID element
		lw $a1, 0($s2) # load current credits element
		lw $a2, 0($s3) # load current name pointer address
		lw $a3, 0($s4) # load current records address
		jal init_student

		addi $s0, $s0, 1 # increment loop counter
		addi $s1, $s1, 4 # move to address of next element in ID array
		addi $s2, $s2, 4 # move to address of next element in credits array

		# increment name pointer address until the after the next null terminator
		inc_name:
			lb $t2, 0($s3)
			beq $t2, $zero, end_inc_name # if the current character is a null terminator, end the loop and increment one more time to get to start of next string
			addi $s3, $s3, 1 # move to next character
			j inc_name
		end_inc_name:
			addi $s3, $s3, 1
			
		# increment address of records by 8 bytes (size of record struct)
		addi $s4, $s4, 8

		j loop

	end: 
		# restore saved registers
		lw $s0, 24($sp)
		lw $s1, 20($sp)
		lw $s2, 16($sp)
		lw $s3, 12($sp)
		lw $s4, 8($sp)
		lw $s5, 4($sp)
		lw $ra, 0($sp)
		addi $sp, $sp, 28
		
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
