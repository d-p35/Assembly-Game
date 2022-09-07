###################################################################### 
# CSCB58 Summer 2022 Project 
# University of Toronto, Scarborough 
# 
# Student Name: Dhruv Patel, Student Number: 1007958685, UTorID: pate1636
# 
# Bitmap Display Configuration: 
# - Unit width in pixels: 8 
# - Unit height in pixels: 8 
# - Display width in pixels: 256  
# - Display height in pixels: 256 
# - Base Address for Display: 0x10008000 
# 
# Basic features that were implemented successfully 
# - Basic feature a/b/c (choose the ones that apply) 
#a) Shows lives in the form of hearts in the top left of the screen
#b)Cars in the opposide lane(left side of road) are faster than the cars in the right side of the road
#c) A Game Over screen is displayed when all 3 lives are lost and the user must press "r" to restart or "e" to exit within a few of seconds of the game finishing, else the program terminates there
# a,b,c were implemented
#	
# Additional features that were implemented successfully 
# - Additional feature a/b/c (choose the ones that apply) 
#a) Two pickups: Extra life and Instant progress
#b)Progress bar in the top right corner
#c)Once level one is over, there is a 2 second hold and then level 2 starts, where there are no powerups and cars spawn more rapidly
#   a,b,c were implemented
#
# Link to the video demo 
# - Insert YouTube/MyMedia/other URL here and make sure the video is accessible 
# https://youtu.be/UnN7EGm6xXU 

# Any additional information that the TA needs to know: 
# - While the game is one press, "q" to restart, and when it is on a game over page or you win page, press "r" to restart and "e" to exit
# -
#  
###################################################################### 
.data 
displayAddress:      .word 0x10008000  
red:		.word	0xFF0000
orange:	.word 0xFF985F
lightBlue:	.word 0x00FFFF
gray:		.word 0x5e5c5c
lives:		.word 0x000003
position:	.word 0x000003
car_loc:	.word 3660
initial_other_road_car1: .word 776
current_other_road_car1: .word 776
wait_other_car_1:	.word 1
initial_other_road_car2: .word 808
current_other_road_car2: .word 4392
wait_other_car_2:	.word 1
initial_other_road_car3: .word 1100
current_other_road_car3: .word 1100
wait_other_car_3:	.word 1
initial_other_road_car4: .word 1136
current_other_road_car4: .word 4444
wait_other_car_4:	.word 1
other_side_car_speed:	.word 256
same_side_car_speed:	.word 128

speed:	.word 1
progress: .word 1
level:	.word 1
powerup_boolean: .word 1
extra_life_powerup_counter: .word 0
wait_extra_life:	.word 0
initial_powerup_position:	.word 4444
current_extra_life_position:	.word 4444
wait_instant_progress:	.word 0
current_instant_progress_position:	.word 4444
instant_progress_powerup_counter: .word 0 
car_spawn_delay_range:	.word 50
progress_delay:	.word 40

.text 
				#zero is the black colour code
lw $t0, displayAddress		# $t0 stores the base address for display  
li $s0 0#delay for other road car 1
li $s1 0 #delay for other road car 2
li $s2, 0 #delay counter for progress bar
li $s5, 0  #delay for same road car 1
li $s6, 0 #delay for same road car 2

li $t9, 0 #temp infinite loop
lw $s3, initial_other_road_car1
add $s3, $t0, $s3		#store inital other car location
add $s4, $zero, $t0
addi $s4, $s4,  4224
li $v0, 32  
li $a0, 1000
syscall 
j main

RESET:	li $t9, 3
		sw $t9, lives
		
		li $t9, 1
		sw $t9, powerup_boolean
		
		li $t9,  1
		sw $t9, level
		
		li $t9, 40
		sw $t9, progress_delay
		
		li $t9, 40
		sw $t9, car_spawn_delay_range
		
		
		j LOSE_LIFE
		

LEVEL2:	
		li $t9, 2
		sw $t9, level
		
		sw $zero, powerup_boolean
		
		li $t9, 30
		sw $t9, car_spawn_delay_range
		
		li $t9, 40
		sw $t9, progress_delay
		
		

		
