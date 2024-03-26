#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processendp

              extrn     address
              extrn     dofixups
              extrn     findsymbol
              extrn     gethex
              extrn     load_r7
              extrn     load_ra
              extrn     procbase
              extrn     save_r7
              extrn     save_ra
              extrn     symbols
              extrn     trimrf

              call      dofixups       ; process any adjustments
              ldi       0              ; clear proc base
              phi       r7
              plo       r7
              hlpr      save_r7,procbase ; set proc base
              rtn                      ; return to caller

              endp

