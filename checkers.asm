	.data
nl: .asciiz "\n"
wreg: .asciiz "w"
rreg: .asciiz "r"
wking: .asciiz "W"
rking: .asciiz "R"
enterrow: .asciiz "Enter row: "
entercol: .asciiz "Enter column: "
enterval: .asciiz "Enter Value: "
endsetup: .asciiz "Board set! Enter a number to continue: "
wturn: .asciiz "~~White Turn~~"
rturn: .asciiz "~~Red Turn~~"
redredo: .asciiz "Not White's Turn. Red try again"
whiteredo: .asciiz "Not Red's Turn. White try again"
wwin: .asciiz "White wins!"
rwin: .asciiz "Red wins!"
movethepiece: .asciiz "Choose where to move piece"
pieces: .asciiz "(1-w, 3-r, 5-W, 7-R)"
	.globl main
	.code
	
main:
	addi $sp,$sp,-256 # allocate memory for array

setboardrow1:
	li $t0,2 # begins at row 2
	
setboardcolumn1:
	mov $t1,$0 # begins at column 0
	
storeREDpieces:
	li $t4,3
	mov $t2,$t0
	mov $t3,$t1
	
	jal isLegalPosition
	beqz $s0,setboardcounter1
	
	sll $v0,$t2,3 # row * 8
	add $v0,$v0,$t3 # row + column
	sll $v0,$v0,2 # (row + column) * 4
	add $v0,$v0,$sp
	sw $t4,0($v0)
	
setboardcounter1:
	mov $t0,$t2
	mov $t1,$t3
	
	addi $t1,$t1,1
	blt $t1,8,storeREDpieces
	addi $t0,$t0,-1
	bgez $t0,setboardcolumn1
	
setboardrow2:
	li $t0,7 # begins at row 7
	
setboardcolumn2:
	mov $t1,$0 # begins at column 0
	
storeWHITEpieces:
	li $t4,1
	mov $t2,$t0
	mov $t3,$t1
	
	jal isLegalPosition
	beqz $s0,setboardcounter2
	
	sll $v0,$t2,3 # row * 8
	add $v0,$v0,$t3 # row + column
	sll $v0,$v0,2 # (row + column) * 4
	add $v0,$v0,$sp
	sw $t4,0($v0)
	
setboardcounter2:
	mov $t0,$t2
	mov $t1,$t3
	
	addi $t1,$t1,1
	blt $t1,8,storeWHITEpieces
	addi $t0,$t0,-1
	bge $t0,5,setboardcolumn2
	
presstocontinue:
	jal rowcounter
	
	la $a0,nl
	syscall $print_string
	la $a0,endsetup
	syscall $print_string # ask user to input again
	syscall $read_int
	
	beq $v0,0,start
	bne $v0,0,start
	
rowcounter:
	li $t0,7 # begins at row 7
	
columncounter:
	mov $t1,$0 # begins at column 0
	
printtheboard:
	sll $v0,$t0,3 # row * 8
	add $v0,$v0,$t1 # row + column
	sll $v0,$v0,2 # (row + column) * 4
	add $v0,$v0,$sp
	lw $t2,0($v0)
	
	beq $t2,1,whiteregularpiece
	beq $t2,3,redregularpiece
	beq $t2,5,whitekingpiece
	beq $t2,7,redkingpiece

	add $t2,$t0,$t1
	div $t2,2
	mfhi $t3
	
	beqz $t3,blackspace
	beq $t3,1,whitespace
	
whiteregularpiece:
	la $a0,wreg
	syscall $print_string
	j incrementcounter

redregularpiece:
	la $a0,rreg
	syscall $print_string
	j incrementcounter
	
whitekingpiece:
	la $a0,wking
	syscall $print_string
	j incrementcounter
	
redkingpiece:
	la $a0,rking
	syscall $print_string
	j incrementcounter

blackspace:
	li $v0,219
	mov $a0,$v0
	syscall $print_char # print blackspace
	j incrementcounter
	
