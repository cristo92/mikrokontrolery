; ******************************************************
; BASIC .ASM template file for AVR
; ******************************************************

.include "C:\PROGRA~2\VMLAB\include\m16def.inc"
	
.def  temp  =r16
.equ SPEAKER_DDR = DDRB
.equ SPEAKER_P = PB3
.equ SPEAKER_PORT = PORTB
.equ SPEAKER_PIN = PINB

	;   D³ugoœæ nuty 		1,6 s		6400 taktów longdelay
	;   D³ugoœæ pó³nuty 	0,8 s 	3200  taktow longdelay
	;	 D³ugoœæ æwierænuty 0,4 s	1600  taktow longdelay
	;	 D³ugoœæ ósemki	0,2 s		800  taktow longdelay
	;   D³ugoœæ szesnastki 0,1 s  4    takty superlong
	.equ  WHOLE_NOTE	= 64
	.equ  HALF_NOTE	= 32
	.equ  QUARTER_HALF_NOTE = 24
	.equ  QUARTER_NOTE = 16
	.equ  EIGHTH_NOTE	= 8
	.equ  SIXTH_NOTE  = 4	
	;   OCR0 jest porównywane z wartoœci¹ licznika
	;   Gdy jest zgodnoœæ, licznik jest zerowany i nastêpuje przerwanie
	;   		Hz		OCR0
	;		c1	262	119
	;		d1	294	106
	;		e1	330   94
	;		f1	350   89
	;		g1	392   79
	;		a1	440   71
	;		h1	494   63
	;		c2	523   59
	;     d2 587   53
	;		e2 659   47
	;		f2 698   44
	;		g2 784   39
	;		a2 880   35
	;		h2 988   31
	.equ	SOUND_c1	= 119
	.equ	SOUND_d1	= 106
	.equ	SOUND_e1  = 94
	.equ  SOUND_f1  = 89
	.equ  SOUND_g1  = 79
	.equ  SOUND_a1  = 71
	.equ  SOUND_h1  = 63
	.equ  SOUND_c2  = 59
	.equ  SOUND_d2  = 53
	.equ  SOUND_e2  = 47
	.equ  SOUND_f2  = 44
	.equ  SOUND_g2  = 39
	.equ  SOUND_a2  = 35
	.equ  SOUND_h2  = 31

; LCD variables
	.equ  LCD_DATA_PORT = PORTC
	.equ  LCD_DATA_DDR  = DDRC
	.equ  LCD_RS        = PC0
	.equ  LCD_OE        = PC1
	.equ  LCD_D4        = PC2
	.equ  LCD_D5        = PC3
	.equ  LCD_D6        = PC4
	.equ  LCD_D7        = PC5
	
.cseg
.org 0

reset:
   rjmp start 	
.org INT0addr
	rjmp move_lcd
	
.org INT1addr
	rjmp play_song

.org 42

; Program starts here after Reset
;
start:

   ; Initialize the stack
   LDI R20, HIGH (RAMEND)
   OUT SPH, R20
   LDI R20, LOW (RAMEND)
   OUT SPL, R20


   ; Initialize global variables
   ldi r25, 0 ; pointer to song

	; Configure speaker
	sbi SPEAKER_DDR, SPEAKER_P
	cbi SPEAKER_PORT, SPEAKER_P
	
	rcall lcd_configure
	ldi r16, 100
	rcall delay
	ldi r16, 'N'
	rcall copy
	ldi r16, 'a'
	rcall copy
	ldi r16, 'c'
	rcall copy
	ldi r16, 'i'
	rcall copy
	ldi r16, 's'
	rcall copy
	ldi r16, 'n'
	rcall copy
	ldi r16, 'i'
	rcall copy
	ldi r16, 'j'
	rcall copy
	ldi r16, ' '
	rcall copy
	ldi r16, 'S'
	rcall copy
	ldi r16, 'W'
	rcall copy
	ldi r16, '7'
	rcall copy
	
	rcall new_line
	
	rcall delay
	ldi r16, 'P'
	rcall copy
	ldi r16, 'o'
	rcall copy
	ldi r16, 'z'
	rcall copy
	ldi r16, 'n'
	rcall copy
	ldi r16, 'i'
	rcall copy
	ldi r16, 'e'
	rcall copy
	ldi r16, 'j'
	rcall copy
	ldi r16, ' '
	rcall copy
	ldi r16, 'S'
	rcall copy
	ldi r16, 'W'
	rcall copy
	ldi r16, '6'
	rcall copy
	
	rcall interrupt_configure
	
	nop
	nop
	sei
	nop
	nop

