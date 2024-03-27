#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      dolibraries

              extrn     dolines
              extrn     islibrary
              extrn     libraries
              extrn     loadfile
              extrn     save_d

              ldi       0              ; turn off line processing
              hlpr      save_d,dolines
              ldi       0ffh           ; signal in library processing
              hlpr      save_d,islibrary

              mov       rf,libraries   ; point to libraries list
loop:         ldn       rf             ; see if done processing libraries
              lbz       done
              push      rf             ; save this position
              call      loadfile       ; process the library file
              pop       rf             ; recover address
find_end:     lda       rf             ; get next byte of name
              lbnz      find_end       ; loop until end of name
              lbr       loop           ; process next library

done:         ldi       0              ; turn off library processing
              hlpr      save_d,islibrary
              rtn                      ; and return to caller

              endp

