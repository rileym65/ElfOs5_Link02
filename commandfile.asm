#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      commandfile

              extrn     buffer
              extrn     cfildes
              extrn     fopen
              extrn     loadfile
              extrn     readln
              extrn     strcasecmpin
              extrn     trimrf

              mov       rd,cfildes     ; point to command fildes
              mov       r7,0           ; no special flags
              call      fopen          ; attempt to open the file
              lbnf      opened
              call      o_inmsg        ; display error
              db        '??? Could not open command file',10,13,0
return:       rtn                      ; return to caller

opened:       mov       rf,buffer      ; point to buffer
              mov       rd,cfildes     ; point to fildes
              call      readln         ; read next line
              lbdf      return         ; jump if done processing file
              call      strcasecmpin   ; check for add command
              db        'add ',0
              lbdf      is_add         ; jump if so

              lbr       opened         ; read and process next line

is_add:       call      trimrf         ; move past spaces
              call      loadfile       ; load specified file
              lbr       opened         ; read and process next line



              endp