forever:
   nop
rjmp forever

; r16 - czêstotliwoœæ	r17 - d³ugoœæ nutki
play_sound:
	push r18
	in r18, SREG
	push r18
	
	;   Preskaler:
	;   CS02 CS01 CS00
	;   0    0    0     licznik zatrzymany
	;   0    0    1     clk
	;   0    1    0     clk/8
	;   0    1    1     clk/64
	;   1    0    0     clk/256
	;   1    0    1     clk/1024
	out OCR0, r16
	ldi r18, 1 << WGM01 | 1 << CS02 | 1 << COM00
	out TCCR0, r18
	
	mov r16, r17
	rcall superlong
	
	ldi r18, 1 << WGM01 | 1 << COM00
	out TCCR0, r18
	ldi r18, 0
	out PORTB, r18
	ldi r16, 70
	rcall longdelay
	
	pop r18
	out SREG, r18
	pop r18
ret

; 0.0088ms = 8.8us
; R16 - liczba obrotów
delay:
	PUSH R18
	bigdelay:
		LDI R18, 20
		smalldelay:
			DEC R18
			BRNE smalldelay
		DEC R16
		BRNE bigdelay
	POP R18
ret
; 1ms = 1000us
; R16 - liczba obrotów
longdelay:
	PUSH R17
	PUSH R18
	
	loop_16:
		CLR R17
		loop_17:
			CLR R18
			loop_18:
				INC R18
				SBRS R18, 7
				rjmp loop_18
			INC R17
			SBRS R17, 4
			rjmp loop_17
		DEC R16
		brne loop_16
		
	POP R18
	POP R17
ret

;50ms = 50 000us
; r16 - liczba obrotow
superlong:
	push r17
	in r17, SREG
	push r17
	
	mov r17, r16
	loop_643:
		ldi r16, 50
		rcall longdelay
		dec r17
		brne loop_643
	nop
	
	pop r17
	out SREG, r17
	pop r17
ret

move_lcd:
	push r16
	in r16, SREG
	push r16
	
	ldi r18, 1 << WGM01 | 1 << COM00
	out TCCR0, r18
	ldi r18, 0
	out PORTB, r18
	
	inc r25
	; Check if bigger than 3
	sbrc r25, 2
	ldi r25, 1
	
	in r16, PIND
	sbrc r16, PD2
	rjmp if_move_lcd
		ldi r16, 10
		rcall longdelay
		
		in r16, PIND
		sbrc r16, PD2
		rjmp if_move_lcd
			; obsluz zdazenie
			rcall clear_lcd
			
			ldi r16, '>'
			rcall copy
			
			mov r16, r25
			dec r16
			breq if_move_lcd01
			dec r16
			breq if_move_lcd02
			dec r16
			breq if_move_lcd03
			
			if_move_lcd01:
				rcall write_mariotheme
				rjmp if_move_lcd00
			if_move_lcd02:
				rcall write_starwars
				rjmp if_move_lcd00
			if_move_lcd03:
				rcall write_cichanoc
				rjmp if_move_lcd00
			if_move_lcd00:
			
			rcall new_line
			
			mov r16, r25
			dec r16
			breq if_move_lcd11
			dec r16
			breq if_move_lcd12
			dec r16
			breq if_move_lcd13
			
			if_move_lcd11:
				rcall write_starwars
				rjmp if_move_lcd10
			if_move_lcd12:
				rcall write_cichanoc
				rjmp if_move_lcd10
			if_move_lcd13:
				rcall write_mariotheme
				rjmp if_move_lcd10
			if_move_lcd10:
			
			while_move_lcd:
				in r16, PIND
				sbrc r16, PD2
				rjmp if_move_lcd
				ldi r16, 10
				rcall longdelay
				rjmp while_move_lcd
	if_move_lcd:
	
	sei
	
	forever_move_lcd:
		nop
		nop
		rjmp forever_move_lcd
		
	pop r16
	out SREG, r16
	pop r16
