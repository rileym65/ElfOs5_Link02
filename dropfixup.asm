#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      dropfixup

              extrn     nextfixup
              extrn     save_rf

              mov       r8,rf          ; copy fixup address
find_lp:      lda       r8             ; find end of name
              lbnz      find_lp
              inc       r8             ; move past type
              inc       r8             ; move past address
              inc       r8
              inc       r8             ; rf now points to next entry
loop:         ldn       r8             ; get first byte of next entry
              lbz       done           ; jump if done
copy_lp:      lda       r8             ; get byte from fixup name
              str       rf             ; store into previous entry
              inc       rf
              lbnz      copy_lp        ; loop until terminator copied
              lda       r8             ; get type
              str       rf             ; store into previous
              inc       rf
              lda       r8             ; copy address
              str       rf
              inc       rf
              lda       r8
              str       rf
              inc       rf
              lda       r8             ; copy offset
              str       rf
              inc       rf
              lbr       loop           ; continue copying entries until done
done:         ldi       0              ; terminate table
              str       rf
              hlpr      save_rf,nextfixup ; save new table end
              rtn                      ; and return

              endp