LOSE_LIFE: 	li $t9, 3
			sw $t9, position		#reset user car position(lane)
		
		li $t9, 0x000E4C
		sw $t9,  car_loc			#reset user car location(lane)
		
		lw $t9, initial_other_road_car1
		sw $t9, current_other_road_car1
		add $s3, $t0, $s3				#reset initial car position
		
		li $t9, 4392
		sw $t9, current_other_road_car2
		
		lw $t9, initial_other_road_car3
		sw $t9, current_other_road_car3
		
		li $t9 4444
		sw $t9, current_other_road_car4

		li $t9, 1
		sw $t9, speed		#reset speed
		
		li $t9, 1
		sw $t9, progress
		
		lw $t9, initial_powerup_position
		sw $t9, current_extra_life_position
		sw $t9, current_instant_progress_position
		
		li $s2, 0
		
		
main:		
MLOOP:		beq $s0, -1000, Exit
		
		jal CHECK_USER_IN
		jal DRAW_ROAD_USERCAR
		jal UPDATE_OTHER_CAR
		li $v0, 32  
		li $a0, 100
		syscall 
		j MLOOP

CHECK_USER_IN:
		li $t9, 0xffff0000 
		lw $t8, 0($t9)
		beq $t8, 1, KEYPRESS_HAPPENED
R_INPUT:	jr $ra
		
KEYPRESS_HAPPENED:
		lw $t2, 4($t9)
		beq $t2, 0x77, W_PRESSED	#'w' is pressed
		beq $t2, 0x61, A_PRESSED	#'a' is pressed
		beq $t2, 0x73, S_PRESSED	#'s' is pressed
		beq $t2, 0x64, D_PRESSED	#'d' is pressed
		beq $t2, 0x71, Q_R_PRESSED #'q' is pressed
		j R_INPUT

W_PRESSED: lw $t3, speed
			beq $t3, 3, R_INPUT
			addi $t3, $t3, 1
			sw $t3, speed
			j R_INPUT

A_PRESSED:	lw $t3, position
		beq $t3, 1, COLLISION
		lw $t2, car_loc
		beq $t3, 3, OVER_MIDDLE_L 
		addi $t2, $t2, -32
		sw $t2, car_loc
A_END:		addi $t3, $t3, -1
		sw $t3, position
		j R_INPUT

OVER_MIDDLE_L: addi $t2, $t2, -40
		sw $t2, car_loc
		j A_END

S_PRESSED:	lw $t3, speed
			beq $t3, 1, R_INPUT
			addi $t3, $t3, -1
			sw $t3, speed
			j R_INPUT

D_PRESSED:	lw $t3, position
		beq $t3, 4, COLLISION
		lw $t2, car_loc	
		beq $t3, 2, OVER_MIDDLE_R
		addi $t2, $t2, 32
		sw $t2, car_loc
D_END:	addi $t3, $t3, 1
		sw $t3, position
		j R_INPUT	

OVER_MIDDLE_R: addi $t2, $t2, 40
		sw $t2, car_loc
		j D_END

Q_R_PRESSED:  j RESET
		
		
DRAW_ROAD_USERCAR:
		 
lw $t1, red		# $t1 stores the purple colour code (for user car body)
li $t2, 0x00ff00		# $t2 stores the green colour code  
la $t3, lightBlue		# $t3 stores the blue colour code  
lw $t3, 0($t3)
li $t4, -1	    		# $t4 stores the white colour code 
li $t9, 0x00ffff00 		#$t3 stores the yellow colour code  
li $t8 0x5e5c5c		#$t8 stores the road colour
      
addi $t6, $t0, 512 # $t6 stores the address of the first unit on the first row
li $t5, 0       # $t5 stores the index of the loop
li $t7, 32  	# $t7 stores the number of units to be painted
SOLID_ROAD:	beq $t5, $t7 END_SOLID_ROAD
		sw $zero, 0($t6)
		sw $zero, 4($t6)
		sw $zero, 8($t6)
		sw $zero, 12($t6)
		sw $zero, 16($t6)
		sw $zero, 20($t6)
		sw $zero, 24($t6)
		sw $zero, 32($t6)
		sw $zero, 36($t6)
		sw $zero, 40($t6)
		sw $zero, 44($t6)
		sw $zero, 48($t6)
		sw $zero, 52($t6)
		sw $zero, 56($t6)
		sw $t9, 60($t6)
		sw $zero, 64($t6)
		sw $t9, 68($t6)
		sw $zero, 72($t6)
		sw $zero, 76($t6)
		sw $zero, 80($t6)
		sw $zero, 84($t6)
		sw $zero, 88($t6)
		sw $zero, 92($t6)
		sw $zero, 96($t6)
		sw $zero, 104($t6)
		sw $zero, 108($t6)
		sw $zero, 112($t6)
		sw $zero, 116($t6)
		sw $zero, 120($t6)
		sw $zero, 124($t6)
		addi $t6, $t6, 128
		addi $t5, $t5, 1
		j SOLID_ROAD