reti

play_song:
	push r16
	in r16, SREG
	push r16
	
	in r16, PIND
	sbrc r16, PD3
	rjmp if_play_song
		ldi r16, 10
		rcall longdelay
		
		in r16, PIND
		sbrc r16, PD3
		rjmp if_play_song
			; obsluz zdazenie
			
			while_play_song:
				in r16, PIND
				sbrc r16, PD3
				rjmp if_play_song
				ldi r16, 10
				rcall longdelay
				rjmp while_play_song
	if_play_song:
	
	
	sei
	
	forever_play_song:
		mov r16, r25
		dec r16
		breq if_play_song1
		dec r16
		breq if_play_song2
		dec r16
		breq if_play_song3
		
		if_play_song1:
			rcall mariotheme
			rjmp forever_play_song
		if_play_song2:
			rcall starwars
			rjmp forever_play_song
		if_play_song3:
			rcall cichanoc
			rjmp forever_play_song
		
		rjmp forever_play_song
	
	pop r16
	out SREG, r16
	pop r16
reti
	

interrupt_configure:
	push r16
	
	; Configure interupt INT0
	; Set PD2 as input
	cbi DDRD, PD2
	; Add rezystor podciagajacy
	sbi PORTD, PD2
	
	; Configure interrupt INT1
	; Set PD3 as input
	cbi DDRD, PD3
	; Add rezystor podci¹gaj¹cy
	sbi PORTD, PD3
	
	in r16, MCUCR
	cbr r16, 1 << 3
	cbr r16, 1 << 3
	sbr r16, 1 << 1
	cbr r16, 1 << 0
	out MCUCSR, r16
	
	in r16, GICR
	sbr r16, 1 << 7
	sbr r16, 1 << 6
	out GICR, r16
	
	in r16, GIFR
	sbr r16, 1 << INTF0 | 1 << INTF1
	out GIFR, r16
	
	pop r16
ret
	

; LCD_configure
lcd_configure:
	push r16
	in r16, SREG
	push r16
	; Set as output
	SBI LCD_DATA_DDR, LCD_RS
	SBI LCD_DATA_DDR, LCD_OE
	SBI LCD_DATA_DDR, LCD_D4
	SBI LCD_DATA_DDR, LCD_D5
	SBI LCD_DATA_DDR, LCD_D6
	SBI LCD_DATA_DDR, LCD_D7

	CBI LCD_DATA_PORT, LCD_RS
   CBI LCD_DATA_PORT, LCD_OE
   LDI R16, 40
   RCALL longdelay
   ; First instruction (30)16
   SBI LCD_DATA_PORT, LCD_OE
   SBI LCD_DATA_PORT, LCD_D4
   SBI LCD_DATA_PORT, LCD_D5
   CBI LCD_DATA_PORT, LCD_D6
   CBI LCD_DATA_PORT, LCD_D7
   NOP
   LDI R16, 6
   CBI LCD_DATA_PORT, LCD_OE
   RCALL longdelay
   ; Second instruction (30)16
   SBI LCD_DATA_PORT, LCD_OE
   NOP
   LDI R16, 10
   CBI LCD_DATA_PORT, LCD_OE
   RCALL delay
   ; Third instruction (30)16
   SBI LCD_DATA_PORT, LCD_OE
   NOP
   LDI R16, 10
   CBI LCD_DATA_PORT, LCD_OE
   RCALL delay
   ; Fourth instruction (20)16
   SBI LCD_DATA_PORT, LCD_OE
   CBI LCD_DATA_PORT, LCD_D4
   NOP
   LDI R16, 6
   CBI LCD_DATA_PORT, LCD_OE
   RCALL delay

	; My configuration
	; Function set
	LDI R16, 0b00101011
	RCALL copy
	LDI R16, 6
	RCALL delay
	; Clear display
	LDI R16, 0b00000001
	RCALL copy
	LDI R16, 2
	RCALL longdelay
	; Display control
	LDI R16, 0b00001111
	RCALL copy
	LDI R16, 6
	RCALL delay
	; Data
	SBI LCD_DATA_PORT, LCD_RS
	LDI R16, 10	
	
	pop r16
	out SREG, r16
	pop r16
