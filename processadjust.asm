#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processadjust

              extrn     gethex
              extrn     load_r8
              extrn     load_rb
              extrn     nextfixup
              extrn     procbase
              extrn     save_r8
              extrn     trimrf

              lda       rf             ; get fixup type
              plo       rc             ; save it for now
              hlpr      load_r8,nextfixup ; get end of fixup table
              ldi       '@'            ; signal adjust instead of fixup
              str       r8
              inc       r8
              ldi       0              ; terminate name
              str       r8
              inc       r8
              glo       rc             ; recover type
              str       r8             ; store into fixup record
              inc       r8 
              call      trimrf         ; move past spaces
              ldn       rf             ; get next byte
              lbz       error          ; jump if unexpected end
              call      gethex         ; get address for fixup
              push      rb
              hlpr      load_rb,procbase ; need to get procbase
              glo       rb             ; add proc base to address
              str       r2
              glo       r7
              add
              plo       r7
              ghi       rb
              str       r2
              ghi       r7
              adc
              phi       r7
              pop       rb
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

