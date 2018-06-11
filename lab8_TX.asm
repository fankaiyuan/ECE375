;***********************************************************
;*
;*	File Name:kaiyuan_fan_and_andrew_collins_Lab7_sourcecode.asm
;*
;*	Enter the description of the program here
;*
;*	This is the TRANSMIT skeleton file for Lab 8 of ECE 375
;*
;***********************************************************
;*
;*	 Author: Andrew Collins and Kaiyuan Fan 
;*	   Date: 
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16	
.def temp =r20
.def	waitcnt = r17	; Wait Loop Counter
.def	ilcnt = r18		; Inner Loop Counter
.def	olcnt = r19		; Outer Loop Counter			; Multi-Purpose Register

.equ	WTime = 100		; Time to wait in wait loop was 
.equ	MovR = 0				; Move right Input Bit
.equ	MovL = 1				; Move left Input Bit
;.equ	MovF = 2				; Move Forward Input Bit
;.equ	MovB = 3				; Move Back Input Bit

.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit
; Use these action codes between the remote and robot
; MSB = 1 thus:
; control signals are shifted right by one and ORed with 0b10000000 = $80
.equ	MovFwd =  ($80|1<<(EngDirR-1)|1<<(EngDirL-1))	;0b10110000 Move Forward Action Code
.equ	MovBck =  ($80|$00)								;0b10000000 Move Backward Action Code
.equ	TurnR =   ($80|1<<(EngDirL-1))					;0b10100000 Turn Right Action Code
.equ	TurnL =   ($80|1<<(EngDirR-1))					;0b10010000 Turn Left Action Code
.equ	Halt =    ($80|1<<(EngEnR-1)|1<<(EngEnL-1))		;0b11001000 Halt Action Code
.equ	RobotID = $2A
;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	ldi		mpr, low(RAMEND)
	out		SPL, mpr		; Load SPL with low byte of RAMEND
	ldi		mpr, high(RAMEND)
	out		SPH, mpr		; Load SPH with high byte of RAMEND

	;I/O Ports
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

	; Initialize Port D for output
		ldi		mpr, (1<<PD3)	;Port E pin 1(TXD1) for output
		out		DDRD, mpr		

	;USART1
		;Set baudrate at 2400bps
		ldi mpr, high (416) ;Load high byte of 0x0340
		sts UBRR1H, mpr		;
		ldi mpr, low(416)	;Load low byte of 0x0340
		sts UBRR1L, mpr	

		;Enable transmitter
		ldi mpr, (1<<TXEN1) ;
		sts UCSR1B, mpr		;enable transmitter

		;Set frame format: 8 data bits, 2 stop bits
		ldi mpr,(0<<UMSEL1 | 1<<USBS1 | 1<<UCSZ11 | 1<<UCSZ10)
		sts UCSR1C, mpr	

		sei
	;Other

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
	;TODO: ???
		;in		mpr, PIND		; Get whisker input from Port D
		sbis	PIND, 0
		rcall	MoveRight
		sbis	PIND, 1
		rcall	MoveLeft

		sbis	PIND, 4
		rcall	MoveForward

		sbis	PIND, 5
		rcall	MoveBack

		sbis	PIND, 6
		rcall	MoveHalt

		sbis	PIND, 7
		rcall	Send_Freeze
		rjmp	MAIN



;***********************************************************
;*	Functions and Subroutines
;***********************************************************
MoveRight:		
		ldi mpr, RobotID
		sts UDR1, mpr
		rcall USART_Transmit

		ldi mpr, TurnR
		out PORTB,mpr
		sts UDR1, mpr
		

		rcall USART_Transmit

		ret

MoveLeft:		
		ldi mpr, RobotID
		sts UDR1, mpr
		rcall USART_Transmit
		ldi mpr, TurnL	
		out PORTB,mpr	
		sts UDR1, mpr
		rcall USART_Transmit
		ret

MoveForward:
		ldi mpr, RobotID
		sts UDR1, mpr
		rcall USART_Transmit
		ldi mpr, MovFwd
		out PORTB, mpr
			
		sts UDR1, mpr
		rcall USART_Transmit
		ret

MoveBack:
		ldi mpr, RobotID
		sts UDR1, mpr
		rcall USART_Transmit
		ldi mpr, MovBCk
			
		out PORTB, mpr
		sts UDR1, mpr
		rcall USART_Transmit
		ret

MoveHalt:
		ldi mpr, RobotID
		sts UDR1, mpr
		rcall USART_Transmit
		ldi mpr, Halt
		out PORTB, mpr
		sts UDR1, mpr
		rcall USART_Transmit
		ret

Send_Freeze:
		ldi mpr, RobotID
		sts UDR1, mpr
		rcall USART_Transmit
		ldi mpr, 0b11111000	
		out PORTB,mpr	
		sts UDR1, mpr
		rcall USART_Transmit
		ret

USART_Transmit:
	lds temp, UCSR1A;
	sbrs temp, UDRE1 ;loop unitl UDR1 is empty
	rjmp USART_Transmit
	;sts UDR1, mpr
	ret




;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************
