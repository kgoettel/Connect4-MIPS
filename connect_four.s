### Author: Karsin Goettel
### File: connect_four.s	
### Assignment: asm5
### Class: CSC 252 Spring 2020
### Assignment: Free for all assignment!! I LOVED THIS PROJECT! I haven't
### gotten many projects where I can use keyboard commands or use a GUI,
### so I had to try and encorporate it. HOW IT WORKS: Press the "r" key 
### move right, "l" key to move left, and press the space bar to drop
### your chip. In order to win you must match 4 of the same color chips
### either horizontally, vertically, or diagonally. The BitMap display
### must be set to 16,16,512,512 for the proper picture to be displayed.
###
###	NOTES:
###
###	--------------------- 124 -----------------------
###	-------------------------------------------------
###	|  <-- 0					|
###	|						|
###	|    536   548   560   572   584   598   608 	|
###	|						|
###	|						|
###	|						|
###	|						|
###	|						|
###	|						|
###	|						|
###	|						|
###	|						|
###	|						|
###	|				      2030  --> |
###	-------------------------------------------------
###
###	board between two posts is 84 pixels wide
###	

.data
	DISPLAY:
		.space  16384
	END_OF_DISPLAY:
	
	BOARD_COL1:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	BOARD_COL2:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	BOARD_COL3:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	BOARD_COL4:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	BOARD_COL5:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	BOARD_COL6:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	BOARD_COL7:
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
		.byte 0
	ARRAYS_LENGTH: 	.word 7
	COL2:		.word 164
	COL3:		.word 176
	COL4:		.word 188
	COL5:		.word 200
	COL6:		.word 212
	
	NO_SPACE_MSG:	.asciiz "Cannot place piece here. Column is full. Try again."
	P1_WIN_MSG:	.asciiz "PLAYER ONE WINS!!!"
	P2_WIN_MSG:	.asciiz "PLAYER TWO WINS!!!"
	

