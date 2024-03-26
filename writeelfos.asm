#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      writeelfos

              extrn     buffer
              extrn     fildes
              extrn     load_ra
              extrn     load_rb
              extrn     highest
              extrn     lowest
              extrn     outputname
              extrn     readmem
              extrn     startaddr
              extrn     writebin

              mov       rf,outputname  ; point to output filename
              mov       rd,fildes      ; point to fildes
              mov       r7,11          ; create/truncate/executable flags
              call      o_open         ; open the file
              lbnf      opened
              call      o_inmsg        ; display error
              db        'Could not open output file: ',0
              mov       rf,outputname
              call      o_msg
              call      o_inmsg
              db        10,13,0
              rtn                      ; return to caller
opened:       mov       rf,buffer      ; point to output buffer
              hlpr      load_rb,lowest ; need lowest value
              ghi       rb             ; write to buffer
              str       rf
              inc       rf
              glo       rb
              str       rf
              inc       rf
              hlpr      load_ra,highest ; need highest-lowest+1
              glo       rb
              str       r2
              glo       ra
              sm
              plo       rb
              ghi       rb
              str       r2
              ghi       ra
              smb
              phi       rb
              inc       rb
              ghi       rb             ; write to buffer
              str       rf
              inc       rf
              glo       rb
              str       rf
              inc       rf
              hlpr      load_rb,startaddr ; get start address
              ghi       rb             ; write to buffer
              str       rf
              inc       rf
              glo       rb
              str       rf
              mov       rf,buffer      ; write header to disk
              mov       rd,fildes
              mov       rc,6
              call      o_write
              lbr       writebin       ; then use writebinary

              endp