END_SOLID_ROAD:		
		addi $t6, $t0, 512 # $t6 stores the address of the first unit on the first row
			li $t5, 0       # $t5 stores the index of the loop

STRIPES_ROAD:		beq $t5, $t7 END_STRIP
			sw $t4, 28($t6)
			sw $zero, 156($t6)
			sw $t4, 100($t6)
			sw $zero, 228($t6)
			addi $t6, $t6, 256
			addi $t5, $t5, 1
			j STRIPES_ROAD


END_STRIP: add $t6, $zero, $t0 # $t6 stores the address of the first unit on the first row
			li $t5, 0       # $t5 stores the index of the loop
			li $t7,  51
TOP_BAR:
		beq $t5, $t7, T_END
		sw $t2, 0($t6)
		addi $t6,$t6, 4
		addi $t5, $t5, 1
		j TOP_BAR
		
T_END:		li $t5, 0       # $t5 stores the index of the loop
			li $t7,  12
PROG_BACK:	beq $t5, $t7, PROG_BACK_END
			sw $t4, 0($t6)
			addi $t6,$t6, 4
			addi $t5, $t5, 1
			j PROG_BACK
			
PROG_BACK_END:	
			li $t5, 0       # $t5 stores the index of the loop
			li $t7,  65
REST_BAR:	beq $t5, $t7, END_TOP_BAR
			sw $t2,0 ($t6)
			addi $t6,$t6, 4
			addi $t5, $t5, 1
			j REST_BAR			
			
				
END_TOP_BAR:	
				li $t1, 0xFF3E99
				addi $t6, $t0, 356
				sw $t1, -12($t6)
				sw $t1, 116($t6)
				sw $t1, 120($t6)
				li $t5, 0
				lw $t7, level
LEV_LOOP:		beq $t5, $t7, LEV_DONE
				sw $t1, 0($t6)
				sw $t1, 128($t6)
				addi $t5, $t5, 1
				addi $t6, $t6, 8
				j LEV_LOOP				

LEV_DONE:		lw $t1, red
				li $t5, 0
				lw $t7, lives
				beqz $t7,  END_LIVES
				addi $t6, $t0, 4
LIVES_L:			beq $t5, $t7,  PROGRESS
				sw $t1, 0($t6)
				sw $t1, 8($t6)
				sw $t1, 132($t6)
				sw $t1, 136($t6)
				sw $t1, 124($t6)
				sw $t1, 128($t6)
				sw $t1, 140($t6)
				sw $t1, 256($t6)
				sw $t1, 260($t6)
				sw $t1, 264($t6)
				sw $t1, 388($t6)
				addi $t6, $t6, 24
				addi $t5, $t5, 1
				j LIVES_L
				
END_LIVES:		jr $ra

MAX_PROG:		li $s7, 12
				jr $ra
				
				
INCR_PROGR:	
				lw $s7, progress
				li $t5, 1
				lw $t7, speed
				mult $t5,$t7
				mflo $t5
				add $s7, $s7, $t5
				ble  $s7, 12, R_MAX_PROG
				addi $sp, $sp, -4
				sw $ra, 0($sp)
				jal MAX_PROG
				lw $ra, 0($sp)
				addi $sp, $sp, 4
R_MAX_PROG:	sw $s7,  progress	
				addi $sp, $sp, -4
				sw $ra, 0($sp)
				jal DRAW_P
				beq $s7, 12, LEVEL_2_CHECK
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				li $s2, 0
				j DRAW_CAR
				
PROGRESS:		addi $s2, $s2, 1
				lw $t7, progress_delay
				beq $s2, $t7,  INCR_PROGR
				addi $sp, $sp, -4
				sw $ra, 0($sp)
				jal DRAW_P
				lw $ra, 0($sp)
				addi $sp, $sp, 4
				j DRAW_CAR
DRAW_P:		
				lw $t1, orange	
				li $t5, 0
				lw $t7, progress
				addi $t6,  $t0, 204
PRO_LOOP:				
				beq $t5, $t7, E_PRO_L
				sw $t1,  0($t6)
				addi $t5, $t5, 1
				addi $t6, $t6, 4
				j PRO_LOOP
			
