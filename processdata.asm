#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processdata

              extrn     gethex
              extrn     writemem

              inc       rf             ; move past : marker
              call      gethex         ; get address for line
              mov       ra,r7          ; move value to ra
loop:         ldn       rf             ; get byte from line
              smi       ' '            ; must be space or greater
              lbnz      done           ; jump if done with line
sploop:       lda       rf             ; get byte from line
              smi       ' '            ; check for space
              lbz       sploop         ; loop until non-space found
              dec       rf             ; move back to non-space character
              ldn       rf             ; get byte from line
              lbz       done           ; done if end of line reached
              call      gethex         ; get next byte value
              glo       r7             ; get converted byte
              call      writemem       ; write to memory array
              inc       ra             ; increment address
              lbr       loop           ; loop for more bytes
done:         rtn                      ; return to caller

              endp

