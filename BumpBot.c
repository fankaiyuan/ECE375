
/*
This code will cause a TekBot connected to the AVR board to
move forward and when it touches an obstacle, it will reverse
and turn away from the obstacle and resume forward motion.

PORT MAP
Port B, Pin 4 -> Output -> Right Motor Enable
Port B, Pin 5 -> Output -> Right Motor Direction
Port B, Pin 7 -> Output -> Left Motor Enable
Port B, Pin 6 -> Output -> Left Motor Direction
Port D, Pin 1 -> Input -> Left Whisker
Port D, Pin 0 -> Input -> Right Whisker
*/

#define F_CPU 16000000
#include <avr/io.h> 
#include <util/delay.h> 
#include <stdio.h>

int main(void)
{
	 DDRB = 0b11111111;// configure port B pin for outputs
	 PORTB = 0b01100000;//set move forward
	 
	 DDRD = 0b00000000;//configure port D for inputs
	   
	     /* Replace with your application code */
	     while (1)
	     {
		     PORTB = 0b01100000;//move forward
			/* if(PIND == 0b11111100 )// if bith right and left wisker hit
			 {
				 PORTB = 0b00000000;//move back
				 //PORTB = 0b01100000; // move forward
				 _delay_ms(500);//wait half seconds
				// PORTB = 0b00000000;//move back
				// _delay_ms(250);//wait quarter second
				 PORTB = 0b01000000;//turn right
				 //PORTB = 0b00100000;//turn left
				 _delay_ms(500);//wait half second
				 PORTB = 0b01100000;//move forward
			 }*/
		    if( PIND == 0b11111110 )//if right whisker hit
		     {
			     //PORTB = 0b00000000;//move back
				PORTB = 0b01100000; // move forward
			     _delay_ms(500);//wait half second
				PORTB = 0b00000000;//move back
				  _delay_ms(250);//wait quarter second
			    // PORTB = 0b00100000;//turn left
				PORTB = 0b01000000;//turn right
			     _delay_ms(500);//wait half second
			    PORTB = 0b01100000;//move forward
			     
		     }else if(PIND == 0b11111101)//if left whisker hit
		     {
			     //PORTB = 0b00000000;//move back
				 PORTB = 0b01100000; // move forward
				 _delay_ms(500);//wait half seconds
				 PORTB = 0b00000000;//move back
				 _delay_ms(250);//wait quarter second
			    // PORTB = 0b01000000;//turn right
				 PORTB = 0b00100000;//turn left
			     _delay_ms(500);//wait half second
			     PORTB = 0b01100000;//move forward
		     }
	     }
}
