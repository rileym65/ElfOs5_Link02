#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *****************************************
; ***** Write to virtual memory array *****
; ***** RA - Address                  *****
; *****  D - value                    *****
; *****************************************
              proc      writemem

              extrn     checkvmem
              extrn     highest
              extrn     load_rc
              extrn     lowest
              extrn     save_ra
              extrn     vmemdta

              stxd                     ; save byte to write
              hlpr      load_rc,lowest ; check if address is higher than lowest
              glo       ra             ; lowest - address
              str       r2
              glo       rc
              sm
              ghi       ra
              str       r2
              ghi       rc
              smb
              lbnf      not_low
              hlpr      save_ra,lowest ; set new lowest address
not_low:      hlpr      load_rc,highest ; check if highest address
              glo       rc             ; address - highest
              str       r2
              glo       ra
              sm
              ghi       rc
              str       r2
              ghi       ra
              smb
              lbnf      not_high
              hlpr      save_ra,highest ; set highest address
not_high:     ghi       ra             ; get high byte of address
              shr                      ; need as relative sector
              call      checkvmem      ; be sure correct sector is loaded
              irx                      ; recover byte to write
              ldx
              plo       re             ; set aside for the moment
              push      r7             ; save consumed register
              glo       ra             ; compute address
              adi       vmemdta.0
              plo       r7
              ghi       ra
              ani       1              ; only 9 bits used
              adci      vmemdta.1
              phi       r7             ; r7 now has correct address
              glo       re             ; get byte to write
              str       r7             ; and write it
              pop       r7             ; recover consumed register
              rtn                      ; return to caller

              endp

