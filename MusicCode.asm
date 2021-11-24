 #include "p16F628a.inc"    ;incluir librerias relacionadas con el dispositivo
 __CONFIG _FOSC_INTOSCCLK & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF    
;configuración del dispositivotodo en OFF y la frecuencia de oscilador
;es la del "reloj del oscilador interno" (INTOSCCLK)     
RES_VECT  CODE    0x0000; processor reset vector
    GOTO    START                   ; go to beginning of program

INT_VECT  CODE	  0x0004
    GOTO ISR
    
    ; TODO ADD INTERRUPTS HERE IF USED
MAIN_PROG CODE                      ; let linker place main program
;variables para el contador:
i equ 0x30
j equ 0x31
k equ 0x32
NOTA equ 0x34
AUX equ 0x35
i1 equ 0x36
j1 equ 0x37
k1 equ 0x38
x equ 0x40
y equ 0x41
z equ 0x42
a equ 0x43
d equ 0x44
c equ 0x45

CNT equ 0x33
;inicio del programa: 
START
    MOVLW d'0'
    MOVWF NOTA
    MOVLW 0x07 ;Apagar comparadores
    MOVWF CMCON
    MOVLW b'10100000'
    MOVWF INTCON 
    BCF STATUS, RP1 ;Cambiar al banco 1
    BSF STATUS, RP0 
    MOVLW b'00000000'
    MOVWF TRISA
    MOVLW b'00000000'
    MOVWF TRISB 
    movlw b'10000111' ;!!! configuración de la prescaler en 1:256
    movwf OPTION_REG  ;!!! dentro del banco 1
    BCF STATUS, RP0 ;Regresar al banco 0

    			; setup registers		
			; setp TMR0 operation
			; internal clock, pos edge, prescale 256
  
			; setup TMR0 INT, 
			; must be cleared after interrupt
			; 256uS * 195 =~ 50mS
			; 255 - 195 = 60
    MOVLW D'120'	; preload value
    MOVWF TMR0
    MOVLW D'3'		; 50mS * 20 = 1 Sec.
    MOVWF CNT
    
    CLRF PORTA
    CLRF PORTB
    
INITLCD
    BCF PORTA,0		;reset
    MOVLW 0x01
    MOVWF PORTB
    
    BSF PORTA,1		;exec
    CALL time
    BCF PORTA,1
    CALL time
    
    MOVLW 0x0C		;first line
    MOVWF PORTB
    
    BSF PORTA,1		;exec
    CALL time
    BCF PORTA,1
    CALL time
         
    MOVLW 0x3C		;cursor mode
    MOVWF PORTB
    
    BSF PORTA,1		;exec
    CALL time
    BCF PORTA,1
    CALL time
    CALL winfo
    goto inicio
    
       
inicio:	
    BSF PORTA, 7
    CALL TIEMPO
    BCF PORTA, 7
    CALL TIEMPO
    goto inicio  ;regresar y repetir
  
;rutina de tiempo

    
    
TIEMPO:  
    movfw i1 ;establecer valor de la variable i
    movwf i
iloop:
    movfw j1 ;establecer valor de la variable j
    movwf j
jloop:	       
    movfw k1 ;establecer valor de la variable k
    movwf k
kloop:	
    decfsz k,f  
    goto kloop
    decfsz j,f
    goto jloop
    decfsz i,f
    goto iloop
    return
    
    
TIEMPO_SIL: 
    movlw d'10' ;establecer valor de la variable i
    movwf x
xloop:
    movlw d'10' ;establecer valor de la variable j
    movwf y
yloop:	       
    movlw d'100' ;establecer valor de la variable k
    movwf z
zloop:	
    decfsz z,f  
    goto zloop
    decfsz y,f
    goto yloop
    decfsz x,f
    goto xloop
    return    
    
fa
    MOVLW d'4'
    MOVWF i1
    MOVLW d'6'
    MOVWF j1
    MOVLW d'18'
    MOVWF k1
    RETURN
sol
    MOVLW d'4'
    MOVWF i1
    MOVLW d'5'
    MOVWF j1
    MOVLW d'19'
    MOVWF k1
    RETURN

la
    MOVLW d'4'
    MOVWF i1
    MOVLW d'5'
    MOVWF j1
    MOVLW d'17'
    MOVWF k1
    RETURN
    
si 
    MOVLW d'4'
    MOVWF i1
    MOVLW d'5'
    MOVWF j1
    MOVLW d'16'
    MOVWF k1
    RETURN
    
