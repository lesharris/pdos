DD=dd
CL65=cl65
AC=AppleCommander.jar
ADDR=2000

PGM=pdos

APPLEWIN=D:/Emu/applewin/Applewin.exe
EMULATOR=$(APPLEWIN) -d1 $(PGM).dsk

all: $(PGM)

run: all
	$(EMULATOR)
	
$(PGM):
	$(CL65) -t apple2enh --start-addr $(ADDR) -o$(PGM).out -l$(PGM).lst $(PGM).s
	$(DD) if=$(PGM).out of=$(PGM) bs=1 skip=4 iflag=skip_bytes
	java -jar $(AC) -d $(PGM).dsk $(PGM)
	java -jar $(AC) -p $(PGM).dsk $(PGM) BIN 0x$(ADDR) < $(PGM)
	$(RM) $(PGM).out
	$(RM) $(PGM).o
	$(RM) $(PGM)

clean:
	rm -f $(PGM)
	rm -f $(PGM).o
	rm -f $(PGM).lst