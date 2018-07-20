;-------------------------------------------------------------------------
;
;  main.s
;  A2NoSlotMidi
;
;  Created by Eric Rangell on 7/17/18.
;-------------------------------------------------------------------------
; APPLE MIDI DRIVER THROUGH ANNUNCIATOR 0
; Copyright © 1998-2018 Eric Rangell. MIT License.
;-------------------------------------------------------------------------
; THIS DRIVER IMPLEMENTS ASYNCHRONOUS SERIAL DATA TRANSMISSION
; THROUGH THE APPLE ANNUNCIATOR 0 OUTPUT PORT OF THE GAME CONNECTOR
; USING 32 CYCLES PER BIT TO ACHIEVE A 31.25K MIDI BAUD RATE.
;
; THE OUTPUT IS INITIALIZED TO A HIGH LOGIC VOLTAGE.  WHEN IT GOES
; LOW FOR 32 MICROSECONDS, THAT INDICATES THE START BIT OF A MIDI BYTE.
; THEN 8 BYTES OF DATA ARE TRANSMITTED, FOLLOWED BY A HIGH STOP BIT.
; THE DATA BYTES REPRESENT MIDI MESSAGES WHICH CAN BE INTERPRETED BY
; ANY MUSICAL INSTRUMENT THAT IMPLEMENTS MIDI.
;
; ENTRY POINTS: (Note: Origin must be set in Makefile)
;
; $9000 = INITIALIZE - TURNS ON ANNUNCIATOR 0 - MUST BE CALLED ONCE
; $9003 = APPLESOFT CALL TO SEND ONE MIDI BYTE.  POKE THE BYTE IN $9004.
; $9005 = ASSEMBLY CALL TO SEND ONE MIDI BYTE FROM ACCUMULATOR
; $9008 = APPLESOFT OR ASSEMBLY CALL TO SEND SEVERAL BYTES AT ONCE:
;         THE CALLER POPULATES LOCATION $D7 WITH THE NUMBER OF BYTES TO BE
;         TRANSMITTED, AND A POINTER IN $CE,CF (LO,HI) WITH THE ADDRESS OF
;         THE DATA BYTES, THEN CALLS THE ENTRY POINT "SENDMSG" TO TRANSMIT
;         THE MESSAGE.
; $900B = SEND A TEST MESSAGE - C MAJOR CHORD NOTE ONS
; $900E = SEND A TEST MESSAGE - C MAJOR CHORD NOTE OFFS
; $9011 = RESERVED
; $9014 = RESERVED
; $9017 = RESERVED
;-------------------------------------------------------------------------
; Enhancements for 2018:
; 1. Disable interrupts during critical timing sections, preserve interrupt status
; 2. Entry point to reconfigure program to use a different annunciator pair
; 3. Entry point to reconfigure program for hardware interface using inverters only (not buffers)
;-------------------------------------------------------------------------
; CALLER MUST POPULATE THE FOLLOWING TWO ZERO PAGE LOCATIONS FOR SENDMSG:
NUMBYTES = $D7             ;NUMBER OF BYTES TO BE TRANSMITTED NOW (1-256)
;                          ;THE VALUE 0 WILL TRANSMIT 256 BYTES.
DATAPTR  = $CE             ;POINTER TO THE BYTES TO BE TRANSMITTED NOW
;-------------------------------------------------------------------------
AN0OFF   = $C058           ;APPLE ADDRESSES THAT CONTROL ANNUNCIATOR OUTPUTS
AN0ON    = $C059           ;PROGRAM REFERNCES ARE RELATIVE TO AN0
;AN1OFF   = $C05A
;AN1ON    = $C05B
;AN2OFF   = $C05C
;AN2ON    = $C05D
;AN3OFF   = $C05E
;AN3ON    = $C05F
;-------------------------------------------------------------------------
.proc main
;---------------------------------------------------------------------------
START:
        JMP INIT            ;MAIN ENTRY POINT - INITIALIZES ANNUNCIATORS
SENDFP:
        LDA #$90            ;ENTRY POINT FOR APPLESOFT: POKE BYTE AND CALL
SENDONE:
        JMP XMITONE         ;ENTRY POINT FOR TRANSMITTING ONE BYTE FROM ACCUM
SENDMSG:
        JMP XMITMSG         ;ENTRY POINT FOR TRANSMITTING A MIDI MESSAGE
ALLNOFF:
        JMP QUIET           ;TURN ALL NOTES OFF
TEST1:
        JMP TESTMSG1        ;SEND TEST MESSAGE 1 - C MAJOR CHORD ON
TEST2:
        JMP TESTMSG2        ;SEND TEST MESSAGE 2 - C MAJOR CHORD OFF
        ;
        ;RSRVD1:
        ;JMP INIT
        ;RSRVD2:
        ;JMP INIT
        ;RSRVD3:
        ;JMP INIT
;---------------------------------------------------------------------------
SAVENBYT: .byte $00             ;SAVE AREA FOR NUMBYTES
TEMPA:    .byte $00
TEMPX:    .byte $00
;ANNPAIR:  .byte  $00            ; ANNUNCIATOR NUMBER TIMES 2 (1=C05A, 2=C05C, 3=C05E)
;---------------------------------------------------------------------------
INIT:
        BIT AN0ON
        RTS
