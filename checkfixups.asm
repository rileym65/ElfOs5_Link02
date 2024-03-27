#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *****************************************
; ***** Check if name in fixups       *****
; ***** Returns: DF=1 - is in fixups  *****
; *****          DF=0 - not in fixups *****
; *****************************************
              proc      checkfixups

              extrn     fixups

              mov       r7,fixups      ; point to fixups table
loop:         ldn       r7             ; get byte from fixups
              lbz       eot            ; jump if end of table
              push      rf             ; save name position
str_loop:     lda       r7             ; get byte from fixups name
              lbz       str_last       ; jump if terminator
              str       r2             ; store for compare
              lda       rf             ; get byte from name
              sm                       ; compare
              lbz       str_loop       ; loop until terminaor or mismatch
              pop       rf             ; recover name address
end_loop:     lda       r7             ; loop until name terminator
              lbnz      end_loop
next:         inc       r7             ; move past type
              inc       r7             ; move past address
              inc       r7
              inc       r7             ; move past offset
              lbr       loop           ; check next entry
str_last:     lda       rf             ; name must also be terminator
              plo       re             ; set aside
              pop       rf             ; recover name address
              glo       re             ; recover byte
              lbnz      next           ; next entry if not
              smi       0              ; signal entry was found
              rtn                      ; and return to caller
eot:          adi       0              ; signal name not in fixups
              rtn                      ; and return

              endp

