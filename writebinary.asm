#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      writebinary

              extrn     buffer
              extrn     fildes
              extrn     load_ra
              extrn     load_rb
              extrn     highest
              extrn     lowest
              extrn     outputname
              extrn     readmem

              mov       rf,outputname  ; point to output filename
              mov       rd,fildes      ; point to fildes
              mov       r7,3           ; create/truncate flags
              call      o_open         ; open the file
              lbnf      opened
              call      o_inmsg        ; display error
              db        'Could not open output file: ',0
              mov       rf,outputname
              call      o_msg
              call      o_inmsg
              db        10,13,0
              rtn                      ; return to caller
opened:
writebin:     hlpr      load_ra,lowest ; get lowest address
              mov       rf,buffer      ; point to buffer
              mov       rc,0           ; set count to zero
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
              str       rf             ; store into buffer
              inc       rf
              inc       rc             ; increment count
              inc       ra             ; increment address
              glo       rc             ; check for full buffer
              smi       128
              lbnz      loop           ; loop until buffer full
              mov       rf,buffer      ; write buffer to output file
              mov       rd,fildes
              mov       rc,128
              call      o_write
              mov       rf,buffer      ; reset pointers
              mov       rc,0
              lbr       loop           ; and loop until done
done:         glo       rc             ; any bytes remaining in buffer
              lbz       finished       ; jump if not
              mov       rf,buffer      ; point to buffer
              mov       rd,fildes
              call      o_write        ; write remaining bytes
finished:     mov       rd,fildes      ; close the file
              call      o_close
              rtn                      ; and return to caller
 
              public    writebin

              endp