;---------------------------------------------------------------------------
XMITMSG:
        LDA NUMBYTES        ;SAVE NUMBER OF BYTES
        STA SAVENBYT        ;BECAUSE WE WILL CLOBBER IT
        LDY #$00            ;Y WILL BE AN INDEX INTO THE DATA AREA
XMITLOOP:
        LDA (DATAPTR),Y     ;GET A DATA BYTE
        JSR XMITONE
        INY                 ;POINT TO NEXT BYTE
        DEC NUMBYTES        ;DECREMENT COUNTER
        LDA NUMBYTES        ;CHECK IF ZERO
        BNE XMITLOOP        ;LOOP UNTIL DONE SENDING ALL BYTES
        LDA SAVENBYT
        STA NUMBYTES        ;RESTORE ORIGINAL VALUE OF NUMBYTES
        RTS
;---------------------------------------------------------------------------
XMITONE:
        STA TEMPA           ;SAVE A AND X REGISTERS
        STX TEMPX
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT7+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT6+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT5+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT4+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT3+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT2+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00            ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT1+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        ASL A               ;SHIFT BIT INTO CARRY
        TAX                 ;SAVE CURRENT IMAGE OF DATA BYTE
        LDA #$00             ;ZERO OUT ACCUMULATOR FOR ADD
        ADC #<AN0OFF        ;ADD CARRY TO ANNUNCIATOR ADDRESS
        STA BIT0+1          ;MODIFY THE XMITBITS SUBROUTINE
        TXA                 ;RESTORE ACCUMULATOR
;
        JSR XMITBITS        ;SEND THE BYTE OUT
        LDX TEMPX
        LDA TEMPA           ;RESTORE X AND A
        RTS
;-----------------------------------------------------------------------
XMITBITS:
        BIT AN0OFF          ;4 CYCLES - TRANSMIT START BIT - ALWAYS LOW
        JSR DELAY22         ;6+22
BIT0:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT1:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT2:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT3:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT4:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT5:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT6:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
BIT7:
        BIT AN0OFF          ;4
        JSR DELAY22         ;6+22
        BIT AN0ON           ;4        ;TRANSMIT STOP BIT - ALWAYS HIGH
        JSR DELAY22         ;6+22
        RTS
;-----------------------------------------------------------------------
DELAY22:
        NOP       ;WAIT 22 CYCLES
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        RTS
;-----------------------------------------------------------------------
TESTMSG1:
        LDA #7
        STA NUMBYTES
        LDA #<TESTDAT1
        STA DATAPTR
        LDA #>TESTDAT1
        STA DATAPTR+1
        JSR SENDMSG
        RTS
;-----------------------------------------------------------------------
TESTMSG2:
        LDA #7
        STA NUMBYTES
        LDA #<TESTDAT2
        STA DATAPTR
        LDA #>TESTDAT2
        STA DATAPTR+1
        JSR SENDMSG
        RTS
;-----------------------------------------------------------------------
QUIET:
        LDA #$90
        STA NUMBYTES
        LDA #<QUIETMSG
        STA DATAPTR
        LDA #>QUIETMSG
        STA DATAPTR+1
        JSR SENDMSG
        RTS
;-----------------------------------------------------------------------
TESTDAT1:
    .byte $90,$3C,$40,$40,$40,$43,$40
TESTDAT2:
    .byte $90,$3C,$00,$40,$00,$43,$00
QUIETMSG:
    .byte $B0,$78,$00,$B0,$79,$00,$B0,$7B,$00
    .byte $B1,$78,$00,$B1,$79,$00,$B1,$7B,$00
    .byte $B2,$78,$00,$B2,$79,$00,$B2,$7B,$00
    .byte $B3,$78,$00,$B3,$79,$00,$B3,$7B,$00
    .byte $B4,$78,$00,$B4,$79,$00,$B4,$7B,$00
    .byte $B5,$78,$00,$B5,$79,$00,$B5,$7B,$00
    .byte $B6,$78,$00,$B6,$79,$00,$B6,$7B,$00
    .byte $B7,$78,$00,$B7,$79,$00,$B7,$7B,$00
    .byte $B8,$78,$00,$B8,$79,$00,$B8,$7B,$00
    .byte $B9,$78,$00,$B9,$79,$00,$B9,$7B,$00
    .byte $BA,$78,$00,$BA,$79,$00,$BA,$7B,$00
    .byte $BB,$78,$00,$BB,$79,$00,$BB,$7B,$00
    .byte $BC,$78,$00,$BC,$79,$00,$BC,$7B,$00
    .byte $BD,$78,$00,$BD,$79,$00,$BD,$7B,$00
    .byte $BE,$78,$00,$BE,$79,$00,$BE,$7B,$00
    .byte $BF,$78,$00,$BF,$79,$00,$BF,$7B,$00
;----------------
; END OF PROGRAM
;----------------
.endproc
