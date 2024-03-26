#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processfixup

              extrn     gethex
              extrn     load_r8
              extrn     nextfixup
              extrn     save_r8
              extrn     trimrf

              lda       rf             ; get fixup type
              plo       rc             ; save it for now
              hlpr      load_r8,nextfixup ; get end of fixup table
name_lp:      lda       rf             ; get byte from name
              lbz       error          ; error if unexpected end
              plo       re             ; keep a copy
              smi       ' '            ; check for end of name
              lbz       name_done      ; jump if done with name
              glo       re             ; recover character
              str       r8             ; store into fixup table
              inc       r8
              lbr       name_lp        ; loop until name copied
name_done:    ldi       0              ; terminate name
              str       r8
              inc       r8
              glo       rc             ; recover type
              str       r8             ; store into fixup record
              inc       r8 
              call      trimrf         ; move past spaces
              ldn       rf             ; get next byte
              lbz       error          ; jump if unexpected end
              call      gethex         ; get address for fixup
              ghi       r7             ; store into fixup record
              str       r8
              inc       r8
              glo       r7
              str       r8
              inc       r8
              call      trimrf         ; move past spaces
              ldn       rf             ; see if offset is provided
              lbz       nooffset       ; jump if not
              call      gethex         ; get offset
              glo       r7             ; only low value matters
              lbr       do_offset      ; then process
nooffset:     ldi       0              ; set offset to zero
do_offset:    str       r8             ; write into fixup record
              inc       r8
              ldi       0              ; terminate table
              str       r8
              hlpr      save_r8,nextfixup ; write new table end
              rtn                      ; and return to caller

error:        call      o_inmsg        ; display error
              db        'Record format error',10,13,0
              rtn                      ; return to caller

              endp

