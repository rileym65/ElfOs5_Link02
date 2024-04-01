#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      openfile

              extrn     dta
              extrn     fopen
              extrn     libpath

              call      fopen          ; attempt to open file
              lbnf      return         ; jump if file opened
              mov       r7,libpath     ; point to library path
loop:         ldn       r7             ; see if done with path
              lbz       failed         ; jump if failed to open file
              mov       r8,dta         ; use dta as buffer space
ploop:        lda       r7             ; get byte from path
              str       r8             ; store into buffer
              inc       r8
              lbnz      ploop          ; loop until terminator copied
              dec       r8             ; move back to last copied byte
              dec       r8
              lda       r8             ; and retrieve it
              smi       '/'            ; did it end with a slash
              lbz       slash          ; jump if so
              ldi       '/'            ; need a slash
              str       r8
              inc       r8
slash:        push      rf             ; save original filename
nloop:        lda       rf             ; get byte from name
              lbz       ndone          ; jump if done with name
              plo       re             ; keep a copy
              smi       ' '            ; space also terminates
              lbz       ndone
              glo       re             ; recover name byte
              str       r8             ; store into buffer
              inc       r8
              lbr       nloop          ; loop until name copied
ndone:        ldi       0              ; terminate full filename
              str       r8
              mov       rf,dta         ; point to path
              push      r7
              mov       r7,0
              call      fopen          ; and attempt to open the file
              pop       r7
              pop       rf             ; recover rf
              lbnf      return         ; jump if file was opened
              lbr       loop           ; try next name in path
failed:       smi       0              ; indicate failure
return:       rtn                      ; return to caller

              endp