ret

; Copy - wypisuje pod kursorem znak R16, przesuwa kursor w prawo
; R16 - argument, znak
copy:
	PUSH R17
	in r17, SREG
	PUSH r17
	MOV R17, R16
	
	SBI LCD_DATA_PORT, LCD_OE ; Set E as 1
	SBRS R17, 4   ; Copy 4 bit
	CBI LCD_DATA_PORT, LCD_D4
	SBRC R17, 4
	SBI LCD_DATA_PORT, LCD_D4
	SBRS R17, 5   ; Copy 5 bit
	CBI LCD_DATA_PORT, LCD_D5
	SBRC R17, 5
	SBI LCD_DATA_PORT, LCD_D5
	SBRS R17, 6   ; Copy 6 bit
	CBI LCD_DATA_PORT, LCD_D6
	SBRC R17, 6
	SBI LCD_DATA_PORT, LCD_D6
	SBRS R17, 7   ; Copy 7 bit
	CBI LCD_DATA_PORT, LCD_D7
	SBRC R17, 7
	SBI LCD_DATA_PORT, LCD_D7
	LDI R16, 1
	NOP
	CBI LCD_DATA_PORT, LCD_OE  ; Set E as 0
	RCALL delay ; Delay 10 us
	
	SBI LCD_DATA_PORT, LCD_OE ; Set E as 1
	SBRS R17, 0   ; Copy 0 bit
	CBI LCD_DATA_PORT, LCD_D4
	SBRC R17, 0
	SBI LCD_DATA_PORT, LCD_D4
	SBRS R17, 1   ; Copy 1 bit
	CBI LCD_DATA_PORT, LCD_D5
	SBRC R17, 1
	SBI LCD_DATA_PORT, LCD_D5
	SBRS R17, 2   ; Copy 2 bit
	CBI LCD_DATA_PORT, LCD_D6
	SBRC R17, 2
	SBI LCD_DATA_PORT, LCD_D6
	SBRS R17, 3   ; Copy 3 bit
	CBI LCD_DATA_PORT, LCD_D7
	SBRC R17, 3
	SBI LCD_DATA_PORT, LCD_D7
	LDI R16, 1
	NOP
	CBI LCD_DATA_PORT, LCD_OE ; Set E as 0
	RCALL delay ; Delay 10 us
	LDI R16, 10
	RCALL delay
	
	POP R17
	out SREG, r17
	pop r17
ret

new_line:
	push r16
	in r16, SREG
	push r16
	
	; New line --begin--
	ldi r16, 100
	rcall delay
	cbi LCD_DATA_PORT, LCD_RS
	ldi r16, 40
	rcall longdelay
	
	ldi r16, 0x80 + 0x40
	rcall copy
	
	ldi r16, 100
	rcall delay
	sbi LCD_DATA_PORT, LCD_RS
	ldi r16, 40
	rcall longdelay
	; New line --end--
	
	pop r16
	out SREG, r16
	pop r16
ret

clear_lcd:
	push r16
	in r16, SREG
	push r16
	
	; Czyszczenie LCD --begin--
	cbi LCD_DATA_PORT, LCD_RS
	ldi r16, 40
	rcall longdelay
	ldi r16, 1
	rcall copy
	
	ldi r16, 100
	rcall delay
	sbi LCD_DATA_PORT, LCD_RS
	ldi r16, 40
	rcall longdelay
	; Czyszczenie LCD --end--
	
	pop r16
	out SREG, r16
	pop r16