E_PRO_L:		jr $ra
		
DRAW_CAR:		
			lw $t1, red	
			lw $t6, car_loc
			add $t6, $t0, $t6 
			

DRAWING_CAR_LOC:	
			sw $t8, 4($t6)
			sw $t8, 8($t6)
			sw $t8, 12($t6)			
			
			sw $t8, 132($t6)
			sw $t8, 136($t6)
			sw $t8, 140($t6)
		
			sw $t1, 260($t6)
			sw $t1, 264($t6)
			sw $t1, 268($t6)
	
			sw $t9, -116($t6)
			sw $t1, -120($t6)
			sw $t9, -124($t6)
			
			
			
			jr $ra

UPDATE_OTHER_CAR:

POWER_UPS_BOL: lw $t2, powerup_boolean 
				bne $t2,  1, UPDATE_O_CAR1
				addi $sp, $sp, -4
				sw $ra, 0($sp)
				jal POWER_UPS
				lw $ra, 0($sp)
				addi $sp, $sp,4

UPDATE_O_CAR1:
				lw $t2,  other_side_car_speed
				lw $t3, speed
				lw $s3, current_other_road_car1
				mult $t3, $t2
				mflo $t3
				add $s3, $s3, $t3
				sw $s3, current_other_road_car1
				add $s3, $t0, $s3
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				ble  $s3 $s4, ON_SCREEN1
				jal RESET_OTHER_POS1
