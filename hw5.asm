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
	# save the address of record in $t2, since $a0 will be overwritten for printing
	move $t2, $a0 
	
	# ID - all bytes will be loaded into $t0, which will be printed
	# byte 0
	lbu $t0, 0($t2)
	sll $t0, $t0, 14

	# byte 1
	lbu $t1, 1($t2)
	sll $t1, $t1, 6
	or $t0, $t0, $t1 # combine byte 0 with byte 1

	# byte 2 (ID part only)
	lbu $t1, 2($t2)
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
	lbu $t0, 2($t2)
	andi $t0, $t0, 0x03
	sll $t0, $t0, 8

	#byte 3
	lbu $t1, 3($t2)
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
	lbu $t0, 4($t2)
	sll $t0, $t0, 24

	# byte 5
	lbu $t1, 5($t2)
	sll $t1, $t1, 16
	or $t0, $t0, $t1 # combine byte 4 and 5

	#byte 6
	lbu $t1, 6($t2)
	sll $t1, $t1, 8
	or $t0, $t0, $t1 # combine byte 6 with (byte 4, byte 5)

	#byte 7
	lbu $t1, 7($t2)
	or $t0, $t0, $t1 # combine byte 7 with (byte 4, byte 5, byte 6)

	# print the string at the address (name)
	move $a0, $t0
	li $v0, 4
	syscall

	jr $ra
	
init_student_array:
	# save start address of records
    lw $t2, 0($sp)

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
	move $s4, $t2 # store the base address of the records struct array
	move $s5, $a0 # store num_students 

	loop:
		# go to end if loop counter = num_students
		beq $s0, $s5, end

		# load arguments to a registers for init_student function call
		lw $a0, 0($s1) # load current ID element
		lw $a1, 0($s2) # load current credits element
		move $a2, $s3 # load current name pointer address
		move $a3, $s4 # move current records address
		jal init_student

		addi $s0, $s0, 1 # increment loop counter
		addi $s1, $s1, 4 # move to address of next element in ID array
		addi $s2, $s2, 4 # move to address of next element in credits array

		# increment name pointer address until the after the next null terminator
		inc_name:
			lb $t3, 0($s3)
			beq $t3, $zero, end_inc_name # if the current character is a null terminator, end the loop and increment one more time to get to start of next string
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
	move $t0, $a0 # store record address
	move $t1, $a1 # store base address of table

	# load into $t2 the ID of the record given by the address
	lbu $t2, 0($t0) # extract first byte of record (ID bytes 15-22)
	sll $t2, $t2, 14 # shift ID bytes 15-22 to the correct position
	lbu $t3, 1($t0) # extract second byte of record (ID bytes 7-15)
	sll $t3, $t3, 6 # shift ID bytes 7-15 to the correct position
	or $t2, $t2, $t3 # combine first and second bytes
	lbu $t3, 2($t0) # extract third byte of record (ID bytes 1-6, credits bytes 9-10)
	srl $t3, $t3, 2 # shift to remove credits bytes 9-10 and correctly position ID bytes 1-6
	or $t2, $t2, $t3 # combine third byte with (first,second)

	# calculate and store id % table_size into $t3
	div $t2, $a2 # stores the quotient of the div in lo, remainder (what we want) in hi
	mfhi $t3

	# calculate the start address ($t1) for linear probing
    sll $t4, $t3, 2 # multiply index by 4 (size of pointer)
    add $t1, $t1, $t4 # add index to base address of table

	# linear probing loop to find a free position
	li $t4, 0 # set loop counter to 0
	li $t6, -1 # tombstone value
	lin_prob:
		lw $t5, 0($t1) # load the element at the current index
		beq $t5, $zero, insert_table # if the element is zero (free), go to insert
		beq $t5, $t6, insert_table # if the element is -1 (free, tombstone value) go to insert

		addi $t1, $t1, 4 # increment to next address
		addi $t4, $t4, 1 # increment counter
		addi $t3, $t3, 1 # increment current index

		beq $t4, $a2, fail # if counter = table_size, we checked all locations and failed to insert
		bne $t3, $a2, lin_prob # if current index != table_size, move on as normal
		
		# otherwise, reset current index to beginning of table, and reset the address
		li $t3, 0
		move $t1, $a1
		j lin_prob

	insert_table:
		# insert the record address into the table
		sw $t0, 0($t1)
		move $v0, $t3
		j end_table

	fail:
		li $v0, -1
		j end_table

	end_table:
	jr $ra
	
search:
	move $t0, $a0 # store ID
	move $t1, $a1 # store base address (also the start location of search)
	li $t2, -1 # store tombstone value
	li $t3, 0 # initialize register to keep track of count and index

	search_loop:
		# load the current record
		lw $t4, 0($t1)

		# if the record is null or tombstone, go directly to next_iteration
		beq $t4, $zero, next_iteration
		beq $t4, $t2, next_iteration

		# extract the record ID into $t5
		lbu $t5, 0($t4) # extract first byte of record (ID bytes 15-22)
		sll $t5, $t5, 14 # shift ID bytes 15-22 to the correct position
		lbu $t6, 1($t4) # extract second byte of record (ID bytes 7-15)
		sll $t6, $t6, 6 # shift ID bytes 7-15 to the correct position
		or $t5, $t5, $t6 # combine first and second bytes
		lbu $t6, 2($t4) # extract third byte of record (ID bytes 1-6, credits bytes 9-10)
		srl $t6, $t6, 2 # shift to remove credits bytes 9-10 and correctly position ID bytes 1-6
		or $t5, $t5, $t6 # combine third byte with (first,second)
		
		# if current ID matches the one we're looking for, the search was a success
		beq $t5, $t0, search_success

		next_iteration:
			addi $t1, $t1, 4 # increment address
			addi $t3, $t3, 1 # increment count and index tracker
			
			# all positions were checked and the given ID was not found
			beq $t3, $a2, search_fail

			j search_loop
	
	search_success:
		move $v0, $t4
		move $v1, $t3
		j search_end

	search_fail:
		li $v0, 0
		li $v1, -1
		j search_end

	search_end:
	jr $ra

delete:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t7, -1 # store tombstone value

	# make a function call to search
	jal search
	beq $v0, $zero, deletion_fail # search did not find the element to be deleted
	
	# calculate the address where record was found
	sll $t8, $v1, 2
	add $t8, $a1, $t8

	# store the tombstone value at the calculated address
	sw $t7, 0($t8)
	move $v0, $v1
	j deletion_end

	deletion_fail:
		li $v0, -1
		j deletion_end

	deletion_end:
		lw $ra, 0($sp)
		addi $sp, $sp, 4
	jr $ra
