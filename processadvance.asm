#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processadvance

              extrn     address
              extrn     gethex
              extrn     load_rb
              extrn     save_r7

              inc       rf             ; move past advance marker
              call      gethex         ; get address for fixup
              hlpr      load_rb,address ; get current address
              glo       rb             ; add advancement count
              str       r2
              glo       r7
              add
              plo       r7
              ghi       rb
              str       r2
              ghi       r7
              adc
              phi       r7
              hlpr      save_r7,address ; save new address
              rtn                      ; and return

              endp

