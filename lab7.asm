;***********************************************************
;*
;*	File Name: kaiyuan_fan_and_andrew_collins_Lab7_sourcecode.asm
;*	Course: ECE 375
;*	Enter the description of the program here
;*
;*	
;*
;***********************************************************
;*
;*	 Author: Kaiyuan Fan and Andrew Collins
;*	   Date: 11/08/2017
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multipurpose register
.def	waitcnt = r17				; Wait Loop Counter
.def	ilcnt = r18				; Inner Loop Counter
.def	olcnt = r19	
.def	speed_count=r20			;0-15
.def	time=r21

.equ	EngEnR = 4				; right Engine Enable Bit
.equ	EngEnL = 7				; left Engine Enable Bit
.equ	EngDirR = 5				; right Engine Direction Bit
.equ	EngDirL = 6				; left Engine Direction Bit
.equ	MovFwd = (1<<EngDirR|1<<EngDirL)


;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000
		rjmp	INIT			; reset interrupt

		; place instructions in interrupt vectors here, if needed
.org	$0002
		rcall  SPEED_UP
		reti
.org	$0004
		rcall SPEED_DOWN
		reti
.org	$0006
		rcall  STOP
		reti
.org	$0008
		rcall FULL_SPEED
		reti
		
.org	$0046					; end of interrupt vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
		; Initialize the Stack Pointer
		ldi		mpr, low(RAMEND)
		out		SPL, mpr		; Load SPL with low byte of RAMEND
		ldi		mpr, high(RAMEND)
		out		SPH, mpr		; Load SPH with high byte of RAMEND

		; Configure I/O ports
		; Initialize Port B for output
		ldi		mpr, $FF		; Set Port B Data Direction Register
		out		DDRB, mpr		; for output
		ldi		mpr, $00		; Initialize Port B Data Register
		out		PORTB, mpr		; so all Port B outputs are low	

		; Initialize Port D for input
		ldi		mpr, $00		; Set Port D Data Direction Register
		out		DDRD, mpr		; for input
		ldi		mpr, $FF		; Initialize Port D Data Register
		out		PORTD, mpr		; so all Port D inputs are Tri-State

		; Configure External Interrupts, if needed
		; Initialize external interrupts
		ldi mpr, (1<<ISC01)|(0<<ISC00)|(1<<ISC11)|(0<<ISC10)|(1<<ISC21)|(0<<ISC20)|(1<<ISC31)|(0<<ISC30)
		sts EICRA, mpr ; Use sts, EICRA is in extended I/O space

		; Configure the External Interrupt Mask
		; Set the Interrupt Sense Control to falling edge 
			ldi mpr, (1<<INT0)|(1<<INT1)|(1<<INT2)|(1<<INT3)
			out EIMSK, mpr

		; Configure 8-bit Timer/Counters

								; no prescaling
		ldi mpr,0b01101001		;activate Fast PWM with togle
		out TCCR0, mpr			;
		ldi mpr,0b01101001		;activate Fast PWM with togle
		out TCCR2, mpr		

		; Set TekBot to Move Forward (1<<EngDirR|1<<EngDirL)

		; Set initial speed, display on Port B pins 3:0
		ldi speed_count,$00;
		out	PORTB,speed_count
		; Enable global interrupts (if any are used)


		;rcall	LCDInit ;Initialize the LCD

		sei ; Enable global interrupt



;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		; poll Port D pushbuttons (if needed)
		;ldi mpr, MovFwd
		;out PORTB, mpr

		sbi PORTB, PB6
		sbi PORTB, PB5
								; if pressed, adjust speed
							; also, adjust speed indication
		rcall CLOCK	
		rcall wait
		rjmp	MAIN			; return to top of MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************
SPEED_UP:

		cpi speed_count,$0f
		breq Done
		inc speed_count
		out	PORTB,speed_count
		ldi mpr,17
		mul mpr,speed_count

		out OCR0,r0
		out OCR2,r0

		ldi mpr, 0xFF
		out EIFR, mpr ;clear interrupt flag register

		ret

SPEED_DOWN:

		cpi speed_count,$00
		breq Done
		dec speed_count
		out	PORTB,speed_count
		ldi mpr,17
		mul mpr,speed_count

		out OCR0,r0
		out OCR2,r0

		ldi mpr, 0xFF
		out EIFR, mpr ;clear interrupt flag register

		ret
STOP:

	ldi speed_count,$00
	out	PORTB,speed_count
	
	out OCR0,speed_count
	out OCR2,speed_count

	ldi mpr, 0xFF
	out EIFR, mpr ;clear interrupt flag register

	ret

FULL_SPEED:
ldi speed_count,$0f
	out	PORTB,speed_count
	
	ldi mpr,17
	mul mpr,speed_count
	out OCR0,r0
	out OCR2,r0
	ldi mpr, (0<<INTF0)|(0<<INTF1)|(0<<INT2)|(0<<INT3)
	out EIFR, mpr ;clear interrupt flag register

	ret

Done:
		ret

Clock:
		inc time
		ldi XL,$04
		ldi XH,$01
		


Wait:
		push	waitcnt			; Save wait register
		push	ilcnt			; Save ilcnt register
		push	olcnt			; Save olcnt register

Loop:	ldi		olcnt, 224		; load olcnt register
OLoop:	ldi		ilcnt, 237		; load ilcnt register
ILoop:	dec		ilcnt			; decrement ilcnt
		brne	ILoop			; Continue Inner Loop
		dec		olcnt		; decrement olcnt
		brne	OLoop			; Continue Outer Loop
		dec		waitcnt		; Decrement wait 
		brne	Loop			; Continue Wait loop	

		pop		olcnt		; Restore olcnt register
		pop		ilcnt		; Restore ilcnt register
		pop		waitcnt		; Restore wait register
		ret				; Return from subroutine
;-----------------------------------------------------------
; Func:	Template function header
; Desc:	Cut and paste this and fill in the info at the 
;		beginning of your functions
;-----------------------------------------------------------
FUNC:	; Begin a function with a label

		; If needed, save variables by pushing to the stack

		; Execute the function here
		
		; Restore any saved variables by popping from stack

		ret						; End a function with RET

;***********************************************************
;*	Stored Program Data
;***********************************************************
		; Enter any stored data you might need here

;***********************************************************
;*	Additional Program Includes
;***********************************************************
		; There are no additional file includes for this program
;.org	$0100				; data memory allocation for MUL16 example
;addrA:	.byte 2

;.include "LCDDriver.asm"		; Include the LCD Driver
