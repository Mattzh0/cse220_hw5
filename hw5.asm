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
	sll $t0, $a1, 6
    andi $t1, $a0, 0x2F
    or $t0, $t0, $t1
    sb $t0, 2($a3)
	

	# 3rd byte in record (bits 1-8 of credits)
	sll $t0, $a1, 0
	andi $t0, $t0, 0xFF
	sb $t0, 3($a3)

	# 4th byte in record (bits 25-32 of name pointer)

	# 5th byte in record (bits 17-24 of name pointer)

	# 6th byte in record (bits 9-16 of name pointer)

	# 7th byte in record (bits 1-8 of name pointer)

	jr $ra
	
print_student:
	jr $ra
	
init_student_array:
	jr $ra
	
insert:
	jr $ra
	
search:
	jr $ra

delete:
	jr $ra
