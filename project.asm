.data
#LABEL FOR THE SENSORS
Temperature:		.word	0
Moisture:		.word	0
LightIntensity:		.word	0
PHvalue:		.word	0

#ACTUATORS OUTPUT MESSAGES


#PROMPT MESSAGES
tempprompt:	.asciiz	"\nEnter the current temperature (in Kelvin): "
phprompt:	.asciiz	"\nEnter the current PH (0.0-14.0): "
signoutprompt:	.asciiz "\nDo you wish to sign out? (Y/N): "

#DISPLAY VALUE MESSAGES
dashboard:	.asciiz "\nDASHBOARD\n"
tempdisplay:	.asciiz "\nTemperature (K): "
phdisplay:	.asciiz "\nPH Value: "
#newline:	.asciiz	"\n"

.text

Login:	
	
	
		#j	Login

Main:		la	$a0, dashboard		#print dashboard
		jal	printstring

		jal	GetInput
		
Compare:	lw	$t0, Moisture		#Load all variable sensors value into registers
		lw	$t1, LightIntensity
		lw	$t2, Temperature
		lw	$t3, PHvalue
		
		slti	$s0, $t0, 5		#Optimal value for moisture is 5% and abpve
		slti	$s1, $t1, 7		#Optimal value for light intensity is 7 and above
		slti	$s2, $t2, 305		#Optimal temperature is 305 and below
		slti	$s3, $t3, 5		#Optimal PH is 5 and above
		
		bne	$s0, $zero, waterOn1
checkLight:	bne	$s1, $zero, lightOn
checkTemp:	beq	$s2, $zero, waterOn2
checkPH:	bne	$s3, $zero, limestoneOn 
		
signout:	la	$a0, signoutprompt	#Prompt to sign out?
		jal	printstring
		
		addi	$v0, $zero, 12		#Read character
		syscall
		
		addi	$t0, $zero, 0x59	
		bne	$t0, $v0, Main		#Compare the input from user to sign out (Y)
		
		addi	$v0, $zero, 10		#exit program
		syscall

waterOn1:					#Output Actuators
		j	checkLight
		
lightOn:
		j	checkTemp
		
waterOn2:	
		j	checkPH

limestoneOn:
		j	signout
		
GetInput:	#GET ALL INPUT FROM SENSORS	

GetMoisture:	
		

GetLight:	
		
		
GetTemp:	la	$a0, tempprompt		#Get Temperature function
		jal	printstring
		
		jal	readint
		sw	$v0, Temperature
		
		la	$a0, tempdisplay
		jal	printstring
		
		lw	$a0, Temperature
		jal	printint

GetPH:		la	$a0, phprompt		#get PH value function
		jal	printstring
		
		jal	readint		
		sw	$v0, PHvalue
		
		la	$a0, phdisplay
		jal	printstring
		
		lw	$a0, PHvalue
		jal	printint
		
		j	Compare

readint:	addi	$v0, $zero, 5		#read float function
		syscall
		
		jr	$ra

printint:	addi	$v0, $zero, 1		#print float function
		syscall
		
		jr	$ra
		
printstring:	addi	$v0, $zero, 4		#print string function
		syscall
		
		jr	$ra