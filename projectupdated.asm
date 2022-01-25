.data
#LABEL FOR REGISTER
welcomeMsg: 	.asciiz "\n~~~WELCOME T0 THE SMART GARDENING SYSTEM~~~\n"
registerMsg:	.asciiz "Please Register First\n"
registerName:	.asciiz "Enter your desire name: "
registerPass:	.asciiz "Enter your desire password: "
username:	.space 10
pass:		.space 10

#LABEL FOR LOGIN & AUTHENTICATION
loginMsg:	.asciiz "\nPlease Login\n"
loginPrompt: 	.asciiz "Username: "
passwordPrompt: .asciiz "Password: "
usernameAuthen:	.space 10
passAuthen:	.space 10
usernameMsg1:	.asciiz "\nUsername Incorrect!! Please Try Again\n"
passwordMsg1:	.asciiz "\nPassword Incorrect!! Please Try Again\n"

#LABEL FOR THE SENSORS
Temperature:		.word	0
Moisture:		.word	0
LightIntensity:		.word	0
PHvalue:		.word	0

#ACTUATORS OUTPUT MESSAGES
waterOut:	.asciiz "\nMoisturizing the soil...\nTurn on Water Sprinkler for 5 minutes.\n"
lightOut:	.asciiz "\nIncreasing light intensity...\nTurn on all spotlight.\n"
waterOut2:	.asciiz "\nDecreasing the temperature...\nTurn on Water Sprinkler for 10 minutes.\n"
limestoneOut:	.asciiz "\nDecreasing soil acidity and increasing the PH...\nSowing limestone to the soil.\n"

#PROMPT MESSAGES
moistureprompt:	.asciiz	"\n\nEnter the moisturity of the soil (in Volumetric(%): "
lightprompt:	.asciiz	"\n\nEnter the current light intensity: "
tempprompt:	.asciiz	"\n\nEnter the current temperature (in Kelvin): "
phprompt:	.asciiz	"\n\nEnter the current PH (0.0-14.0): "
signoutprompt:	.asciiz "\nDo you wish to sign out? (Y/N): "

#DISPLAY VALUE MESSAGES
dashboard:	   .asciiz "\nDASHBOARD\n"
moisturedisplay:   .asciiz "Moisturity (%): "
lightdisplay:	   .asciiz "Light Intensity: "
tempdisplay:	   .asciiz "Temperature (K): "
phdisplay:	   .asciiz "PH Value: "
#newline:	   .asciiz	"\n"

.text
Register:	la	$a0, welcomeMsg		#print Welcome Message
		jal	printstring	
		
		la	$a0, registerMsg	#print Register Message
		jal	printstring
		
		la	$a0, registerName	#prompt user to input desire username
		jal	printstring
		
		la	$a0, username		#read desire username input
		jal	readstr	
		
		la	$a0, registerPass	#prompt user to input desire password
		jal	printstring						
	
		la	$a0, pass		#read desire password input
		jal	readstr	
		
#Login Part and Authentication		
LoginName:	la	$a0, loginMsg		#print login Message
		jal	printstring
		
		la	$a0, loginPrompt	#prompt user to input username
		jal	printstring
		
		la	$a0, usernameAuthen	#read username input
		jal	readstr	
		
		la	$t1, username
		la	$t2, usernameAuthen
		
#Authentication for Username		
AuthenName:	lb	$t3, ($t1)
		lb	$t4, ($t2)	
		bne	$t3, $t4, namene
		
		beq	$t3, $zero, LoginPass
		
		addi    $t1,$t1,1                   # point to next char
    		addi    $t2,$t2,1                   
    		j       AuthenName
    		
    						
LoginPass:	la	$a0, passwordPrompt	#prompt user to input password
		jal	printstring						
	
		la	$a0, passAuthen		#read password input
		jal	readstr
		
		la	$t1, pass
		la	$t2, passAuthen

#Authentication for Password		   		
AuthenPass:	lb	$t3, 0($t1)
		lb	$t4, 0($t2)	
		bne	$t3, $t4, passne
		
		beq	$t3, $zero, Main
		
		addi    $t1,$t1,1                   # point to next char
    		addi    $t2,$t2,1                   
    		j       AuthenPass		
		

	#Print message when username and password is not equal	
	namene:		la	$a0, usernameMsg1	
			jal	printstring
			syscall
		
			j	LoginName
			
	passne:		la	$a0, passwordMsg1		
			jal	printstring
			syscall
		
			j	LoginPass
	

Main:		la	$a0, dashboard		#print dashboard
		jal	printstring

		jal	GetInput
		
Compare:	lb	$t0, Moisture		#Load all variable sensors value into registers
		lb	$t1, LightIntensity
		lw	$t2, Temperature
		lb	$t3, PHvalue
		
		slti	$s0, $t0, 5		#Optimal value for moisture is 5% and above
		slti	$s1, $t1, 7		#Optimal value for light intensity is 7 and above
		slti	$s2, $t2, 306		#Optimal temperature is 305 and below
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
		bne 	$t0, $v0, Main		#Compare the input from user to sign out (Y)
		
		addi	$v0, $zero, 10		#exit program
		syscall

waterOn1:					#Output Actuators
		la	$a0, waterOut
		jal	printstring
		j	checkLight
		
lightOn:
		la	$a0, lightOut
		jal	printstring
		j	checkTemp
		
waterOn2:	
		la	$a0, waterOut2
		jal	printstring
		j	checkPH

limestoneOn:
		la	$a0, limestoneOut
		jal	printstring
		j	signout
		
GetInput:	#GET ALL INPUT FROM SENSORS	

GetMoisture:	la	$a0, moistureprompt		#Get Temperature function
		jal	printstring
		
		jal	readint
		sw	$v0, Moisture
		
		la	$a0, moisturedisplay
		jal	printstring
		
		lw	$a0, Moisture
		jal	printint
		

GetLight:	la	$a0, lightprompt		#Get Temperature function
		jal	printstring
		
		jal	readint
		sw	$v0, LightIntensity
		
		la	$a0, lightdisplay
		jal	printstring
		
		lw	$a0, LightIntensity
		jal	printint
		
		
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

readstr:	li 	 $a1, 10		#read string input
		li  	 $v0, 8	
		syscall
		
		jr	 $ra						

printint:	addi	$v0, $zero, 1		#print float function
		syscall
		
		jr	$ra
		
printstring:	addi	$v0, $zero, 4		#print string function
		syscall
		
		jr	$ra
