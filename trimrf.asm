#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      trimrf

              lda       rf
              smi       ' '
              lbz       trimrf
              dec       rf
              rtn

              endp

