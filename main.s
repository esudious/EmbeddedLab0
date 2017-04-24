;****************** main.s ***************
; Program written by: Jeremy Mattson
; Date Created: 1/15/2017 
; Last Modified: 2/26/2017 
; Brief description of the program
; The objective of this system is to implement a Car door signal system
; Hardware connections: Inputs are negative logic; output is positive logic
;  PF0 is right-door input sensor (1 means door is open, 0 means door is closed)
;  PF4 is left-door input sensor (1 means door is open, 0 means door is closed)
;  PF3 is Safe (Green) LED signal - ON when both doors are closed, otherwise OFF
;  PF1 is Unsafe (Red) LED signal - ON when either (or both) doors are open, otherwise OFF
; The specific operation of this system 
;   Turn Unsafe LED signal ON if any or both doors are open, otherwise turn the Safe LED signal ON
;   Only one of the two LEDs must be ON at any time.
; NOTE: Do not use any conditional branches in your solution. 
;       We want you to think of the solution in terms of logical and shift operations

GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_PORTF_AMSEL_R EQU 0x40025528
GPIO_PORTF_PCTL_R  EQU 0x4002552C
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
SYSCTL_RCGCGPIO_R  EQU   0x400FE608
      THUMB
      AREA    DATA, ALIGN=2
;global variables go here
      ALIGN
      AREA    |.text|, CODE, READONLY, ALIGN=2
      EXPORT  Start
Start
	LDR R0, =SYSCTL_RCGCGPIO_R ;get clock address
	MOV R1, #0x20
	STR R1, [R0] ; turn on F Clock
	LDR R10, =0x0 ;wait..
	LDR R10, =0x0 ;wait..
	LDR R0, =GPIO_PORTF_LOCK_R ;get lock address
	LDR R1, =GPIO_LOCK_KEY ;get unlock key
	LDR R1, [R0] ;Unlock 
	
	LDR R0, =GPIO_PORTF_CR_R
	MOV R1, #0x1F ; allow changes to PF4-0
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_AMSEL_R
	MOV R1, #0x00 ; disable analog function
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_PCTL_R
	MOV R1, #0x00 ; GPIO clear bit PCTL
	STR R1, [R0]
	
	LDR R0, =GPIO_PORTF_DIR_R
	MOV R1, #0x1F	 ;PF4, PF0 input
	STRB R1, [R0]  ;and PF3, 2, 1 output
	
	LDR R0, =GPIO_PORTF_AFSEL_R
	MOV R1, #0x00 ; no alternate function
	STRB R1, [R0]  ; 
	
	LDR R0, =GPIO_PORTF_PUR_R
	MOV R1, #0x11 ; enable pullup resistors on PF4, PF0
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_DEN_R
	MOV R1, #0x1F ; enable digital pins PF4-PF0
	STRB R1, [R0]
	
	LDR R0, =GPIO_PORTF_DATA_R
	MOV R7, #0x08 	;GREEN LIGHT PF3
	MOV R8, #0x02	;RED LIGHT PF2
	
loop
	
	LDR R1, [R0]
	;MOV R1, R1, LSR #2
	AND R1, R1, #0x11 ; MASK with 10001
	CMP R1, #0x11     ;if doors open go to green
	BEQ green
	BNE red			;else red
	
	
 
green
	STR R7, [R0];green light
	B   loop
	
red
	STR R8, [R0];red light
	B   loop
	
	ALIGN        ; make sure the end of this section is aligned
		  
	AREA data1, DATA
		
		
PF0
	% 32
	ALIGN
		
PF4
	% 32
	ALIGN

      END          ; end of file