ON_SCREEN1:	jal DRAW_OTHER_ROADSIDE_CAR
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				j UPDATE_O_CAR2
				
			
DRAW_OTHER_ROADSIDE_CAR:
lw $t1, lightBlue		# $t1 stores the blue colour code (for other car body)
li $t2, 0x00ff00		# $t2 stores the green colour code  
lw $t3, red 		
li $t9, 0x00ffff00 		# $t9 stores the yellow colour code  (head lights)
li $t8 0x5e5c5c		# $t8 stores the gray colour code (hood)
			
		
			
			addi $t6, $s3, 0

			lw $t4, 0($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 0($t6)
			
			lw $t4, 4($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 4($t6)
			
			lw $t4, 8($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 8($t6)
			
			lw $t4, -128($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, -128($t6)
			
			lw $t4, -124($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, -124($t6)
			
			lw $t4, -120($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, -120($t6)
		
			lw $t4, -256($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, -256($t6)
			
			lw $t4, -252($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, -252($t6)
			
			lw $t4, -248($t6)
			beq	$t4, $t3, COLLISION
			sw $t1, -248($t6)
			
			lw $t4, 128($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t9, 128($t6)
			
			lw $t4, 132($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, 132($t6)
			
			lw $t4, 136($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t9, 136($t6)
			jr $ra
			
			
	
RESET_OTHER_POS1:	addi $s0, $s0, 1
					bne  $s0, 1, CONTINUE1
					addi $sp, $sp , -4
					sw $ra, 0($sp)
					jal RANDOM_NUM_GEN
					sw $a0,  wait_other_car_1
					lw $ra, 0($sp)
					addi $sp, $sp , 4
CONTINUE1:			lw $t5,  wait_other_car_1
					bge  $s0, $t5,  CAR1
					j NO_CAR
CAR1:				lw $s3,  initial_other_road_car1
					sw $s3, current_other_road_car1
					add $s3, $t0, $s3
					li $s0, 0
					jr $ra

UPDATE_O_CAR2:
				lw $t2,  other_side_car_speed
				lw $t3, speed
				lw $s3, current_other_road_car2
				mult $t3, $t2
				mflo $t3
				add $s3, $s3, $t3
				sw $s3, current_other_road_car2
				add $s3, $t0, $s3
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				ble  $s3 $s4, ON_SCREEN2
				jal RESET_OTHER_POS2
ON_SCREEN2:	jal DRAW_OTHER_ROADSIDE_CAR
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				j UPDATE_O_CAR3
				

	
RESET_OTHER_POS2:	addi $s1, $s1, 1
					bne  $s1, 1, CONTINUE2
					addi $sp, $sp , -4
					sw $ra, 0($sp)
					jal RANDOM_NUM_GEN
					sw $a0,  wait_other_car_2
					lw $ra, 0($sp)
					addi $sp, $sp , 4
CONTINUE2:			lw $t5,  wait_other_car_2
					bge  $s1, $t5,  CAR2
					j NO_CAR
CAR2:				lw $s3,  initial_other_road_car2
					sw $s3, current_other_road_car2
					add $s3, $t0, $s3
					li $s1, 0
					jr $ra

DRAW_SAME_ROADSIDE_CAR:
lw $t1, lightBlue		# $t1 stores the blue colour code (for other car body)
li $t2, 0x00ff00		# $t2 stores the green colour code  
lw $t3, red 		
li $t9, 0x00ffff00 		# $t9 stores the yellow colour code  (head lights)
li $t8 0x5e5c5c		# $t8 stores the gray colour code (hood)
			
		
			
			addi $t6, $s3, 0

			lw $t4, 4($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 4($t6)
			
			
			lw $t4, 8($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 8($t6)
			
			lw $t4, 12($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 12($t6)
			
			
			lw $t4, 132($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 132($t6)
			
			
			lw $t4, 136($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 136($t6)
			
			lw $t4, 140($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t8, 140($t6)
			
			lw $t4, 260($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, 260($t6)
			
			lw $t4, 264($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, 264($t6)
			
			lw $t4, 268($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, 268($t6)

			lw $t4, -116($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t9, -116($t6)
			
			lw $t4, -120($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t1, -120($t6)
			
			lw $t4, -124($t6)
			beq	$t4, $t3, COLLISION
			beq	$t4, $t8, COLLISION
			beq	$t4, $t9, COLLISION
			sw $t9, -124($t6)
			jr $ra
			
UPDATE_O_CAR3:
				lw $t2,  same_side_car_speed
				lw $t3, speed
				lw $s3, current_other_road_car3
				mult $t3, $t2
				mflo $t3
				add $s3, $s3, $t3
				sw $s3, current_other_road_car3
				add $s3, $t0, $s3
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				ble  $s3 $s4, ON_SCREEN3
				jal RESET_OTHER_POS3
ON_SCREEN3:	jal DRAW_SAME_ROADSIDE_CAR
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				j UPDATE_O_CAR4
				

	
RESET_OTHER_POS3:	addi $s5, $s5, 1
					bne  $s5, 1, CONTINUE3
					addi $sp, $sp , -4
					sw $ra, 0($sp)
					jal RANDOM_NUM_GEN
					sw $a0,  wait_other_car_3
					lw $ra, 0($sp)
					addi $sp, $sp , 4
CONTINUE3:			lw $t5,  wait_other_car_3
					bge  $s5, $t5,  CAR3
					j NO_CAR
CAR3:				lw $s3,  initial_other_road_car3
					sw $s3, current_other_road_car3
					add $s3, $t0, $s3
					li $s5, 0
					jr $ra

UPDATE_O_CAR4:
				lw $t2,  same_side_car_speed
				lw $t3, speed
				lw $s3, current_other_road_car4
				mult $t3, $t2
				mflo $t3
				add $s3, $s3, $t3
				sw $s3, current_other_road_car4
				add $s3, $t0, $s3
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				ble  $s3 $s4, ON_SCREEN4
				jal RESET_OTHER_POS4
ON_SCREEN4:	jal DRAW_SAME_ROADSIDE_CAR
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				jr $ra
				

	
RESET_OTHER_POS4:	addi $s6, $s6, 1
					bne  $s6, 1, CONTINUE4
					addi $sp, $sp , -4
					sw $ra, 0($sp)
					jal RANDOM_NUM_GEN
					sw $a0,  wait_other_car_4
					lw $ra, 0($sp)
					addi $sp, $sp , 4
CONTINUE4:			lw $t5,  wait_other_car_4
					bge  $s6, $t5,  CAR4
					j NO_CAR
CAR4:				lw $s3,  initial_other_road_car4
					sw $s3, current_other_road_car4
					add $s3, $t0, $s3
					li $s6, 0
					jr $ra
					
					
NO_CAR:			addi $ra,$ra, 4
				jr $ra

RANDOM_NUM_GEN:	li $v0, 42  
					li $a0, 0  
					lw $a1, car_spawn_delay_range
					syscall
					jr $ra

RANDOM_NUM_GEN2:	li $v0, 42  
					li $a0, 0  
					li $a1, 100
					syscall
					jr $ra

POW_POS_GEN:		li $v0, 42  
					li $a0, 0  
					li $a1, 4
					syscall
					beq $a0, 0, POW_POS1
					beq $a0, 1, POW_POS2
					beq $a0, 2, POW_POS3
					beq $a0, 3, POW_POS4
					

POW_POS1:			lw $t5, initial_other_road_car1
					jr $ra

POW_POS2:			lw $t5, initial_other_road_car2
					jr $ra	

POW_POS3:			lw $t5, initial_other_road_car3
					jr $ra

POW_POS4:			lw $t5, initial_other_road_car4
					jr $ra





DRAW_EXTRA_LIFE:		
	li $t2, 0x00ff00		# $t2 stores the green colour code  
	lw $t3, red 		
	li $t9, 0x00ffff00 		# $t9 stores the yellow colour code  (head lights)
	li $t8 0x5e5c5c		#car roof
			add $t6, $s3, 0
			lw $t4, 4($t6)
			beq	$t4, $t3, EXTRA_LIFE_PICKUP
			sw $t2, 4($t6)
			
			lw $t4, 132($t6)
			beq	$t4, $t3, EXTRA_LIFE_PICKUP
			sw $t2, 132($t6)
			
			lw $t4, 260($t6)
			beq	$t4, $t3, EXTRA_LIFE_PICKUP
			sw $t2, 260($t6)
			
			lw $t4, 128($t6)
			beq	$t4, $t3, EXTRA_LIFE_PICKUP
			sw $t2, 128($t6)
			
			lw $t4, 136($t6)
			beq	$t4, $t3, EXTRA_LIFE_PICKUP
			sw $t2, 136($t6)
			jr $ra

EXTRA_LIFE_PICKUP:	
			lw $t5, lives
			beq $t5, 3, DONT_ADD_LIFE
			addi $t5, $t5, 1
			sw $t5, lives
DONT_ADD_LIFE:
			lw $t5,  initial_powerup_position
			sw $t5,  current_extra_life_position
			jr $ra

POWER_UPS:
EXTRA_LIFE:		li $t2,  128
				lw $t3, speed
				lw $s3, current_extra_life_position
				mult $t3, $t2
				mflo $t3
				add $s3, $s3, $t3
				sw $s3, current_extra_life_position
				add $s3, $t0, $s3
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				ble  $s3 $s4, ON_SCREENP1
				jal RESET_EXTRA_LIFE_POS
ON_SCREENP1:	jal DRAW_EXTRA_LIFE
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				 j INSTANT_PROGRESS		



RESET_EXTRA_LIFE_POS:
				lw $t2,  extra_life_powerup_counter
				addi $t2, $t2, 1
				sw $t2,  extra_life_powerup_counter
				bne $t2, 1, SKIP1
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				jal RANDOM_NUM_GEN2
				sw $a0,  wait_extra_life
				lw $ra, 0($sp)
				addi $sp, $sp , 4
SKIP1:			lw $t5,  wait_extra_life
				ble $t2, $t5, NO_CAR
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				jal  POW_POS_GEN		#stores current pos in $t5
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				sw $t5,  current_extra_life_position
				li $t5, 0
				sw $t5,  extra_life_powerup_counter
				jr $ra
				
DRAW_INSTANT_PROGRESS:
lw $t1, red
lw $t2, orange 
li $t3, -1

			addi $t6, $s3, 0
			
			lw $t4, 0($t6)
			beq	$t4, $t1, INSTANT_PROGRESS_PICKUP
			sw $t2, 0($t6)
			
			lw $t4, 4($t6)
			beq	$t4, $t1, INSTANT_PROGRESS_PICKUP
			sw $t2, 4($t6)
			
			lw $t4, 8($t6)
			beq	$t4, $t1, INSTANT_PROGRESS_PICKUP
			sw $t2, 8($t6)
			
			lw $t4, 12($t6)
			beq	$t4, $t1, INSTANT_PROGRESS_PICKUP
			sw $t3, 12($t6)
			jr $ra

INSTANT_PROGRESS_PICKUP:
			lw $s7, progress
			addi $s7, $s7, 2
			blt $s7, 12, NOT_FULL
			addi $sp, $sp , -4
			sw $ra, 0($sp)
			jal MAX_PROG
			lw $ra, 0($sp)
			addi $sp, $sp , 4
NOT_FULL:	sw $s7, progress
			lw $s7,  initial_powerup_position
			sw $s7,  current_instant_progress_position
			jr $ra		
				
INSTANT_PROGRESS:		
				li $t2,  128
				lw $t3, speed
				lw $s3, current_instant_progress_position
				mult $t3, $t2
				mflo $t3
				add $s3, $s3, $t3
				sw $s3, current_instant_progress_position
				add $s3, $t0, $s3
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				ble  $s3 $s4, ON_SCREENP2
				jal RESET_INSTANT_PROGRESS_POS
ON_SCREENP2:	jal DRAW_INSTANT_PROGRESS
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				jr $ra		
				
				
			
RESET_INSTANT_PROGRESS_POS:
				lw $t2,  instant_progress_powerup_counter
				addi $t2, $t2, 1
				sw $t2,  instant_progress_powerup_counter
				bne $t2, 1, SKIP2
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				jal RANDOM_NUM_GEN2
				sw $a0, wait_instant_progress
				lw $ra, 0($sp)
				addi $sp, $sp , 4
SKIP2:			lw $t5,  wait_instant_progress
				ble $t2, $t5, NO_CAR
				addi $sp, $sp , -4
				sw $ra, 0($sp)
				jal  POW_POS_GEN		#stores current pos in $t5
				lw $ra, 0($sp)
				addi $sp, $sp , 4
				sw $t5,  current_instant_progress_position
				add $s3, $t5, $s3
				li $t5, 0
				sw $t5,  instant_progress_powerup_counter
				jr $ra

LEVEL_2_CHECK:	lw $t9, level
				beq $t9, 2, YOU_WIN
				li $v0, 32  
				li $a0, 2000
				syscall 
				j LEVEL2
	
COLLISION:		
				lw $t7, lives
				addi $t7, $t7, -1
				sw $t7, lives
				bgtz $t7,  LOSE_LIFE
				jal END_STRIP
				jal GAME_OVER
RESTART_OR_QUIT:				
				li  $t7, 0
				li $s7 1000000
GAME_OVER_L:	beq $t7, $s7, Exit
				jal CHECK_END_INPUT
				addi $t7, $t7, 1
				j GAME_OVER_L
				
				
CHECK_END_INPUT:	li $t9, 0xffff0000
					lw $t8, 0($t9)
					beq $t8, 1, KEYPRESS_HAPPENED2

KEYPRESS_HAPPENED2:	lw $t2, 4($t9)
						beq $t2, 0x72, Q_R_PRESSED	#'r' is pressed
						beq $t2, 0x65, E_PRESSED	#'e' is pressed
						jr $ra
				
E_PRESSED:				j Exit

GAME_OVER:		
			li $t2, 0
			li $t7, 4096
			li $t5, 0
			addi $t6, $t0, 0
			
G_LOOP:		beq $t5, $t7, GAME_O_TEXT
			sw $t2,  0($t6)
			addi $t6, $t6, 4
			addi $t5, $t5, 1
			j G_LOOP



GAME_O_TEXT:	lw $t1, red
				li $t2, 0x00ff00
				addi $t6, $t0, 532
				sw $t2, 4($t6)
				sw $t2, 8($t6)
				sw $t2, 128($t6)
				sw $t2, 256($t6)
				sw $t2, 384($t6)
				sw $t2, 516($t6)
				sw $t2, 520($t6)
				sw $t2, 396($t6)
				sw $t2, 268($t6)
				sw $t2, 264($t6)
				
				sw $t2, 32($t6)
				sw $t2, 156($t6)
				sw $t2, 164($t6)
				sw $t2, 280($t6)
				sw $t2, 284($t6)
				sw $t2, 288($t6)
				sw $t2, 292($t6)
				sw $t2, 296($t6)
				sw $t2, 404($t6)
				sw $t2, 532($t6)
				sw $t2, 428($t6)
				sw $t2, 556($t6)
				
				sw $t2, 52($t6)
				sw $t2, 68($t6)
				sw $t2, 180($t6)
				sw $t2, 184($t6)
				sw $t2, 192($t6)
				sw $t2, 196($t6)
				sw $t2, 324($t6)
				sw $t2, 316($t6)
				sw $t2, 308($t6)
				sw $t2, 436($t6)
				sw $t2, 564($t6)
				sw $t2, 452($t6)
				sw $t2, 580($t6)
				
				sw $t2, 76($t6)
				sw $t2, 80($t6)
				sw $t2, 84($t6)
				sw $t2, 204($t6)
				sw $t2, 332($t6)
				sw $t2, 336($t6)
				sw $t2, 340($t6)
				sw $t2, 460($t6)
				sw $t2, 588($t6)
				sw $t2, 592($t6)
				sw $t2, 596($t6)
				
				addi $t6, $t6, 1024
				
				sw $t2, 4($t6)
				sw $t2, 8($t6)
				sw $t2, 128($t6)
				sw $t2, 140($t6)
				sw $t2, 256($t6)
				sw $t2, 268($t6)
				sw $t2, 388($t6)
				sw $t2, 392($t6)
				
				sw $t2, 20($t6)
				sw $t2, 152($t6)
				sw $t2, 284($t6)
				sw $t2, 416($t6)
				sw $t2, 292($t6)
				sw $t2, 168($t6)
				sw $t2, 44($t6)
				
				addi $t6, $t6, -128
				sw $t2, 56($t6)
				sw $t2, 60($t6)
				sw $t2, 64($t6)
				sw $t2, 184($t6)
				sw $t2, 312($t6)
				sw $t2, 316($t6)
				sw $t2, 320($t6)
				sw $t2, 440($t6)
				sw $t2, 568($t6)
				sw $t2, 572($t6)
				sw $t2, 576($t6)
				
				sw $t2, 76($t6)
				sw $t2, 80($t6)
				sw $t2, 84($t6)
				sw $t2, 204($t6)
				sw $t2, 212($t6)
				sw $t2, 332($t6)
				sw $t2, 336($t6)
				sw $t2, 340($t6)
				sw $t2, 460($t6)
				sw $t2, 464($t6)
				sw $t2, 588($t6)
				sw $t2, 596($t6)
				
				sw $t2, 20($t6)
				sw $t2, 152($t6)
				sw $t2, 284($t6)
				sw $t2, 416($t6)
				sw $t2, 292($t6)
				sw $t2, 168($t6)
				sw $t2, 44($t6)

				jr $ra
					
YOU_WIN:	
			li $t2, 0
			li $t7, 4096
			li $t5, 0
			addi $t6, $t0, 0
			
WIN_LOOP:	beq $t5, $t7, WIN_TEXT
			sw $t2,  0($t6)
			addi $t6, $t6, 4
			addi $t5, $t5, 1
			j WIN_LOOP
			

WIN_TEXT:		li $t1, 0x00ff00
				addi $t6, $t0, 532
				sw $t1, 16($t6)
				sw $t1, 148($t6)
				sw $t1, 280($t6)
				sw $t1, 412($t6)
				sw $t1, 288($t6)
				sw $t1, 164($t6)
				sw $t1, 40($t6)
				sw $t1, 540($t6)
				sw $t1, 668($t6)
				sw $t1, 796($t6)
				
				addi $t6, $t6, 424
				sw $t1, 4($t6)
				sw $t1, 8($t6)
				sw $t1, 128($t6)
				sw $t1, 140($t6)
				sw $t1, 256($t6)
				sw $t1, 268($t6)
				sw $t1, 388($t6)
				sw $t1, 392($t6)
				
				sw $t1, 20($t6)
				sw $t1, 148($t6)
				sw $t1, 276($t6)
				sw $t1, 404($t6)
				sw $t1, 408($t6)
				sw $t1, 412($t6)
				sw $t1, 284($t6)
				sw $t1, 156($t6)
				sw $t1, 28($t6)
				
				addi $t6, $t6, 720
				sw $t1, 0($t6)
				sw $t1, 132($t6)
				sw $t1, 264($t6)
				sw $t1, 396($t6)
				sw $t1, 272($t6)
				sw $t1, 148($t6)
				sw $t1, 24($t6)
				sw $t1, 156($t6)
				sw $t1, 288($t6)
				sw $t1, 420($t6)
				sw $t1, 296($t6)
				sw $t1, 172($t6)
				sw $t1, 48($t6)
				
				sw $t1, 60($t6)
				sw $t1, 188($t6)
				sw $t1, 316($t6)
				sw $t1, 444($t6)
			
				
				sw $t1, 72($t6)
				sw $t1, 200($t6)
				sw $t1, 328($t6)
				sw $t1, 456($t6)
				sw $t1, 76($t6)
				sw $t1, 208($t6)
				sw $t1, 340($t6)
				sw $t1, 472($t6)
				sw $t1, 476($t6)
				sw $t1, 348($t6)
				sw $t1, 220($t6)
				sw $t1, 92($t6)
				
			j RESTART_OR_QUIT

Exit:  
li $v0, 10 # terminate the program  
syscall
