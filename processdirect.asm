#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      processdirect

              extrn     addlibrary
              extrn     address
              extrn     findsymbol
              extrn     load_r8
              extrn     load_rf
              extrn     nextfixup
              extrn     trimrf
              extrn     save_r8
              extrn     save_rf
              extrn     strcasecmpin

              inc       rf             ; move past directive marker
              call      strcasecmpin   ; check for align directive
              db        'align ',0
              lbdf      do_align       ; jump if alignment
              call      strcasecmpin   ; check for library directive
              db        'library ',0
              lbdf      is_library     ; jump if so
              call      strcasecmpin   ; check for library directive
              db        'requires ',0
              lbdf      is_requires    ; jump if so

return:       rtn                      ; return to caller

do_align:     call      trimrf         ; move past spaces
              call      strcasecmpin   ; check for word alignment
              db        'word',0
              lbdf      is_word        ; jump if so
              call      strcasecmpin   ; check for dword alignment
              db        'dword',0
              lbdf      is_dword       ; jump if so
              call      strcasecmpin   ; check for qword alignment
              db        'qword',0
              lbdf      is_qword       ; jump if so
              call      strcasecmpin   ; check for para alignment
              db        'para',0
              lbdf      is_para        ; jump if so
              call      strcasecmpin   ; check for 32-byte alignment
              db        '32',0
              lbdf      is_32          ; jump if so
              call      strcasecmpin   ; check for 64-byte alignment
              db        '64',0
              lbdf      is_64          ; jump if so
              call      strcasecmpin   ; check for 128-byte alignment
              db        '128',0
              lbdf      is_128         ; jump if so
              call      strcasecmpin   ; check for page alignment
              db        'page',0
              lbdf      is_page        ; jump if so

              rtn                      ; return to caller

is_word:      hlpr      load_rf,address ; get current address
              ldi       0feh           ; mask
              stxd                     ; store for processing
              ldi       1              ; to add
              str       r2             ; store for processing
process:      glo       rf             ; add size to rf
              add
              plo       rf
              ghi       rf
              adci      0
              phi       rf
              irx                      ; move to mask
              glo       rf             ; and mask low byte
              and
              plo       rf
              hlpr      save_rf,address ; save new address
              rtn                      ; and return

is_dword:     hlpr      load_rf,address ; get current address
              ldi       0fch           ; mask
              stxd
              ldi       3              ; amount to add
              str       r2
              lbr       process        ; process it

is_qword:     hlpr      load_rf,address ; get current address
              ldi       0f8h           ; mask
              stxd
              ldi       7              ; amount to add
              str       r2
              lbr       process        ; process it

is_para:      hlpr      load_rf,address ; get current address
              ldi       0f0h           ; mask
              stxd
              ldi       0fh            ; amount to add
              str       r2
              lbr       process        ; process it

is_32:        hlpr      load_rf,address ; get current address
              ldi       0e0h           ; mask
              stxd
              ldi       01fh            ; amount to add
              str       r2
              lbr       process        ; process it

is_64:        hlpr      load_rf,address ; get current address
              ldi       0c0h           ; mask
              stxd
              ldi       03fh            ; amount to add
              str       r2
              lbr       process        ; process it

is_128:       hlpr      load_rf,address ; get current address
              ldi       080h           ; mask
              stxd
              ldi       07fh            ; amount to add
              str       r2
              lbr       process        ; process it

is_page:      hlpr      load_rf,address ; get current address
              ldi       000h           ; mask
              stxd
              ldi       0ffh            ; amount to add
              str       r2
              lbr       process        ; process it

is_library:   call      trimrf         ; move past spaces
              push      rf             ; save name start position
lib_loop_1:   lda       rf             ; look for end of name
              lbz       lib_done       ; jump if end found
              smi       ' '            ; space also ends name
              lbnz      lib_loop_1     ; loop until end found
lib_done:     dec       rf             ; move back to non-name char
              ldi       0              ; and terminate name
              str       rf
              pop       rf             ; recover start of name
              call      addlibrary     ; and add to library list
              rtn                      ; return to caller

is_requires:  call      trimrf         ; move past spaces
              push      rf             ; save position
              call      findsymbol     ; see if symbol already exists
              pop       rf             ; recover RF
              lbnf      return         ; do nothing if so
              hlpr      load_r8,nextfixup ; get end of fixup table
name_lp:      lda       rf             ; get byte from name
              lbz       name_done      ; done if terminator
              plo       re             ; keep a copy
              smi       ' '            ; check for end of name
              lbz       name_done      ; jump if done with name
              glo       re             ; recover character
              str       r8             ; store into fixup table
              inc       r8
              lbr       name_lp        ; loop until name copied
name_done:    ldi       0              ; terminate name
              str       r8
              inc       r8
              ldi       '$'            ; set type as requires
              str       r8
              inc       r8
              ldi       0              ; address is zero
              str       r8
              inc       r8
              str       r8
              inc       r8
              str       r8             ; offset is zero
              inc       r8
              str       r8             ; write table terminator
              hlpr      save_r8,nextfixup ; write new fixup pointer
              rtn                      ; and return to caller

              endp

