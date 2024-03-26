#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      writercs

              extrn     buffer
              extrn     fildes
              extrn     highest
              extrn     load_ra
              extrn     load_rb
              extrn     load_rd
              extrn     lowest
              extrn     outputname
              extrn     readmem
              extrn     startaddr
              extrn     writeln

              mov       rf,outputname  ; point to output filename
              mov       rd,fildes      ; point to file descriptor
              mov       r7,3           ; create/trunc flags set
              call      o_open         ; open the file
              lbnf      opened         ; jump if file opened
              call      o_inmsg        ; display error
              db        'Could not open output file: ',0
              mov       rf,outputname
              call      o_msg
              call      o_inmsg
              db        10,13,0
              rtn                      ; return to caller
opened:       hlpr      load_ra,lowest ; point to lowest
next_line:    mov       rf,buffer
              ldi       ':'            ; write marker to buffer
              str       rf
              inc       rf
              ldi       0              ; clear count
              plo       rc
              mov       rd,ra          ; move address for conversion
              call      f_hexout4
loop:         hlpr      load_rb,highest ; get highest value
              glo       ra             ; highest - address
              str       r2
              glo       rb
              sm
              ghi       ra
              str       r2
              ghi       rb
              smb
              lbnf      done           ; jump if address now higher than highest
              call      readmem        ; read memory for current address
              inc       ra             ; increment address
              plo       rd             ; move for conversion
              ldi       ' '            ; write a space to the buffer
              str       rf
              inc       rf
              call      f_hexout2      ; write value to buffer
              inc       rc             ; increment counter
              glo       rc
              smi       16             ; see if full line
              lbnz      loop           ; loop if not
              ldi       0              ; terminte buffer
              str       rf
              mov       rf,buffer      ; point back to buffer
              mov       rd,fildes      ; point to fildes
              call      writeln        ; write line
              lbr       next_line      ; then setup for next line
done:         glo       rc             ; see if any bytes written
              lbz       finished       ; jump if not
              ldi       0              ; terminate buffer
              str       rf
              mov       rf,buffer      ; point to buffer
              mov       rd,fildes      ; point to fildes
              call      writeln        ; write the line
finished:     mov       rf,buffer      ; point to buffer
              ldi       '@'            ; write start marker
              str       rf
              inc       rf
              hlpr      load_rd,startaddr ; get start addres
              call      f_hexout4      ; convert to ascii hex
              ldi       0              ; terminate string
              str       rf
              mov       rf,buffer      ; now setup for write
              mov       rd,fildes
              call      writeln        ; write it out
              mov       rd,fildes      ; point to fildes
              call      o_close        ; close the file
              rtn                      ; and return to caller

              endp