whitespace:
	li $v0,32
	mov $a0,$v0
	syscall $print_char # print whitespace
	j incrementcounter

incrementcounter:
	addi $t1,$t1,1
	blt $t1,8,printtheboard
	
	la $a0,nl
	syscall $print_string

	addi $t0,$t0,-1
	bgez $t0,columncounter
	
	jr $ra
	
isLegalPosition:
	la $a0,nl
	syscall $print_string
	
	mov $s0,$0 # invalid move
	
	blt $t0,0,goback
	bgt $t0,7,goback
	blt $t1,0,goback
	bgt $t1,7,goback
	
	add $t0,$t0,$t1
	div $t0,2
	mfhi $t1
	
	beq $t1,0,goback
	
	li $s0,1 # valid move
	# goback
	
goback:
	jr $ra
	
start:
	#######starting game#######
	li $s1,12 # number of red pieces
	li $s2,12 # number of white pieces
	
whiteturn:
	li $t9,1
	
	la $a0,nl
	syscall $print_string
	la $a0,wturn
	syscall $print_string
	la $a0,nl
	syscall $print_string
	
	j beginturn
	
redturn:
	mov $t9,$0
	
	la $a0,nl
	syscall $print_string
	la $a0,rturn
	syscall $print_string
	la $a0,nl
	syscall $print_string
	
	j beginturn
	
beginturn:
	jal rowcounter
	
	la $a0,enterrow
	syscall $print_string
	syscall $read_int # user chooses row
	mov $t0,$v0
	la $a0,entercol
	syscall $print_string
	syscall $read_int # user chooses column
	mov $t1,$v0
	
	mov $t2,$t0
	mov $t3,$t1
	
	la $a0,nl
	syscall $print_string
	la $a0,movethepiece
	syscall $print_string
	la $a0,nl
	syscall $print_string
	
	la $a0,enterrow
	syscall $print_string
	syscall $read_int # user chooses row
	mov $t0,$v0
	la $a0,entercol
	syscall $print_string
	syscall $read_int # user chooses column
	mov $t1,$v0
	
	mov $t4,$t0
	mov $t5,$t1
	
	j isValidMove
	
isValidMove:
	mov $t0,$t2
	mov $t1,$t3
	jal isLegalPosition
	beqz $s0,beginturn
	
	mov $t0,$t4
	mov $t1,$t5
	jal isLegalPosition
	beqz $s0,beginturn
	
	sll $t0,$t4,3 # row * 8
	add $t0,$t0,$t5 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	lw $t1,0($t0)
	
	beq $t1,1,beginturn # checking if piece exists at r2,c2
	beq $t1,3,beginturn
	beq $t1,5,beginturn
	beq $t1,7,beginturn
	
	sll $t0,$t2,3 # row * 8 
	add $t0,$t0,$t3 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	lw $t1,0($t0)
	
	beq $t1,1,checkthemovement # white regular piece exists
	beq $t1,3,checkthemovement # red regular piece exists
	beq $t1,5,checkthemovement # white king piece exists
	beq $t1,7,checkthemovement # red king piece exists
	
	j beginturn

checkthemovement:
	mov $t6,$t1
	sub $t0,$t2,$t4 # setting up for checking movement
	sub $t1,$t3,$t5
	
	beq $t6,1,thepieceisWR
	beq $t6,3,thepieceisRR
	beq $t6,5,thepieceisWK
	beq $t6,7,thepieceisRK
	
whitetryagain:
	la $a0,whiteredo
	syscall $print_string
	la $a0,nl
	syscall $print_string
	j beginturn

redtryagain:
	la $a0,redredo
	syscall $print_string
	la $a0,nl
	syscall $print_string
	j beginturn
	
thepieceisWR:
	beqz $t9,redtryagain
	beq $t0,1,checkcolumn
	beq $t0,2,checkcolumnjump
	j beginturn

thepieceisRR:
	beq $t9,1,whitetryagain
	beq $t0,-1,checkcolumn
	beq $t0,-2,checkcolumnjump
	j beginturn

