#include      macros.inc
#include      bios.inc
#include      kernel.inc

; **********************************************
; ***** Add path to library search path    *****
; ***** RF - Pointer to library filename   *****
; **********************************************
              proc      addlibpath

              extrn     libpath

              mov       r7,libpath     ; point to libpath
oloop:        ldn       r7             ; get first byte of entry
              lbz       eol            ; jump if end of list
iloop:        lda       r7             ; search for end of entry
              lbnz      iloop
              lbr       oloop          ; check next entry
eol:          lda       rf             ; get byte from filename
              str       r7             ; store into libraries
              inc       r7
              lbnz      eol            ; loop until terminator copied
              ldi       0              ; write new list terminator
              str       r7
              rtn                      ; and return to caller

              endp