.text
.globl make_background
make_background:

	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	add $t2, $zero, $zero		# int i = 0
	addi $t3, $zero, 2304		# t3 = 2300 used to fill the background white
	add $t4, $zero, $zero		# t4 = 0 used to increment to the next pixel
	
	BACKGROUND_LOOP:
	slt $t5, $t2, $t3		# t5 = i < 2300
	beq $t5, $zero, END_BACK	# if i >= 2304, then stop making the background
	add $t5, $t4, $a0		# t4 = &display + i
	sw $a1, 0($t5)			# draws a white pixel
	addi $t2, $t2, 1		# i ++
	addi $t4, $t4, 4		# used to get to increment to next pixel
	j BACKGROUND_LOOP
	
	END_BACK:
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	
.globl make_pillars
make_pillars:

	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	addi $t1, $zero, 8		# end row = 8
	addi $t2, $zero, 0		# int j = 0
	
	L_PILLAR_LOOP:
	slt $t4, $a2, $a3		# t4 = i < 1936
	beq $t4, $zero, END_PILLARS	# if i >= 1936, then stop making the board
	R_PILLAR_LOOP:
	slt $t4, $t2, $t1		# t4 = 	j < 8
	beq $t4, $zero, NEXT_ROW	# if j >= 8, then go to the next row
	add $t4, $a2, $t2		# t4 = i + j
	add $t4, $t4, $a0		# t4 = &display + (i + j)
	sw $a1, 0($t4)			# paints that pixel teal
	addi $t2, $t2, 4		# j += 4
	j R_PILLAR_LOOP			# back to inner loop
	NEXT_ROW:			# inner loop ended
	add $t2, $zero, $zero		# reset j to 0
	addi $a2, $a2, 128		# i += 128
	j L_PILLAR_LOOP
		
	END_PILLARS:
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	
.globl make_board
make_board:
	
	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	addi $t0, $zero, 404		# int i = 404
	addi $t1, $zero, 88		# the width of the board + 4
	add $t2, $zero, $zero		# int j = 0
	addi $t3, $zero, 2028		# where the board stops
	
	BOARD_LOOP:
	slt $t4, $t0, $t3		# t4 = i < 1772
	beq $t4, $zero, END_BOARD	# if i >= 1772, then stop making the board
	IN_BOARD_LOOP:			
	slt $t4, $t2, $t1		# t4 = j < 84
	beq $t4, $zero, NEXT_LINE	# if j >= 84, then go to the next row
	add $t4, $t0, $t2		# t4 = i + j
	add $t4, $a0, $t4		# t4 = &display + (i + j)
	sw $a1, 0($t4)			# paints the pixel teal
	addi $t2, $t2, 4		# j += 4
	j IN_BOARD_LOOP			# go back through the inner loop
	NEXT_LINE:			# inner loop ended
	add $t2, $zero, $zero		# reset j = 0
	addi $t0, $t0, 128		# i += 128
	j BOARD_LOOP
	
	END_BOARD:
	
	add $a0, $a0, $zero		# setting the display as the first parameter 
	add $a1, $zero, 0xC2C5C6	# making the pixel color gray
	jal make_spaces			# jumps to function that makes the spaces
	
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	
.globl make_spaces
make_spaces:
	
	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	addi $t0, $zero, 536		# int i = starting space
	addi $t1, $zero, 1892		# the last spot + 4
	addi $t2, $zero, 84		# aids in knowing when to go to next level
	add $t3, $zero, $zero		# keeps track of when to stop the loop
	
	SPACES_LOOP:
	slt $t4, $t3, $t1		# t4 = counter < 1892
	beq $t4, $zero, NO_SPACES	# if counter >= 1892, then stop adding spaces
	add $t5, $zero, $zero		# t5 = 0 (j)
	SPACE_ROWS:
	slt $t4, $t5, $t2		# t4 = j < 84
	beq $t4, $zero, NEW_ROW		# if j >= 84, go to the next row
	add $t4, $t0, $t5		# t0 = i + 12(j)
	add $t3, $zero, $t4		# tracker = 60 + i
	add $t4, $a0, $t4		# t4 = &display + i + 12(j)
	sw $a1, 0($t4)			# paints a pixel
	addi $t5, $t5, 12		# t5 += 12
	j SPACE_ROWS
	NEW_ROW:
	addi $t3, $t3, 256		# adds to tracker
	addi $t0, $t0, 256		# i += 256
	j SPACES_LOOP
	
	NO_SPACES:
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	
.globl game_play
game_play:
	
	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	addi $s0, $zero, 0		# used to determine whose turn it is (0 = P1, 1 = P2)
	add $t9, $zero, $a0		# keep track of a0
	
	lui     $t0, 0xffff
	
	START:
	addi $s1, $zero, 152		# position 0 = 152
	addi $s2, $zero, 224		# position 6 = 224
	addi $s3, $zero, 108		# hex value for L which is Left
	addi $s4, $zero, 114		# hex value for R which is right
	addi $t4, $zero, 20		# hex value for ' ' which is select
	addi $s5, $zero, 152		# used for incrementor 
	addi $s6, $zero, 0xC2C5C6	# gray used to cover up old pixel
	
	beq $s0, $zero, P1_TURN		# if s0 = 0, then its player 1s turn
	bne $s0, $zero, P2_TURN		# if s0 = 1, then its player 2s turn
	
	P1_TURN:
	addi $s7, $zero, 0xEC2923	# makes the color of the chip red
	sw $s7, 152($t9)		# places the red chip at the top
	addi    $t8, $zero, 0x00100	# LOOP_COUNT used for delay
	j SET_UP
	
	P2_TURN:
	addi $s7, $zero, 0x2347EC	# makes the color of the chip blue
	sw $s7, 152($t9)		# places the blue chip at the top
	addi    $t8, $zero, 0x00100	# LOOP_COUNT used for delay
	j SET_UP
	
	
	SET_UP:
	lw      $t1, 0($t0)      	# read control register
	andi    $t1, $t1,0x1     	# mask off all but bit 0 (the 'ready' bit)
	bne     $t1,$zero, READY
	
	NOT_READY_LOOP:
	lw      $t1, 0($t0)      	# read control register
	andi    $t1, $t1,0x1     	# mask off all but bit 0 (the 'ready' bit)
	beq     $t1,$zero, NOT_READY_LOOP
	
	READY:
	
	TURN_LOOP:
	lw  $t1, 4($t0)			# this loads what the keyboard value that was typed was
	beq $s3, $t1, CHECK_OK_L	# if "L" was typed, check if in bounds
	beq $s4, $t1, CHECK_OK_R	# if "R" was typed, check if in bounds
	beq $t4, $t1, PLACE		# if " " was typed, check if can insert

	PLACE:
	beq $s5, $s1, SET_COL1		# if youre in the first col, set param to BOARD_COL1
	lw $t5, COL2			# t5 = Col2
	beq $s5, $t5, SET_COL2		# if youre in the first col, set param to BOARD_COL2
	lw $t5, COL3			# t5 = Col2
	beq $s5, $t5, SET_COL3		# if youre in the first col, set param to BOARD_COL3
	lw $t5, COL4			# t5 = Col2
	beq $s5, $t5, SET_COL4		# if youre in the first col, set param to BOARD_COL4
	lw $t5, COL5			# t5 = Col2
	beq $s5, $t5, SET_COL5		# if youre in the first col, set param to BOARD_COL5
	lw $t5, COL6			# t5 = Col2
	beq $s5, $t5, SET_COL6		# if youre in the first col, set param to BOARD_COL6
	beq $s5, $s2, SET_COL7		# if youre in the first col, set param to BOARD_COL7
	
	SET_COL1:
	la $a0, BOARD_COL1		# first param
	add $a1, $s1, $zero		# makes the col number the second parameter
	j CALL_FUNCT	
	SET_COL2:
	la $a0, BOARD_COL2		# first param
	lw $a1, COL2			# makes the col number the second parameter
	j CALL_FUNCT
	SET_COL3:
	la $a0, BOARD_COL3		# first param
	lw $a1, COL3			# makes the col number the second parameter
	j CALL_FUNCT
	SET_COL4:
	la $a0, BOARD_COL4		# first param
	lw $a1, COL4			# makes the col number the second parameter
	j CALL_FUNCT	
	SET_COL5:
	la $a0, BOARD_COL5		# first param
	lw $a1, COL5			# makes the col number the second parameter
	j CALL_FUNCT
	SET_COL6:
	la $a0, BOARD_COL6		# first param
	lw $a1, COL6			# makes the col number the second parameter
	j CALL_FUNCT
	SET_COL7:
	la $a0, BOARD_COL7		# first param
	add $a1, $s2, $zero		# makes the col number the second parameter
	
	CALL_FUNCT:
	add $a2, $zero, $s7		# sets the color of the pixel as param 3
	add $a3, $zero, $t9		# sets the display as param 4
	
	addiu $sp, $sp, -28		# allocates stack space for the $tX registers
	sw $t0, 0($sp)			# add t0 to the stack
	sw $t1, 4($sp)			# add t1 to the stack
	sw $t2, 8($sp)			# add t2 to the stack
	sw $t3, 12($sp)			# add t3 to the stack
	sw $t4, 16($sp)			# add t4 to the stack
	sw $t8, 20($sp)			# add t8 to the stack
	sw $t9, 24($sp)			# add t9 to the stack

	jal place_piece
	
	lw $t9, 24($sp)			# remove t9 from the stack
	lw $t8, 20($sp)			# remove t8 from the stack
	lw $t4, 16($sp)			# remove t4 from the stack
	lw $t3, 12($sp)			# remove t3 from the stack
	lw $t2, 8($sp)			# remove t2 from the stack
	lw $t1, 4($sp)			# remove t1 from the stack
	lw $t0, 0($sp)			# remove t0 from the stack
	addiu $sp, $sp, 28		# takes away stack space
	
	beq $v0, 0x1, NOT_READY_LOOP
	
	# place parameters for checking for a winner
	add $a0, $zero, $t9		# sets the display as param 1
	add $a1, $zero, $s7		# sets the color of the pixel as param 2
	
	addiu $sp, $sp, -28		# allocates stack space for the $tX registers
	sw $t0, 0($sp)			# add t0 to the stack
	sw $t1, 4($sp)			# add t1 to the stack
	sw $t2, 8($sp)			# add t2 to the stack
	sw $t3, 12($sp)			# add t3 to the stack
	sw $t4, 16($sp)			# add t4 to the stack
	sw $t8, 20($sp)			# add t8 to the stack
	sw $t9, 24($sp)			# add t9 to the stack
	
	jal check_win
	
	lw $t9, 24($sp)			# remove t9 from the stack
	lw $t8, 20($sp)			# remove t8 from the stack
	lw $t4, 16($sp)			# remove t4 from the stack
	lw $t3, 12($sp)			# remove t3 from the stack
	lw $t2, 8($sp)			# remove t2 from the stack
	lw $t1, 4($sp)			# remove t1 from the stack
	lw $t0, 0($sp)			# remove t0 from the stack
	addiu $sp, $sp, 28		# takes away stack space
	
	addi $s1, $zero, 1		# to determine if there is a winner
	beq $v0, $s1, GAME_OVER		# if 1 was returned from checkwin, then GAME_OVER!
	
	xori $s0, $s0, 0xffffffff	# xor s0 with all ones gives the opposite value
	j START	
	
	GAME_OVER:
	li $v0, 10			# THIS IS THE MIPS EXIT COMMAND
   	syscall					

	CHECK_OK_R:
	beq $s5, $s2, NO_MOVE		# move off board, print message
	add $t5, $s5, $t9		# t5 = position + &display
	sw $s6, 0($t5)			# covers up the old piece
	addi $t5, $t5, 12		# move to next position
	sw $s7, 0($t5)			# make the chip move
	addi $s5, $s5, 12		# increment to next spot for checking
	j DELAY_LOOP
		
	CHECK_OK_L:
	beq $s5, $s1, NO_MOVE		# mvoe off board, print message
	add $t5, $s5, $t9		# t5 = position + &display
	sw $s6, 0($t5)			# covers up old piece
	addi $t5, $t5, -12		# moves back a position
	sw $s7, 0($t5)			# make the chip move
	addi $s5, $s5, -12		# increment to next spot for checking
	j DELAY_LOOP
	
	DELAY_LOOP:
	addi    $t2, $zero,0     	# i=0
	DELAY_START:
	slt     $t3, $t2,$t8      	# i < LOOP_COUNT
	beq     $t3,$zero, DELAY_DONE
	addi    $t2, $t2,1       	# i++
	j       DELAY_START
	DELAY_DONE:
	j SET_UP
	
	.data
		ERROR_MSG: 	.asciiz "Cannot move that way. Try again."
		
	.text
	NO_MOVE:
	addi $v0, $zero, 4		# prints a string
	la $a0, ERROR_MSG		# a0 = "Cannot move that way. Try again."
	syscall
	addi $v0, $zero, 11		# prints a character
	addi $a0, $zero, '\n'		# a0 = '\n'
	syscall
	j NOT_READY_LOOP

	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	
