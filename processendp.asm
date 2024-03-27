#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processendp

              extrn     dofixups
              extrn     dolines
              extrn     islibrary
              extrn     load_d
              extrn     procbase
              extrn     save_d
              extrn     save_r7

              call      dofixups       ; process any adjustments
              ldi       0              ; clear proc base
              phi       r7
              plo       r7
              hlpr      save_r7,procbase ; set proc base
              hlpr      load_d,islibrary ; need to see if processing library
              lbz       return         ; jump if not
              ldi       0              ; otherwise turn off line processing
              hlpr      save_d,dolines
return:       rtn                      ; return to caller

              endp

