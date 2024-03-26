#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processstart

              extrn     gethex
              extrn     save_r7
              extrn     startaddr

              inc       rf             ; move past @ marker
              call      gethex         ; conver address from hex to binary
              hlpr      save_r7,startaddr
              rtn                      ; return to caller

              endp
