#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processsymbol

              extrn     findsymbol
              extrn     gethex
              extrn     load_ra
              extrn     load_rf
              extrn     procbase
              extrn     save_ra
              extrn     symbols
              extrn     trimrf

              inc       rf             ; move past =
              call      findsymbol     ; see if already exists
              lbdf      noexist        ; jump if not a duplicate
              call      o_inmsg        ; display error
              db        'Error: Duplicate symbol: ',0
              call      o_msg
              call      o_inmsg
              db        10,13,0
              rtn                      ; return to caller
noexist:      push      rf             ; save position
              mov       rc,3           ; entry size starts with 3
loop:         lda       rf             ; get byte from name
              lbz       name_dn        ; jump if done with name
              smi       ' '            ; space ends name
              lbz       name_dn
              inc       rc             ; increment count
              lbr       loop           ; loop until end of name
name_dn:      pop       rf             ; return to starting position
              hlpr      load_ra,symbols ; get start of symbol table
              glo       rc             ; subtract entry size
              str       r2
              glo       ra
              sm
              plo       ra
              ghi       rc
              str       r2
              ghi       ra
              smb
              phi       ra             ; ra now has new start
              hlpr      save_ra,symbols ; write it back
name_cp:      lda       rf             ; copy name to symbol
              lbz       copy_dn        ; jump if done
              plo       re             ; save it
              smi       ' '            ; space ends
              lbz       copy_dn
              glo       re             ; recover name character
              str       ra             ; write to symbol table
              inc       ra
              lbr       name_cp        ; loop until all copied
copy_dn:      ldi       0              ; terminate name
              str       ra
              inc       ra
              call      trimrf         ; move past spaces
              call      gethex         ; and get symbol value
              hlpr      load_rf,procbase ; get base address
              glo       r7             ; add to label value
              str       r2
              glo       rf
              add
              plo       r7
              ghi       r7
              str       r2
              ghi       rf
              adc
              phi       r7
              ghi       r7             ; write value to symbol table
              str       ra
              inc       ra
              glo       r7
              str       ra
              rtn                      ; return to caller

              endp

