PROJECT = link02
INCDIR=../../Include
LIBDIR=../../Lib
INSTDIR=../../Image/bin
OBJS = \
	checkrange.prg \
	checkvmem.prg \
	commandfile.prg \
	dofixups.prg \
	dropfixup.prg \
	final.prg \
	findsymbol.prg \
	fopen.prg \
	gethex.prg \
	loadfile.prg \
	main.prg \
	processadjust.prg \
	processadvance.prg \
	processdata.prg \
	processdirect.prg \
	processendp.prg \
	processfixup.prg \
	processproc.prg \
	processstart.prg \
	processsymbol.prg \
	readln.prg \
	readmem.prg \
	strcasecmpin.prg \
	tolc.prg \
	trimrf.prg \
	writebinary.prg \
	writeelfos.prg \
	writeintel.prg \
	writeln.prg \
	writemem.prg \
	writercs.prg

.SUFFIXES: .asm .prg

$(PROJECT).bin: $(OBJS)
#	asm02 -l -L -I$(INCDIR) main.asm
	link02 -s -S symbols.sym -e @link.lnk -o $(PROJECT).bin

.asm.prg:
	asm02 -l -L -I$(INCDIR) $<

clean:
	-rm *.prg
	-rm *.bin
	-rm *.lst
	-rm symbols.sym

lists:
	adjlst checkrange.lst checkrange
	adjlst checkvmem.lst checkvmem
	adjlst commandfile.lst commandfile
	adjlst dofixups.lst dofixups
	adjlst final.lst final
	adjlst findsymbol.lst findsymbol
	adjlst gethex.lst gethex
	adjlst loadfile.lst loadfile
	adjlst processadjust.lst processadjust
	adjlst processdata.lst processdata
	adjlst processdirect.lst processdirect
	adjlst processfixup.lst processfixup
	adjlst processstart.lst processstart
	adjlst processsymbol.lst processsymbol
	adjlst readmem.lst readmem
	adjlst writebinary.lst writebinary
	adjlst writemem.lst writemem
	adjlst writeln.lst writeln
	adjlst writercs.lst writercs

install: $(PROJECT).bin
	cp $(PROJECT).bin $(INSTDIR)

