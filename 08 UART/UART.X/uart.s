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
TEST_FLAGS equ 0x73 ; bit 0 = RX_DONE
RX_TEMP equ 0x74
W_TEMP equ 0x75

psect   RESET_VECT,class=CODE,delta=2 ; PIC10/12/16
RESET_VECT:
    goto setup
    
psect   INT_VECT,class=CODE,delta=2 ; PIC10/12/16
INT_VECT:
    movwf W_TEMP
    BTFSC PIR1,5
    call uart_rx_isr
    movf W_TEMP,0
    RETFIE
uart_rx_isr:
    movf RCREG,0
    movwf RX_TEMP
    bsf TEST_FLAGS,0
    bcf PIR1,5
    return
setup:
    call uart_init
    bsf STATUS,5 ;select bank 1
    CLRF TRISB
    BSF TRISD,2
    bcf STATUS,5 ;select bank 0
    CLRF PORTB
    movlw (1<<7)
    IORWF INTCON
    bcf STATUS,0 ;clear carry BCF INTCON,0 ; clear int flag

main:
    ;movlw 'A'
    ;movwf TXREG
    ;call uart_tx_done
    
    BTFSC TEST_FLAGS,0
    call uart_echo
    
    goto main

uart_init:
    bsf STATUS,5 ;select bank 1
    movlw 25
    movwf SPBRG
    movlw (1<<7 | 1<<6)
    IORWF TRISC
    bsf TXSTA,5
    bsf PIE1,5
    bcf STATUS,5 ;select bank 0
    movlw (1<<7) | (1<<4)
    IORWF RCSTA
    
    movlw (1<<6)
    IORWF INTCON
    
    return
uart_tx_poll:
    bsf STATUS,5 ;select bank 1
uart_tx_done:
    BTFSC TXSTA,1
    goto uart_tx_done
    bcf STATUS,5 ;select bank 0
    return
uart_echo:
    bcf TEST_FLAGS,0
    movf RX_TEMP,0
    movwf TXREG
    call uart_tx_done
    movwf TRISB
    return