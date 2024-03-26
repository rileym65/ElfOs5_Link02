#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      loadfile

              extrn     buffer
              extrn     fildes
              extrn     fopen
              extrn     load_d
              extrn     outputname
              extrn     processdata
              extrn     processfixup
              extrn     processstart
              extrn     processsymbol
              extrn     readln

              hlpr      load_d,outputname ; see if output name is set
              lbnz      nameset        ; jump if name is set
              mov       ra,rf          ; make copy of filename address
              mov       rb,outputname  ; point to output name
name_loop:    lda       ra             ; copy byte from filename
              str       rb             ; to outputname
              inc       rb
              lbz       no_dot         ; jump if terminator
              smi       '.'            ; was a dot written
              lbnz      name_loop
              dec       rb             ; move back to the dot
              ldi       0              ; and terminate name
              str       rb
              lbr       nameset        ; then continue processing file
no_dot:       ldi       '.'            ; add extension
              str       rb
              inc       rb
              ldi       'o'
              str       rb
              inc       rb
              ldi       'u'
              str       rb
              inc       rb
              ldi       't'
              str       rb
              inc       rb
              ldi       0              ; and terminate
              str       rb
nameset:      call      o_inmsg        ; display message
              db        'Linking: ',0
              push      rf             ; keep a copy of filename
              call      o_msg          ; then display filename
              call      o_inmsg        ; display cr/lf
              db        10,13,0
              pop       rf             ; recover filename
              push      rf             ; keep a copy of the filename
              mov       rd,fildes      ; point to fildes
              mov       r7,0           ; no open flags
              call      fopen          ; attempt to open the file
              lbnf      opened         ; jump if the file was opened
              call      o_inmsg        ; display error
              db        'Could not open file: ',0
              pop       rf             ; recover filename
              call      o_msg          ; and display it
              call      o_inmsg        ; display crlf
              db        10,13,0
              rtn                      ; then return to caller
opened:       pop       rf             ; remove filename from stack
loop:         mov       rf,buffer      ; point to input buffer
              mov       rd,fildes      ; point to fildes
              call      readln         ; read next line
              lbdf      done           ; jump if end of file
              mov       rf,buffer      ; point to input buffer
              ldn       rf             ; get first byte
              smi       ':'            ; is it data marker
              lbnz      not_data       ; jump if not
              call      processdata    ; process data line
              lbr       loop           ; then read next line
not_data:     ldn       rf             ; recover first byte
              smi       '@'            ; check for start marker
              lbnz      not_start      ; jump if not
              call      processstart   ; process start
              lbr       loop           ; jump to process next line
not_start:    ldn       rf             ; recover first byte
              smi       '?'            ; check for fixup
              lbnz      not_qm         ; jump if not
              call      processfixup   ; otherwise process fixup
              lbr       loop           ; and back to loop
not_qm:       ldn       rf             ; recover first byte
              smi       '/'            ; check for high fixup
              lbnz      not_hf         ; jump if not
              call      processfixup   ; otherwise process fixup
              lbr       loop           ; and back to loop
not_hf:       ldn       rf             ; recover first byte
              smi       '\'            ; check for low fixup
              lbnz      not_lf         ; jump if not
              call      processfixup   ; otherwise process fixup
              lbr       loop           ; and back to loop
not_lf:       ldn       rf             ; recover first byte
              smi       '='            ; check for equate symbol
              lbnz      not_eq         ; jump if not
              call      processsymbol  ; process symbol
              lbr       loop           ; then back for next line
not_eq:
              lbr       loop           ; ignore line and process next line

done:         rtn                      ; return to caller

              endp

