#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processdata

              extrn     address
              extrn     gethex
              extrn     load_r7
              extrn     procbase
              extrn     save_ra
              extrn     writemem

              inc       rf             ; move past : marker
              call      gethex         ; get address for line
              mov       ra,r7          ; move value to ra
              hlpr      load_r7,procbase ; get proc base
              glo       r7             ; add to address
              str       r2
              glo       ra
              add
              plo       ra
              ghi       r7
              str       r2
              ghi       ra
              adc
              phi       ra             ; ra now has adjusted address
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
done:         hlpr      save_ra,address ; save current address
              rtn                      ; return to caller

              endp