do
    MOVLW d'4'
    MOVWF i1
    MOVLW d'5'
    MOVWF j1
    MOVLW d'14'
    MOVWF k1
    RETURN
  
do4
    MOVLW d'5'
    MOVWF i1
    MOVLW d'6'
    MOVWF j1
    MOVLW d'20'
    MOVWF k1
    RETURN
    
re
    MOVLW d'4'
    MOVWF i1
    MOVLW d'4'
    MOVWF j1
    MOVLW d'16'
    MOVWF k1
    RETURN
    
ISR: 
    
    BCF INTCON, GIE
    DECFSZ CNT 
    GOTO $+7

    INCF NOTA
    CALL NOTAS
    
    MOVLW D'3' ; 50mS * value
    MOVWF CNT
		    ; 256uS * 195 =~ 50mS
		    ; 255 - 195 = 60
    MOVLW D'120' ; preload value
    MOVWF TMR0
    
    BCF INTCON, T0IF ;Clear external interrupt flag bit
    BSF INTCON, GIE ;Enable all interrupts on exit
    retfie  ; return from interrupt
    
	
NOTAS
    MOVFW NOTA
    MOVWF AUX
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    CALL wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wsol
    GOTO sol
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO sol
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wla
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wsol
    GOTO sol
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO sol
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wla
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
   
    
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wla
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wsi
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wla
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wsi
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wre
    GOTO re
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wsi
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wla
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    ;Segundo
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wre
    GOTO re
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wsi
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO si
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wla
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO la
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
; ultimo
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo4
    GOTO do4
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do4
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wdo4
    GOTO do4
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO do4
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+3
    call wfa
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    
    DECF AUX
    BTFSS STATUS, Z
    GOTO $+2
    GOTO fa
    GOTO $
    
    MOVLW D'0'
    MOVWF NOTA
    
    
    return
    
    exec

    BSF PORTA,1		;exec
    CALL time
    BCF PORTA,1
    CALL time
    RETURN
    
time
    CLRF a
    MOVLW d'10'
    MOVWF c
ciclo    
    MOVLW d'80'
    MOVWF a
    DECFSZ a
    GOTO $-1
    DECFSZ c
    GOTO ciclo
    RETURN
    
    
wfa
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'F'
    MOVWF PORTB
    CALL exec 

    MOVLW '4'
    MOVWF PORTB
    CALL exec
    RETURN
    
  wsol
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'G'
    MOVWF PORTB
    CALL exec 

    MOVLW '4'
    MOVWF PORTB
    CALL exec
   
    RETURN
    
    wla
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'A'
    MOVWF PORTB
    CALL exec 

    MOVLW '#'
    MOVWF PORTB
    CALL exec
    RETURN
    
    wsi
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'B'
    MOVWF PORTB
    CALL exec 

    MOVLW '4'
    MOVWF PORTB
    CALL exec
    RETURN
    
    wdo
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'C'
    MOVWF PORTB
    CALL exec 

    MOVLW '5'
    MOVWF PORTB
    CALL exec
    RETURN
    
    wdo4
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'C'
    MOVWF PORTB
    CALL exec 

    MOVLW '4'
    MOVWF PORTB
    CALL exec
    RETURN
    
    wre
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0xC0	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'D'
    MOVWF PORTB
    CALL exec 

    MOVLW '4'
    MOVWF PORTB
    CALL exec
    RETURN
    
winfo
    BCF PORTA,0		;command mode
    CALL time
    
    MOVLW 0x80	;LCD position
    MOVWF PORTB
    CALL exec
    
    BSF PORTA,0		;data mode
    CALL time
    
    MOVLW 'M'
    MOVWF PORTB
    CALL exec 

    MOVLW 'A'
    MOVWF PORTB
    CALL exec
    
    MOVLW 'R'
    MOVWF PORTB
    CALL exec 
    
    MOVLW 'T'
    MOVWF PORTB
    CALL exec 

    MOVLW 'I'
    MOVWF PORTB
    CALL exec
    
    MOVLW 'N'
    MOVWF PORTB
    CALL exec 

    MOVLW 'I'
    MOVWF PORTB
    CALL exec
    
    MOVLW 'L'
    MOVWF PORTB
    CALL exec 

    MOVLW 'L'
    MOVWF PORTB
    CALL exec
    
    MOVLW 'O'
    MOVWF PORTB
    CALL exec
    
    RETURN
    
    END