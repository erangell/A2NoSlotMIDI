# A2NoSlotMIDI - latest DSK images 

See the SRC directory for information on how the ANN0TEST.DSK image is created.

Note: An updated disk image that plays MIDI through Annunciator 2 and includes a drum program is available here:
https://github.com/erangell/kfest2020/blob/master/hackfest/src/Apple2/ANN2MIDI2020.dsk


If you want to play MIDI files on a different disk, rename the volume of ANN0TEST.DSK to something other than /MIDI (ex: /MIDI0), and rename the volume of the disk that contains the MIDI files to /MIDI.


Each MIDI file should have a type of $D7 and a suffix of .MID


The program "CHANGETYPE" can be used to change the type of a file.


TEST PLAN:


GIVEN wiring has 2 inverters (positive logic), and MIDI OUT circuit is hooked up to AN0

WHEN you boot the DSK and select option 1 (Test MIDI OUT)  

THEN chord plays on a connected MIDI instrument


GIVEN 9018:02

WHEN 9000G

THEN BRK is hit, displays address 9026

WHEN 9003G

THEN BRK is hit, displays address 90A2


GIVEN 9018:01, and wiring has 1 inverter (negative logic) and MIDI OUT circuit is hooked up to AN0

WHEN 900EG

THEN plays a chord on the connected MIDI Instrument


GIVEN negative logic MIDI OUT circuit

WHEN 

LOAD TESTCHORD

15 POKE 9*4096+16+8,1 : CALL 9*4096

RUN

THEN chord plays on connected MIDI instrument


GIVEN midi out circuit is connected to AN1

WHEN

9017:01

9014G

900EG N 9011G

THEN short duration chord plays on connected MIDI instrument


GIVEN midi out circuit is connected to AN2

WHEN

9017:02

9014G

900EG N 9011G

THEN short duration chord plays on connected MIDI instrument


GIVEN midi out circuit is connected to AN3

WHEN

9017:03

9014G

900EG N 9011G

THEN short duration chord plays on connected MIDI instrument


GIVEN midi out circuit can play a chord

WHEN 

900EG N 900BG

THEN very short duration chord plays on connected MIDI instrument (due to all sounds off message)


GIVEN midi out circuit can play a chord, and driver is loaded at $9000

WHEN you enter the following Applesoft BASIC program and run it

10 P=36868: M=36867 : REM P=ADDRESS TO POKE MIDI BYTE, M=CALL TO MIDI OUT DRIVER

20 FOR N = 60 TO 72 : REM NOTE NUMBERS FOR MIDDLE C THRU ONE OCTAVE ABOVE MIDDLE C

30 POKE P,144: CALL M: REM 144 (0X90) IS THE MIDI MESSAGE FOR NOTE ON

40 POKE P,N: CALL M: REM FIRST DATABYTE OF NOTE ON MESSAGE IS NOTE NUMBER

50 POKE P,64: CALL M: REM SECOND DATABYTE IS VELOCITY OF KEYPRESS (0=127)

60 FOR DE=1 TO 250: NEXT : REM DELAY LOOP

70 POKE P,N : CALL M : REM USING RUNNING STATUS - MESSAGE IS STILL NOTE ON, BUT NEW DATABYTES

80 POKE P,0: CALL M : REM VELOCITY OF 0 TURNS A NOTE OFF

90 NEXT N: REM REPEAT FOR EACH NOTE IN CHROMATIC SCALE


THEN you hear a chromatic scale played on your MIDI instrument.

