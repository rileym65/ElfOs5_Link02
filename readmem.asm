#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *************************************
; ***** Read virtual memory array *****
; ***** RA - address to read      *****
; ***** Returns: D - value        *****
; *************************************
              proc      readmem

              extrn     checkvmem
              extrn     vmemdta

              ghi       ra             ; get high byte of address
              shr                      ; need as relative sector
              call      checkvmem      ; be sure correct sector is loaded
              push      r7             ; save consumed register
              glo       ra             ; compute address
              adi       vmemdta.0
              plo       r7
              ghi       ra
              ani       1              ; only 9 bits used
              adci      vmemdta.1
              phi       r7             ; r7 now has correct address
              ldn       r7             ; read the byte
              plo       re             ; set aside for a mmoment
              pop       r7             ; recover consumed register
              glo       re             ; recover read byte
              rtn                      ; and return to caller

              endp