thepieceisWK:
	beqz $t9,redtryagain
	beq $t0,1,checkcolumn
	beq $t0,-1,checkcolumn
	beq $t0,2,checkcolumnjump
	beq $t0,-2,checkcolumnjump
	j beginturn
	
thepieceisRK:
	beq $t9,1,whitetryagain
	beq $t0,1,checkcolumn
	beq $t0,-1,checkcolumn
	beq $t0,2,checkcolumnjump
	beq $t0,-2,checkcolumnjump
	j beginturn

checkcolumn:
	beq $t1,1,movepiece
	beq $t1,-1,movepiece
	j beginturn
	
checkcolumnjump:
	beq $t1,2,isValidJump
	beq $t1,-2,isValidJump
	j beginturn
	
isValidJump:
	add $t0,$t2,$t4 # checking if a piece exists at location
	div $t0,2
	mflo $t1
	mov $t7,$t1
	
	add $t0,$t3,$t5
	div $t0,2
	mflo $t1
	mov $t8,$t1
	
	mov $t0,$t7
	mov $t1,$t8
	jal isLegalPosition
	beqz $s0,beginturn
	
	sll $t0,$t7,3 # row * 8
	add $t0,$t0,$t8 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	lw $t1,0($t0)
	
	beq $t1,1,mustberedpiece # you must eat a piece to jump
	beq $t1,3,mustbewhitepiece
	beq $t1,5,mustberedpiece
	beq $t1,7,mustbewhitepiece
	
	j beginturn
	
mustberedpiece:
	beq $t6,3,jumppiece
	beq $t6,7,jumppiece
	j beginturn

mustbewhitepiece:
	beq $t6,1,jumppiece
	beq $t6,5,jumppiece
	j beginturn
	
movepiece:
	jal RegulartoKing
	sll $t0,$t4,3 # row * 8
	add $t0,$t0,$t5 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	sw $t6,0($t0)

	li $t6,32
	sll $t0,$t2,3 # row * 8
	add $t0,$t0,$t3 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	sw $t6,0($t0)
	
	jal rowcounter
	
	beqz $t9,whiteturn
	beq $t9,1,redturn
	
RegulartoKing:
	beq $t6,1,EndRowAtZero
	beq $t6,3,EndRowAtSeven
	jr $ra
	
EndRowAtZero:
	beqz $t4,nowaWHITEKING
	jr $ra
	
EndRowAtSeven:
	beq $t4,7,nowaREDKING
	jr $ra
	
nowaWHITEKING:
	li $t6,5
	jr $ra
	
nowaREDKING:
	li $t6,7
	jr $ra
	
jumppiece:
	jal RegulartoKing
	sll $t0,$t4,3 # row * 8
	add $t0,$t0,$t5 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	sw $t6,0($t0)

	li $t6,32
	sll $t0,$t2,3 # row * 8
	add $t0,$t0,$t3 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	sw $t6,0($t0)
	
	sll $t0,$t7,3 # row * 8
	add $t0,$t0,$t8 # row + column
	sll $t0,$t0,2 # (row + column) * 4
	add $t0,$t0,$sp
	sw $t6,0($t0)
	
	jal rowcounter
	jal WhoLosesAPiece
	
	beqz $t9,whiteturn
	beq $t9,1,redturn
	
WhoLosesAPiece:
	beqz $t9,loseWHITEpiece
	beq $t9,1,loseREDpiece
	
loseREDpiece:
	addi $s1,$s1,-1
	beqz $s1,declareWHITEwinner
	jr $ra

loseWHITEpiece:
	addi $s2,$s2,-1
	beqz $s2,declareREDwinner
	jr $ra

declareWHITEwinner:
	la $a0,nl
	syscall $print_string
	la $a0,wwin
	syscall $print_string
	j exit
	
declareREDwinner:
	la $a0,nl
	syscall $print_string
	la $a0,rwin
	syscall $print_string
	j exit
	
exit:
	syscall $exit