.globl place_piece
place_piece:

	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	la $t1, ARRAYS_LENGTH		# t1 = &ARRAYS_LENGTH
	lw $t1, 0($t1)			# t1 = 7 
	addi $t1, $t1, -1		# t1 = 6 = i
	add $t2, $zero, $zero		# t2 = 0
	la $t4, 0($a0)			# t4 = &the array
	addi $t0, $zero, 0xEC2923	# color of the red chip
	
	addi $t3, $t4, 1		# &array[1]
	lb $t3, 0($t3)			# array[1]
	bne $t3, $zero, NO_PLACE	# if the column is full, cannot place a piece here
	
	CHECK_DRAW:
	slt $t3, $t1, $t2		# t3 = length of the arrays < i
	bne $t3, $zero, STOP		# if length of the arrays < i, then stop
	add $t5, $t1, $t4		# t5 = i + &array
	lb $t7, 0($t5)			# t7 = array[i]
	beq $t7, $zero, FOUND		# if there is a zero here, its empty, found location
	addi $t1, $t1, -1		# i--
	j CHECK_DRAW
	
	FOUND:
	beq $a2, $t0, INSERT_1		# if its player 1's turn, place a 1, otherwise, place a 2
	addi $t0, $zero, 2		# to load 2 into the array
	sb $t0, 0($t5)			# 2 is there so nothing else can occupy
	j CONTINUE
	INSERT_1:
	addi $t3, $zero, 1		# to load 1 into the array
	sb $t3, 0($t5)			# 1 is there so nothing else can occupy
	CONTINUE:
	beq $t1, $t3, LAST_SPOT		# if i = 1, then the entire col is full except the last
	addi $t1, $t1, -1		# i --
	add $t6, $zero, $zero		# t6 = 0
	INDEX_LOOP:
	slt $t3, $t1, $t3		# t3 = i < 1
	bne $t3, $zero, DRAW		# if i < 1, then draw
	addi $t6, $t6, 256		# t6 += 256
	addi $t1, $t1, -1		# i --
	j INDEX_LOOP
	
	LAST_SPOT:
	addi $t8, $zero, 0xC2C5C6	# makes the pixel gray to cover the old one
	add $t9, $a3, $a1		# &display + &col
	sw $t8, 0($t9)			# makes the pixel before disappear
	add $a3, $a3, $a1		# a3 = &display + col
	addi $a3, $a3, 384		# add offset
	sw $a2, 0($a3)			# paints the pixel
	j STOP
	
	DRAW:
	addi $t8, $zero, 0xC2C5C6	# makes the pixel gray to cover the old one
	add $t9, $a3, $a1		# &display + &col
	sw $t8, 0($t9)			# makes the pixel before disappear
	add $a3, $a3, $t6		# a3 = &display + 256(i)
	add $a3, $a3, $a1		# a3 = &display + 256(i) + column number
	addi $a3, $a3, 128		# adds offset
	sw $a2, 0($a3)			# paints the pixel the correct color
	add $v0, $zero, 0		# place was found! 
	j STOP
	
	NO_PLACE:
	addi $v0, $zero, 4		# prepares to print a string
	la $a0, NO_SPACE_MSG		# a0 = "Cannot place piece here. Column is full. Try again."
	syscall
	addi $v0, $zero, 11		# prepares to print a character
	addi $a0, $zero, '\n'		# a0 = '\n'
	syscall
	addi $v0, $zero, 1		# no place found!
	
	STOP:
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	
.globl check_win
check_win:
	
	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	addiu $sp, $sp, -32		# allocating stack space to save previous $sX registers
	sw $s0, 0($sp)			# storing s0 onto the stack
	sw $s1, 4($sp)			# storing s1 onto the stack
	sw $s2, 8($sp)			# storing s2 onto the stack
	sw $s3, 12($sp)			# storing s3 onto the stack
	sw $s4, 16($sp)			# storing s4 onto the stack
	sw $s5, 20($sp)			# storing s5 onto the stack
	sw $s6, 24($sp)			# storing s6 onto the stack
	sw $s7, 28($sp)			# storing s7 onto the stack
	
	addi $t6, $zero, 1		# used to keep track of which col to check
	
	CHOOSE_COL:
	addi $t8, $zero, 1		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL1		# read from column 1
	addi $t8, $zero, 2		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL2		# read from column2
	addi $t8, $zero, 3		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL3		# read from column3
	addi $t8, $zero, 4		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL4		# read from column4
	addi $t8, $zero, 5		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL5		# read from column5
	addi $t8, $zero, 6		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL6		# read from column6
	addi $t8, $zero, 7		# aids in checking which col to load
	beq $t8, $t6, LOAD_COL7		# read from column7
	
	LOAD_COL1:
	la $t0, BOARD_COL1		# t0 = col1[]
	j INITIALIZE
	LOAD_COL2:
	la $t0, BOARD_COL2		# t0 = col2[]
	j INITIALIZE
	LOAD_COL3:
	la $t0, BOARD_COL3		# t0 = col3[]
	j INITIALIZE
	LOAD_COL4:
	la $t0, BOARD_COL4		# t0 = col4[]
	j INITIALIZE
	LOAD_COL5:
	la $t0, BOARD_COL5		# t0 = col5[]
	j INITIALIZE
	LOAD_COL6:
	la $t0, BOARD_COL6		# t0 = col6[]
	j INITIALIZE
	LOAD_COL7:
	la $t0, BOARD_COL7		# t0 = col7[]
	
	INITIALIZE:
	addi $t8, $zero, 6		# length of each array (refer to as i)
	addi $t5, $zero, 3		# winning value
	
	CHECK_VERT:
	
	add $t1, $zero, $zero		# counter (if it reaches four, there is a win)
	
	CHECK_WIN_COL:
	slt $t9, $t8, $zero		# t9 = i < 0
	bne $t9, $zero, CHECK_WIN_VERT	# if i <= 0, looked through everything here
	add $t3, $t0, $t8		# t3 = &BOARD_COL1 + i
	lb $t7, 0($t3)			# t7 = BOARD_COL1[i]
	beq $t7, $zero, MOVE_UP		# if  its a zero, then there is nothing here to check
	sub $t3, $t8, 1			# t3 =  i - 1
	add $t4, $t3, $t0		# t4 = &BOARD_COL1 + (i-1)
	lb $t4, 0($t4)			# t4 = col1[i-1]
	bne $t7, $t4, MOVE_NEXT		# if col1[i] != col[i-1]
	addi $t1, $t1, 1		# counter ++
	j CHECK_WIN_VERT
	MOVE_NEXT:
	add $t8, $t3, $zero		# t8 becomes that index that may have broken the chain
	add $t1, $zero, $zero		# reset the counter
	j CHECK_WIN_COL 
	MOVE_UP:
	addi $t8, $t8, -1		# i--
	add $t1, $zero, $zero		# reset the counter
	j CHECK_WIN_COL
	
	CHECK_WIN_VERT:
	beq $t1, $t5, WINNER		# if the counter = 4, the WINNER!
	slt $t9, $zero, $t8		# t6 = 0 < i
	bne $t9, $zero, KEEP_CHECK	# if 0 < i, then there is still more to check
	#check next col
	addi $t9, $zero, 7		# used to check if all columns have been checked
	beq $t9, $t6, CHECK_HORZ	# if t6 = 7, all columns have been gone through and no win, check horizontal 
	addi $t6, $t6, 1		# move to the next column
	j CHOOSE_COL
	KEEP_CHECK:
	addi $t8, $t8, -1
	j CHECK_WIN_COL
	
	CHECK_HORZ:
	addi $s0, $zero, 6 		# s0 = the number of rows 
	add $s2, $zero, $zero		# counter for wins
	
	CHECK_WIN_ROW:
	slt $t0, $s0, $zero		# t0 = rows < 0
	bne $t0, $zero, CHECK_DIAG	# if rows < zero, then you have checked every row
	
	la $t0, BOARD_COL1		# t0 = &BOARD_COL1
	la $t2, BOARD_COL2		# t2 = &BOARD_COL2
	la $t3, BOARD_COL3		# t3 = &BOARD_COL3
	la $t4, BOARD_COL4		# t4 = &BOARD_COL4
	la $t5, BOARD_COL5		# t5 = &BOARD_COL5
	la $t6, BOARD_COL6		# t6 = &BOARD_COL6
	la $s3, BOARD_COL7		# t7 = &BOARD_COL7
	
	START_COL1:
	add $t0, $t0, $s0		# t0 = &BOARD_COL1 + num_row
	lb $t0, 0($t0)			# t0 = col1[row]
	add $t2, $t2, $s0		# t0 = &BOARD_COL2 + num_row
	lb $t2, 0($t2)			# t0 = col2[row]
	add $t3, $t3, $s0		# t0 = &BOARD_COL3 + num_row
	lb $t3, 0($t3)			# t0 = col1[row]
	add $t4, $t4, $s0		# t0 = &BOARD_COL4 + num_row
	lb $t4, 0($t4)			# t0 = col1[row]
	add $t5, $t5, $s0		# t0 = &BOARD_COL5 + num_row
	lb $t5, 0($t5)			# t0 = col5[row]
	add $t6, $t6, $s0		# t0 = &BOARD_COL6 + num_row
	lb $t6, 0($t6)			# t0 = col6[row]
	add $s3, $s3, $s0		# t0 = &BOARD_COL7 + num_row
	lb $s3, 0($s3)			# t0 = col7[row]
	
	beq $t0, $zero, START_COL2	# if col1[row] = 0, then move on
	bne $t0, $t2, START_COL2	# if col1[row] != col2[row], move and check next cols
	bne $t2, $t3, START_COL3	# if col2[row] != col3[row], move and check next cols
	bne $t3, $t4, START_COL4	# if col3[row] != col4[row], move and check next cols
	add $t7, $zero, $t0		# makes t7 equal to the value found in the array to help determine winner
	j WINNER
	START_COL2:
	beq $t2, $zero, START_COL3	# if col2[row] = 0, then move on
	bne $t2, $t3, START_COL3	# if col2[row] != col3[row], move and check next cols
	bne $t3, $t4, START_COL4	# if col3[row] != col4[row], move and check next cols
	bne $t4, $t5, NEXT_ROW_HORZ	# if col4[row != col5[row], move and check next row, no possible win here
	add $t7, $zero, $t2		# makes t7 equal to the value found in the array to help determine winner
	j WINNER
	START_COL3:
	beq $t3, $zero, START_COL4	# if col3[row] = 0, then move one
	bne $t3, $t4, START_COL4	# if col3[row] != col4[row], move and check next cols
	bne $t4, $t5, NEXT_ROW_HORZ	# if col3[row] != col4[row], move and check next row, no possible win here
	bne $t5, $t6, NEXT_ROW_HORZ	# if col4[row != col5[row], move and check next rowm no possible win here
	add $t7, $zero, $t3		# makes t7 equal to the value found in the array to help determine winner
	j WINNER
	START_COL4:
	beq $t4, $zero, NEXT_ROW_HORZ	# if col4[row] = 0, then move one
	bne $t4, $t5, NEXT_ROW_HORZ	# if col4[row] != col5[row], move and check next row, no possible win here
	bne $t5, $t6, NEXT_ROW_HORZ	# if col5[row] != col6[row], move and check next row, no possible win here
	bne $t6, $s3, NEXT_ROW_HORZ	# if col6[row != col7[row], move and check next rowm no possible win here
	add $t7, $zero, $t4		# makes t7 equal to the value found in the array to help determine winner
	j WINNER	
	
	NEXT_ROW_HORZ:
	addi $s0, $s0, -1		# num_rows--
	j CHECK_WIN_ROW			
	
	CHECK_DIAG:
	addi $s0, $zero, 4		# last column where the forward and backward diagonals are checked
	addi $s4, $zero, 6		# number of rows
	
	la $t0, BOARD_COL1		# t0 = &BOARD_COL1
	la $t2, BOARD_COL2		# t2 = &BOARD_COL2
	la $t3, BOARD_COL3		# t3 = &BOARD_COL3
	la $t4, BOARD_COL4		# t4 = &BOARD_COL4
	la $t5, BOARD_COL5		# t5 = &BOARD_COL5
	la $t6, BOARD_COL6		# t6 = &BOARD_COL6
	la $s3, BOARD_COL7		# t7 = &BOARD_COL7
	
	CHECK_WIN_DIAG:
	slt $t8, $s4, $s0		# t8 = num_rows < 4
	bne $t8, $zero, END_WIN_FUNCT	# if num_rows < 4, then no wins can occur here diagonally, so STOP
	
	la $t0, BOARD_COL1		# t0 = &BOARD_COL1
	la $t2, BOARD_COL2		# t2 = &BOARD_COL2
	la $t3, BOARD_COL3		# t3 = &BOARD_COL3
	la $t4, BOARD_COL4		# t4 = &BOARD_COL4
	la $t5, BOARD_COL5		# t5 = &BOARD_COL5
	la $t6, BOARD_COL6		# t6 = &BOARD_COL6
	la $s3, BOARD_COL7		# t7 = &BOARD_COL7

	add $s5, $zero, $s4 		# number of rows, used to help increment and find proper diag value
	add $t0, $s5, $t0		# t0 = &BOARD_COL1 + num rows
	lb $s1, 0($t0)			# t0 = col1[row]
	addi $s5, $s5, -1		# row increment --
	add $t2, $s5, $t2		# t2 = &BOARD_COL2 + (num_rows-1)
	lb $s2, 0($t2)			# t2 = col2[row-1]
	addi $s5, $s5, -1		# row increment --
	add $t3, $s5, $t3		# t3 = &BOARD_COL3 + (num_rows-2)
	lb $s6, 0($t3)			# t2 = col3[row-2]
	addi $s5, $s5, -1		# row increment --
	add $t4, $s5, $t4		# t2 = &BOARD_COL4 + (num_rows-3)
	lb $s7, 0($t4)			# t2 = col4[row-3]
	
	beq $s1, $zero, CHECK_2		# if s1 is 0, no chance of diag, check 2
	bne $s1, $s2, CHECK_2		# if col1[row] != col2[row-1], then start checking col 2
	bne $s2, $s6, CHECK_3		# if col2[row-1] != col3[row-2], then start checking col 3
	bne $s6, $s7, CHECK_4		# if col3[row-2] != col4[row-3], then start checking
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	CHECK_2:
	addi $t2, $t2, 1		# t2 = &BOARD_COL2 + num_rows
	lb $s1, 0($t2)			# s1 = col2[row]
	addi $t3, $t3, 1		# t3 = &BOARD_COL3 + (num_rows-1)
	lb $s2, 0($t3)			# s2 = col3[row-1]
	addi $t4, $t4, 1		# t4 = &BOARD_COL4 + (num_rows-2)
	lb $s6, 0($t4)			# s6 = col4[rows-2]
	add $t5, $s5, $t5		# t5 = &BOARD_COL5 + (num_rows-3)
	lb $s7, 0($t5)			# s7 = col5[rows-3]
	
	beq $s1, $zero, CHECK_3		# if s1 is zero, no chance of diag, check 3
	bne $s1, $s2, CHECK_3		# if col2[row] != col3[row-1], then start checking col 3
	bne $s2, $s6, CHECK_4		# if col3[row-1] != col4[row-2], then start checking col 4
	bne $s6, $s7, BACK_DIAG		# if col4[row-2] != col5[row-3], then start checking back diag
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	CHECK_3:
	addi $t3, $t3, 1		# t3 = &BOARD_COL3 + num_rows
	lb $s1, 0($t3)			# s1 = col3[row]
	addi $t4, $t4, 1		# t4 = &BOARD_COL4 + (num_rows-1)
	lb $s2, 0($t4)			# s2 = col4[row-1]
	addi $t5, $t5, 1		# t5 = &BOARD_COL5 + (num_rows-2)
	lb $s6, 0($t5)			# s6 = col5[rows-2]
	add $t6, $s5, $t6		# t6 = &BOARD_COL6 + (num_rows-3)
	lb $s7, 0($t6)			# s7 = col6[rows-3]
	
	beq $s1, $zero, CHECK_4		# if s1 is zero, no chance for diag, check 4
	bne $s1, $s2, CHECK_4		# if col3[row] != col4[row-1], then start checking col 4
	bne $s2, $s6, BACK_DIAG		# if col4[row-1] != col5[row-2], then start checking back diag
	bne $s6, $s7, BACK_DIAG		# if col5[row-2] != col6[row-3], then start checking back diag
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	CHECK_4:
	addi $t4, $t4, 1		# t4 = &BOARD_COL4 + num_rows
	lb $s1, 0($t4)			# s1 = col4[row]
	addi $t5, $t5, 1		# t5 = &BOARD_COL5 + (num_rows-1)
	lb $s2, 0($t5)			# s2 = col5[row-1]
	addi $t6, $t6, 1		# t6 = &BOARD_COL6 + (num_rows-2)
	lb $s6, 0($t6)			# s6 = col6[rows-2]
	add $s3, $s5, $s3		# s3 = &BOARD_COL7 + (num_rows-3)
	lb $s7, 0($s3)			# s7 = col7[rows-3]
	
	beq $s1, $zero, BACK_DIAG	# if s1 is zero, no chance for diag, check back
	bne $s1, $s2, BACK_DIAG		# if col4[row] != col5[row-1], then start checking col 2
	bne $s2, $s6, BACK_DIAG		# if col5[row-1] != col5[row-2], then start checking col 3
	bne $s6, $s7, BACK_DIAG		# if col6[row-2] != col7[row-3], then start checking
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	BACK_DIAG:
	add $s5, $zero, $s4		# number of rows, used to help increment and find proper diag value
	
	la $t0, BOARD_COL1		# t0 = &BOARD_COL1
	la $t2, BOARD_COL2		# t2 = &BOARD_COL2
	la $t3, BOARD_COL3		# t3 = &BOARD_COL3
	la $t4, BOARD_COL4		# t4 = &BOARD_COL4
	la $t5, BOARD_COL5		# t5 = &BOARD_COL5
	la $t6, BOARD_COL6		# t6 = &BOARD_COL6
	la $s3, BOARD_COL7		# t7 = &BOARD_COL7
	
	add $s3, $s5, $s3		# t0 = &BOARD_COL7 + num rows
	lb $s1, 0($s3)			# t0 = col7[row]
	addi $s5, $s5, -1		# row increment --
	add $t6, $s5, $t6		# t2 = &BOARD_COL6 + (num_rows-1)
	lb $s2, 0($t6)			# t2 = col6[row-1]
	addi $s5, $s5, -1		# row increment --
	add $t5, $s5, $t5		# t3 = &BOARD_COL5 + (num_rows-2)
	lb $s6, 0($t5)			# t2 = col5[row-2]
	addi $s5, $s5, -1		# row increment --
	add $t4, $s5, $t4		# t2 = &BOARD_COL4 + (num_rows-3)
	lb $s7, 0($t4)			# t2 = col4[row-3]
	
	beq $s1, $zero, CHECK_6		# if s1 is 0, no chance of diag, check 6
	bne $s1, $s2, CHECK_6		# if col7[row] != col6[row-1], then start checking col 6
	bne $s2, $s6, CHECK_5		# if col6[row-1] != col5[row-2], then start checking col 5
	bne $s6, $s7, CHECK_4_2		# if col5[row-2] != col4[row-3], then start checking col 4
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	CHECK_6:
	addi $t6, $t6, 1		# t2 = &BOARD_COL6 + num_rows
	lb $s1, 0($t6)			# s1 = col6[row]
	addi $t5, $t5, 1		# t3 = &BOARD_COL5 + (num_rows-1)
	lb $s2, 0($t5)			# s2 = col5[row-1]
	addi $t4, $t4, 1		# t4 = &BOARD_COL4 + (num_rows-2)
	lb $s6, 0($t4)			# s6 = col4[rows-2]
	add $t3, $s5, $t3		# t5 = &BOARD_COL3 + (num_rows-3)
	lb $s7, 0($t3)			# s7 = col3[rows-3]
	
	beq $s1, $zero, CHECK_5		# if s1 is zero, no chance of diag, check 5
	bne $s1, $s2, CHECK_5		# if col6[row] != col5[row-1], then start checking col 5
	bne $s2, $s6, CHECK_4_2		# if col5[row-1] != col4[row-2], then start checking col 4
	bne $s6, $s7, NEXT_ROW_DIAG	# if col4[row-2] != col3[row-3], then start checking new row
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	CHECK_5:
	addi $t5, $t5, 1		# t2 = &BOARD_COL5 + num_rows
	lb $s1, 0($t5)			# s1 = col5[row]
	addi $t4, $t4, 1		# t3 = &BOARD_COL4 + (num_rows-1)
	lb $s2, 0($t4)			# s2 = col4[row-1]
	addi $t3, $t3, 1		# t4 = &BOARD_COL3 + (num_rows-2)
	lb $s6, 0($t3)			# s6 = col3[rows-2]
	add $t2, $s5, $t2		# t5 = &BOARD_COL2 + (num_rows-3)
	lb $s7, 0($t2)			# s7 = col2[rows-3]
	
	beq $s1, $zero, CHECK_4_2	# if s1 is zero, no chance of diag, check 4
	bne $s1, $s2, CHECK_4_2		# if col5[row] != col4[row-1], then start checking col 4
	bne $s2, $s6, NEXT_ROW_DIAG	# if col4[row-1] != col3[row-2], then start checking new row
	bne $s6, $s7, NEXT_ROW_DIAG	# if col3[row-2] != col2[row-3], then start checking new row
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	CHECK_4_2:
	addi $t4, $t4, 1		# t2 = &BOARD_COL4 + num_rows
	lb $s1, 0($t4)			# s1 = col4[row]
	addi $t3, $t3, 1		# t3 = &BOARD_COL3 + (num_rows-1)
	lb $s2, 0($t3)			# s2 = col3[row-1]
	addi $t2, $t2, 1		# t4 = &BOARD_COL2 + (num_rows-2)
	lb $s6, 0($t2)			# s6 = col2[rows-2]
	add $t0, $s5, $t0		# t5 = &BOARD_COL1 + (num_rows-3)
	lb $s7, 0($t0)			# s7 = col1[rows-3]
	
	beq $s1, $zero, NEXT_ROW_DIAG	# if s1 is zero, no chance of diag, check new row
	bne $s1, $s2, NEXT_ROW_DIAG	# if col4[row] != col3[row-1], then start checking new row
	bne $s2, $s6, NEXT_ROW_DIAG	# if col3[row-1] != col2[row-2], then start checking new row
	bne $s6, $s7, NEXT_ROW_DIAG	# if col2[row-2] != col1[row-3], then start checking new row
	add $t7, $zero, $s1		# assignes t7 to be who the winner is
	j WINNER
	
	NEXT_ROW_DIAG:
	addi $s4, $s4, -1		# go to next row
	j CHECK_WIN_DIAG
	
	WINNER:
	addi $t0, $zero, 1		# aids in checking if Player 1 is a winner
	beq $t7, $t0, P1_WIN		# if the col was filled with 1, then P1 wins
	P2_WINS:
	addi $v0, $zero, 4		# prepares to print a string
	la $a0, P2_WIN_MSG		# a0 = "PLAYER ONE WINS!!!"
	syscall
	addi $v0, $zero, 1		# there is a winner!
	j END_WIN_FUNCT
	P1_WIN:
	addi $v0, $zero, 4		# prepares to print a string
	la $a0, P1_WIN_MSG		# a0 = "PLAYER TWO WINS!!!"
	syscall
	addi $v0, $zero, 1		# there is a winner!
	
	END_WIN_FUNCT:
	
	lw $s7, 28($sp)			# removing s7 from the stack
	lw $s6, 24($sp)			# removing s6 from the stack
	lw $s5, 20($sp)			# removing s5 from the stack
	lw $s4, 16($sp)			# removing s4 from the stack
	lw $s3, 12($sp)			# removing s3 from the stack
	lw $s2, 8($sp)			# removing s2 from the stack
	lw $s1, 4($sp)			# removing s1 from the stack
	lw $s0, 0($sp)			# removing s0 from the stack
	addiu $sp, $sp, 32		# reallocating stack space
	
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
	

