# A2NoSlotMIDI - latest DSK images 

See the SRC directory for information on how the ANN0TEST.DSK image is created.


If you want to play MIDI files on a different disk, rename the volume of ANN0TEST.DSK to something other than /MIDI (ex: /MIDI0), and rename the volume of the disk that contains the MIDI files to /MIDI.


Each MIDI file should have a type of $D7 and a suffix of .MID


The program "CHANGETYPE" can be used to change the type of a file.

2018-JUL-26: Tested MIDIDRVR.OBJ on real hardware - the code to change the Annunciator works.  The Negative Logic does not work yet.
