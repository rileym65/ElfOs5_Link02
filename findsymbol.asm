#include      macros.inc
#include      bios.inc
#include      kernel.inc

; ****************************************
; ***** Search for public symbol     *****
; ***** RF - Symbol to search for    *****
; ***** Returns: DF=0 - symbol found *****
; *****            R7 - symbol value *****
; *****            RA - symbol name  *****
; *****          DF=1 - not found    *****
; ****************************************
              proc      findsymbol

              extrn     load_ra
              extrn     symbols

              hlpr      load_ra,symbols ; get symbol table start
loop:         ldn       ra              ; get byte from sybmol table
              lbz       notfound        ; jump if end of table
              push      ra              ; save pointers
              push      rf
name_lp:      lda       ra              ; get byte from name
              lbz       name_dn         ; jump if end of name
              str       r2              ; store for compare
              lda       rf              ; get byte from source
              sm                        ; do they match
              lbz       name_lp         ; jump if they match
end_lp:       lda       ra              ; search for end of symbol name
              lbnz      end_lp
next:         inc       ra              ; move past address
              inc       ra
              pop       rf              ; recover search address
              irx                       ; remove ra
              irx
              lbr       loop            ; check next symbol
name_dn:      ldn       rf              ; get byte from symbol
              lbz       match           ; jump if matched
              smi       ' '             ; space matches too
              lbnz      next            ; no match so find next entry
match:        lda       ra              ; retrieve symbol value
              phi       r7
              lda       ra
              plo       r7
              pop       rf              ; recover pointers
              pop       ra
              adi       0               ; signal found
              rtn                       ; and return
notfound:     smi       0               ; indicate not found
              rtn                       ; and return

              endp