.globl main
main:
	addiu $sp, $sp, -24 		# allocate stack space
	sw $ra, 4($sp)			# save the caller's return address
	sw $fp, 0($sp)			# save the caller's frame pointer
	addiu $fp, $sp, 20		# set up the frame pointer
	
	addiu $sp, $sp, -16		# stores the s registers that are important
	sw $s0, 0($sp)			# stores s0 onto the stack
	sw $s1, 4($sp)			# stores s1 onto the stack
	sw $s2, 8($sp)			# stores s2 onto the stack
	sw $s3, 12($sp)			# stores s3 onto the stack

	la      $s0, DISPLAY
	addi    $s1, $zero, 0xC2C5C6
	
	add $a0, $zero, $s0		# makes the display the first parameter of make_background
	add $a1, $zero, $s1		# makes the color of the pixel white
	
	jal make_background		# jumps to the make_background function
	
	addi $s1, $zero, 0x208DBF	# makes the color of the board a teal color
	add $a0, $zero, $s0		# makes the display the first parameter of make_board
	add $a1, $zero, $s1		# makes the color of the pixel teal
	addi $a2, $zero, 268		# make the first point parameter 3
	addi $a3, $zero, 2064		# make the last point parameter 4
	
	jal make_pillars		# jumps to the make_pillars function
	
	add $a0, $zero, $s0		# makes the display the first parameter of make_pillars
	add $a1, $zero, $s1		# makes the color of the pixel teal
	addi $a2, $zero, 364		# make the first point parameter 3
	addi $a3, $zero, 2164		# make the last point parameter 4
	
	jal make_pillars		# jumps to the make_pillars function
	
	add $a0, $zero, $s0		# makes the display the first parameter of make_board
	add $a1, $zero, $s1		# makes the color of the pixel teal
	
	jal make_board
	
	add $a0, $zero, $s0		# makes the display the first parameter
	add $a1, $zero, $s1		# makes the color for the pixels the second parameter
	jal game_play
	
	la      $s2, END_OF_DISPLAY
	lui     $s3, 0xff
	sw      $s3, -4($s2)      	# row 63, col 63
	
	lw $s3, 12($sp)			# loads s3 from the stack
	lw $s2, 8($sp)			# loads s2 from the stack
	lw $s1, 4($sp)			# loads s1 from the stack
	lw $s0, 0($sp)			# loads s0 from the stack
	addiu $sp, $sp, 16		# reallocates stack stapce
	
	lw $fp, 0($sp)			# retores callers frame pointer
	lw $ra, 4($sp)			# get return address from stack
	addiu $sp, $sp, 24		# restore caller stack pointer
	jr $ra				# return to the caller code
