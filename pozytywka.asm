; ******************************************************
; BASIC .ASM template file for AVR
; ******************************************************

.include "C:\PROGRA~2\VMLAB\include\m16def.inc"

; Wizja:
; Ka¿dy utwór jest whardcodowany jako funkcja 
; Jest jakies GUI na LCD, które wyswietla nr utworu i jego nazwe
; SW7 - poprzedni utwór
; SW6 - nastêpny utwór
; SW5 - graj/przestañ

; Najprostrze rozwi¹zanie - dowolny przycisk wywo³uje przerwanie, ktore przerywa utwor i obsluguje przycisk
; Drugie rozwiazanie - Gdy grany jest utwor wylaczane jest przerwanie SW7 i SW6
; Trzecie rozwiazanie - obslugiwanie przerwania SW7 i SW6 nie przerywa utworu, a wykonuje sie w czasie przerwy pomiedzy nutami

; LCD:
; Pierwsze rozwiazanie - dwa wiersze ekranu sa zarezerwowane dla jedengo utworu
; Drugie rozwiazanie - Wyswietlamy aktywny utwor w pierwszej lini, a w drugiej nastepny

; Define here the variables
;
.def  temp  =r16
.equ SPEAKER_DDR = DDRB
.equ SPEAKER_P = PB3
.equ SPEAKER_PORT = PORTB

	;   D³ugoœæ nuty 		1,6 s		1600 taktów longdelay
	;   D³ugoœæ pó³nuty 	0,8 s 	800  taktow longdelay
	;	 D³ugoœæ æwierænuty 0,4 s	400  taktow longdelay
	;	 D³ugoœæ ósemki	0,2 s		200  taktow longdelay
	;   D³ugoœæ szesnastki 0,1 s  2    takty longlongdelay
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

; Define here Reset and interrupt vectors, if any
;
reset:
   rjmp start
   reti      ; Addr $01
   reti      ; Addr $02
   reti      ; Addr $03
   reti      ; Addr $04
   reti      ; Addr $05
   reti      ; Addr $06        Use 'rjmp myVector'
   reti      ; Addr $07        to define a interrupt vector
   reti      ; Addr $08
   reti      ; Addr $09
   reti      ; Addr $0A
   reti      ; Addr $0B        This is just an example
   reti      ; Addr $0C        Not all MCUs have the same
   reti      ; Addr $0D        number of interrupt vectors
   reti      ; Addr $0E
   reti      ; Addr $0F
   reti      ; Addr $10

; Program starts here after Reset
;
start:
   nop       ; Initialize here ports, stack pointer,
   nop       ; cleanup RAM, etc.
   nop       ;
   nop       ;

   ; Initialize the stack
   LDI R20, HIGH (RAMEND)
   OUT SPH, R20
   LDI R20, LOW (RAMEND)
   OUT SPL, R20

	; Configure speaker
	sbi SPEAKER_DDR, SPEAKER_P
	cbi SPEAKER_PORT, SPEAKER_P
	
	; Configure counter
	sbi DDRB, PB3
	;   Preskaler:
	;   CS02 CS01 CS00
	;   0    0    0     licznik zatrzymany
	;   0    0    1     clk
	;   0    1    0     clk/8
	;   0    1    1     clk/64
	;   1    0    0     clk/256
	;   1    0    1     clk/1024
;	ldi r16, 1 << WGM01 | 1 << CS02 | 1 << COM00
;	out TCCR0, r16

	ldi r16, 1 << OCIE0
	out TIMSK, r16
	
	; Cicha noc
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
	rcall longlongdelay
	
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
	rcall longlongdelay

forever:
   nop
   nop       ; Infinite loop.
   nop       ; Define your main system
   nop       ; behaviour here
rjmp forever

trigger_speaker:
	push r16
	in r16, SREG
	push r16
	
	in r16, PINB
	sbrc r16, PB3
	cbi SPEAKER_PORT, SPEAKER_P
	sbrs r16, PB3
	sbi SPEAKER_PORT, SPEAKER_P
	
	pop r16
	out SREG, r16
	pop r16
reti

; r16 - czêstotliwoœæ	r17 - d³ugoœæ nutki
play_sound:
	push r18
	in r18, SREG
	push r18
	
	out OCR0, r16
	ldi r18, 1 << WGM01 | 1 << CS02 | 1 << COM00
	out TCCR0, r18
	
	mov r16, r17
	rcall longlongdelay
	
	ldi r18, 1 << WGM01 | 1 << COM00
	out TCCR0, r18
	ldi r18, 0
	out PINB, r18
	ldi r16, 70
	rcall longdelay
	
	pop r18
	out SREG, r18
	pop r18
ret

; 0.0088ms = 8.8us
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
		BRNE loop_16
	POP R18
	POP R17
ret

;50ms = 50 000us
; r16 - ilosc obrotow
longlongdelay:
	push r17
	in r17, SREG
	push r17
	
	mov r17, r16
	loop_64352:
		ldi r16, 50
		rcall longdelay
		dec r17
		brne loop_64352
	nop
	
	pop r17
	out SREG, r17
	pop r17
ret



