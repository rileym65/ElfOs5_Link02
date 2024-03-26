#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *****************************************
; ***** Get hex value from input line *****
; ***** RF - Input                    *****
; ***** Returns: R7 - value           *****
; *****          RF - non hex char    *****
; *****************************************
              proc      gethex

              extrn     checkrange

              mov       r7,0           ; Set initial value to zero
loop:         lda       rf             ; get next byte from input
              lbz       done           ; jump if end of string
              call      checkrange     ; check range
              db        '0','9'
              lbnf      not_num        ; jump if not a numeral
              smi       '0'            ; convert to binary
process:      str       r2             ; save for now
              ldi       4              ; need to shift 4 bits
              plo       re
loop_1:       glo       r7             ; shift result left
              shl
              plo       r7
              ghi       r7
              shlc
              phi       r7
              dec       re             ; decrement count
              glo       re             ; see if done
              lbnz      loop_1         ; loop until all 4 shifts done
              glo       r7             ; now combine with new digit
              or
              plo       r7
              lbr       loop           ; loop until non-hex character
not_num:      call      checkrange     ; check a-f
              db        'a','f'
              lbnf      not_lc         ; jump if not lowercase a-f
              smi       87             ; convert to binary
              lbr       process        ; and process it
not_lc:       call      checkrange     ; check A-F
              db        'A','F'
              lbnf      done           ; done if non-hex character
              smi       55             ; convert to binary
              lbr       process        ; and process it
done:         dec       rf             ; move back to non-hex character
              rtn                      ; and return to caller

              endp

