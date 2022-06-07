; When assembly code is placed in a psect, it can be manipulated as a
; whole by the linker and placed in memory.  
;
; In this example, barfunc is the program section (psect) name, 'local' means
; that the section will not be combined with other sections even if they have
; the same name.  class=CODE means the barfunc must go in the CODE container.
; PIC18's should have a delta (addressible unit size) of 1 (default) since they
; are byte addressible.  PIC10/12/16's have a delta of 2 since they are word
; addressible.  PIC18's should have a reloc (alignment) flag of 2 for any
; psect which contains executable code.  PIC10/12/16's can use the default
; reloc value of 1.  Use one of the psects below for the device you use:

;psect   barfunc,local,class=CODE,delta=2 ; PIC10/12/16

#include <xc.inc>
    
; CONFIG
    CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator)
    CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
    CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
    CONFIG  BOREN = OFF           ; Brown-out Reset Enable bit (BOR disabled)
    CONFIG  LVP = OFF             ; Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
    CONFIG  CPD = OFF             ; Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
    CONFIG  WRT = OFF             ; Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
    CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)  

    
DELAY_A equ 0x70
DELAY_B equ 0x71
DELAY_C equ 0x72

psect   RESET_VECT,class=CODE,delta=2 ; PIC10/12/16
RESET_VECT:
    goto setup
    
psect   INT_VECT,class=CODE,delta=2 ; PIC10/12/16
INT_VECT:   
    retfie
setup:
    bsf STATUS,5 ;select bank 1
    CLRF TRISB
    bcf STATUS,5 ;select bank 0
    CLRF PORTB    
    
    movlw 0x01
    movwf PORTB
    bcf STATUS,0 ;select bank 0
main:
    RLF PORTB,1
    call delay_100ms
    call delay_100ms
    ;movlw 2;
    ;movwf PORTB
    ;call delay_100ms
    ;call delay_100ms
    ;movlw 0x00;
    ;movwf PORTB
    ;call delay_100ms
    ;call delay_100ms
    goto main
    
delay_100ms:
    movlw 0xFF ;255
    movwf DELAY_A
delay_a:
    call delay_nest_b
    decfsz DELAY_A
    goto delay_a
    return
delay_nest_b:
    movlw 112
    movwf DELAY_B
delay_b:
    call delay_nest_c
    decfsz DELAY_B
    goto delay_b
    return
delay_nest_c:
    movlw 2
    movwf DELAY_C
delay_c:
    decfsz DELAY_C
    goto delay_c
    return
    
    END RESET_VECT
    