ret

; Teksty
; 1. Mario theme
write_mariotheme:
	push r16
	in r16, SREG
	push r16
	
	ldi r16, 'M'
	rcall copy
	ldi r16, 'a'
	rcall copy
	ldi r16, 'r'
	rcall copy
	ldi r16, 'i'
	rcall copy
	ldi r16, 'o'
	rcall copy
	ldi r16, ' '
	rcall copy
	ldi r16, 't'
	rcall copy
	ldi r16, 'h'
	rcall copy
	ldi r16, 'e'
	rcall copy
	ldi r16, 'm'
	rcall copy
	ldi r16, 'e'
	rcall copy
	
	pop r16,
	out SREG, r16
	pop r16
ret
; 2. Star Wars
write_starwars:
	push r16
	in r16, SREG
	push r16
	
	ldi r16, 'S'
	rcall copy
	ldi r16, 't'
	rcall copy
	ldi r16, 'a'
	rcall copy
	ldi r16, 'r'
	rcall copy
	ldi r16, ' '
	rcall copy
	ldi r16, 'W'
	rcall copy
	ldi r16, 'a'
	rcall copy
	ldi r16, 'r'
	rcall copy
	ldi r16, 's'
	rcall copy
	
	pop r16
	out SREG, r16
	pop r16
ret
; 3. Cicha noc
write_cichanoc:
	push r16
	in r16, SREG
	push r16
	
	ldi r16, 'C'
	rcall copy
	ldi r16, 'i'
	rcall copy
	ldi r16, 'c'
	rcall copy
	ldi r16, 'h'
	rcall copy
	ldi r16, 'a'
	rcall copy
	ldi r16, ' '
	rcall copy
	ldi r16, 'n'
	rcall copy
	ldi r16, 'o'
	rcall copy
	ldi r16, 'c'
	rcall copy
	
	pop r16
	out SREG, r16
	pop r16
ret

; Kolendy:
; 1. Mario Theme
mariotheme:
	push r16
	push r17
	push r18
	in r16, SREG
	push r16
	
	ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_a2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_a2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, QUARTER_NOTE
rcall superlong
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, QUARTER_NOTE
rcall play_sound

ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, QUARTER_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SIXTH_NOTE
rcall superlong
ldi r16, SOUND_c2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE
rcall play_sound



	
	pop r16
	out SREG, r16
	pop r18
	pop r17
	pop r16
ret
; 2. Star Wars
starwars:
	push r16
	push r17
	push r18
	in r16, SREG
	push r16
	
	ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, HALF_NOTE
rcall play_sound

ldi r16, SOUND_d2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, HALF_NOTE
rcall play_sound

ldi r16, SOUND_g2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_h1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, HALF_NOTE
rcall play_sound

ldi r16, SOUND_g2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_f2
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_e2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_d2
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_e2
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_g1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_c2
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_a1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, EIGHTH_NOTE
rcall superlong
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound

ldi r16, SOUND_g1
ldi r17, QUARTER_NOTE
rcall play_sound
ldi r16, SOUND_e1
ldi r17, EIGHTH_NOTE + SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_h1
ldi r17, SIXTH_NOTE
rcall play_sound
ldi r16, SOUND_g1
ldi r17, HALF_NOTE
rcall play_sound






	
	pop r16
	out SREG, r16
	pop r18
	pop r17
	pop r16
