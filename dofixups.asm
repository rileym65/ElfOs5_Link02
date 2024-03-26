#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      dofixups

              extrn     dropfixup
              extrn     findsymbol
              extrn     fixups
              extrn     load_r7
              extrn     procbase
              extrn     readmem
              extrn     writemem

loop:         mov       rf,fixups      ; point to fixups table
iloop:        ldn       rf             ; get byte from fixups table
              lbz       return         ; return if no more fixups
              ldn       rf             ; get first byte of fixup record
              smi       '@'            ; check for adjustment record
              lbnz      no_adjust      ; jump if not
              mov       r8,rf          ; save fixup position
              inc       rf             ; move past record marker
              inc       rf             ; and terminator
              lbr       do_fixup       ; then process adjustment
no_adjust:    push      rf             ; save table position
              call      findsymbol     ; search for symbol
              pop       rf             ; recover position
              lbdf      notfound       ; jump if symbol not found
              mov       r8,rf          ; save fixup position
name_lp:      lda       rf             ; find end of name
              lbnz      name_lp        ; loop until terminator found
do_fixup:     ldn       rf             ; get fixup type
              smi       '?'            ; check for 16 bit
              lbz       fix_16         ; jump if so
              ldn       rf             ; recover fixup type
              smi       '/'            ; check for high fix
              lbz       fix_high
              ldn       rf             ; recover fixup type
              smi       '\'            ; check for low fix
              lbz       fix_low
              ldn       rf             ; recover fixup type
              smi       '+'            ; check for 16-bit adjustment
              lbz       adj_16         ; jump if so
              ldn       rf             ; recover fixup type
              smi       '^'            ; check for high byte adjustment
              lbz       adj_high       ; jump if so
              ldn       rf             ; recover fixup type
              smi       'v'            ; check for low byte adjustment
              lbz       adj_low        ; jump if so
              rtn                      ; return if invalid fix

notfound:     lda       rf             ; find end of fixup name
              lbnz      notfound       ; search for terminator
              inc       rf             ; move past type
              inc       rf             ; move past address
              inc       rf
              inc       rf             ; move past offset
              lbr       iloop          ; and check next entry

fix_16:       inc       rf             ; move to address
              lda       rf             ; and retrieve it
              phi       ra
              lda       rf
              plo       ra
              call      readmem        ; read 16 bit value from address
              phi       rb
              inc       ra
              call      readmem
              plo       rb
              glo       r7             ; rb += r7
              str       r2
              glo       rb
              add
              plo       rb
              ghi       r7
              str       r2
              ghi       rb
              adc
              phi       rb
              glo       rb             ; write adjusted address back to memory
              call      writemem
              dec       ra
              ghi       rb
              call      writemem
now_drop:     mov       rf,r8          ; recover fixup position
              call      dropfixup      ; and remove fixup
              lbr       loop           ; and loop for more fixups

fix_low:      inc       rf             ; move to address
              lda       rf             ; and retrieve it
              phi       ra
              lda       rf
              plo       ra
              call      readmem        ; read the value
              str       r2             ; store for add
              glo       r7             ; get low of symbol value
              add                      ; and add
              call      writemem       ; write it back to memory
              lbr       now_drop       ; now drop fixup

fix_high:     inc       rf             ; move to address
              lda       rf             ; and retrieve it
              phi       ra
              lda       rf
              plo       ra
              call      readmem        ; read the value
              str       r2             ; store for add
              ghi       r7             ; get high of symbol value
              add                      ; and add
              str       r2             ; store for add
              ldn       rf             ; get offset
              add                      ; and add
              call      writemem       ; write it back to memory
              lbr       now_drop       ; now drop fixup

adj_16:       hlpr      load_r7,procbase ; get proc base
              lbr       fix_16         ; now handle as fix 16

adj_low:      hlpr      load_r7,procbase ; get proc base
              lbr       fix_low        ; now handle as fix low

adj_high:     hlpr      load_r7,procbase ; get proc base
              lbr       fix_high       ; now handle as fix high

return:       rtn                      ; return to caller

              endp

