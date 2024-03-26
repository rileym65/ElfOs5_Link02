#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      commandfile

              extrn     buffer
              extrn     cfildes
              extrn     fopen
              extrn     loadfile
              extrn     outputmode
              extrn     outputname
              extrn     readln
              extrn     save_d
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
              call      strcasecmpin   ; check for mode command
              db        'mode ',0
              lbdf      is_mode        ; jump if so
              call      strcasecmpin   ; check for output command
              db        'output ',0
              lbdf      is_output      ; jump if so

              lbr       opened         ; read and process next line

is_add:       call      trimrf         ; move past spaces
              call      loadfile       ; load specified file
              lbr       opened         ; read and process next line

is_mode:      call      trimrf         ; move past spaces
              call      strcasecmpin   ; check for binary mode
              db        'binary',0
              lbdf      is_binary      ; jump if so
              call      strcasecmpin   ; check for elfos mode
              db        'elfos',0
              lbdf      is_elfos       ; jump if so
              call      strcasecmpin   ; check for intel mode
              db        'intel',0
              lbdf      is_intel       ; jump if so
              call      strcasecmpin   ; check for rcs mode
              db        'rcs',0
              lbdf      is_rcs         ; jump if so

              lbr       opened         ; read and process next line

is_binary:    ldi       'B'            ; set binary mode
              hlpr      save_d,outputmode
              lbr       opened         ; read and process next line

is_elfos:     ldi       'E'            ; set elfos mode
              hlpr      save_d,outputmode
              lbr       opened

is_intel:     ldi       'I'            ; set intel mode
              hlpr      save_d,outputmode
              lbr       opened

is_rcs:       ldi       'H'            ; set rcs mode
              hlpr      save_d,outputmode
              lbr       opened

is_output:    call      trimrf         ; move past spaces
              mov       r7,outputname  ; point to output name
out_loop:     ldn       rf             ; get byte from line
              lbz       out_done       ; jump if terminator
              smi       ' '            ; check for space
              lbz       out_done
              lda       rf             ; retrieve character
              str       r7             ; store into name buffer
              inc       r7
              lbr       out_loop       ; loop until name copied
out_done:     ldi       0              ; terminate name
              str       r7
              lbr       opened         ; read and process next line

              endp