ret
; 3. Cicha noc
cichanoc:
	push r16
	push r17
	push r18
	in r16, SREG
	push r16
	
	ldi r16, SOUND_g1
	ldi r17, EIGHTH_NOTE + SIXTH_NOTE
	rcall play_sound		
	ldi r16, SOUND_a1
	ldi r17, SIXTH_NOTE
	rcall play_sound	
	ldi r16, SOUND_g1
	ldi r17, EIGHTH_NOTE
	rcall play_sound	
	ldi r16, SOUND_e1
	ldi r17, QUARTER_NOTE + EIGHTH_NOTE
	rcall play_sound
	
	ldi r16, SOUND_g1
	ldi r17, EIGHTH_NOTE + SIXTH_NOTE
	rcall play_sound		
	ldi r16, SOUND_a1
	ldi r17, SIXTH_NOTE
	rcall play_sound	
	ldi r16, SOUND_g1
	ldi r17, EIGHTH_NOTE
	rcall play_sound	
	ldi r16, SOUND_e1
	ldi r17, QUARTER_NOTE + EIGHTH_NOTE
	rcall play_sound

	ldi r16, SOUND_d2
	ldi r17, QUARTER_NOTE
	rcall play_sound
	ldi r16, SOUND_d2
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	ldi r16, SOUND_h1
	ldi r17, QUARTER_NOTE
	rcall play_sound							
	ldi r16, SOUND_h1
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	
	ldi r16, SOUND_c2
	ldi r17, QUARTER_NOTE
	rcall play_sound				
	ldi r16, SOUND_c2
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	ldi r16, SOUND_g1
	ldi r17, QUARTER_NOTE + EIGHTH_NOTE
	rcall play_sound		
	
	ldi r18, 2
	loop_26576:
		ldi r16, SOUND_a1
		ldi r17, QUARTER_NOTE
		rcall play_sound
		ldi r16, SOUND_a1
		ldi r17, EIGHTH_NOTE
		rcall play_sound
		ldi r16, SOUND_c2
		ldi r17, EIGHTH_NOTE + SIXTH_NOTE
		rcall play_sound
		ldi r16, SOUND_h1
		ldi r17, SIXTH_NOTE
		rcall play_sound
		ldi r16, SOUND_a1
		ldi r17, EIGHTH_NOTE
		rcall play_sound
		
		ldi r16, SOUND_g1
		ldi r17, EIGHTH_NOTE + SIXTH_NOTE
		rcall play_sound				
		ldi r16, SOUND_a1
		ldi r17, SIXTH_NOTE
		rcall play_sound
		ldi r16, SOUND_g1
		ldi r17, EIGHTH_NOTE
		rcall play_sound
		ldi r16, SOUND_e1
		ldi r17, QUARTER_NOTE
		rcall play_sound
		ldi r16, SOUND_g1
		ldi r17, EIGHTH_NOTE
		rcall play_sound
		
		dec r18
		brne loop_26576
	nop
	
	ldi r16, SOUND_d2
	ldi r17, QUARTER_NOTE
	rcall play_sound
	ldi r16, SOUND_d2
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	ldi r16, SOUND_f2
	ldi r17, EIGHTH_NOTE + SIXTH_NOTE
	rcall play_sound
	ldi r16, SOUND_d2
	ldi r17, SIXTH_NOTE
	rcall play_sound
	ldi r16, SOUND_h1
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	
	ldi r16, SOUND_c2
	ldi r17, EIGHTH_NOTE + QUARTER_NOTE
	rcall play_sound
	ldi r16, SOUND_c2
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	ldi r16, QUARTER_NOTE
	rcall superlong
	
	ldi r16, SOUND_c2
	ldi r17, EIGHTH_NOTE + SIXTH_NOTE
	rcall play_sound
	ldi r16, SOUND_g1
	ldi r17, SIXTH_NOTE
	rcall play_sound
	ldi r16, SOUND_e1
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	ldi r16, SOUND_g1
	ldi r17, EIGHTH_NOTE + SIXTH_NOTE
	rcall play_sound
	ldi r16, SOUND_f1
	ldi r17, SIXTH_NOTE
	rcall play_sound
	ldi r16, SOUND_d1
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	
	ldi r16, SOUND_c1
	ldi r17, EIGHTH_NOTE + QUARTER_NOTE
	rcall play_sound
	ldi r16, SOUND_c1
	ldi r17, EIGHTH_NOTE
	rcall play_sound
	ldi r16, QUARTER_NOTE
	rcall superlong
	
	pop r16
	out SREG, r16
	pop r18
	pop r17
	pop r16
ret



























