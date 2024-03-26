#include      macros.inc
#include      bios.inc
#include      kernel.inc

              org       2000h

              extrn     dofixups
              extrn     fixups
              extrn     loadfile
              extrn     writebinary
              extrn     writeelfos
              extrn     writeintel
              extrn     writercs

begin:        br        start
              eever
              db        'Written by Michael H. Riley',0

start:        mov       rf,K_VER       ; get kernel version
              lda       rf
              smi       5              ; must be 5+
              lbdf      start2         ; jump if valid version
              call      o_inmsg        ; display error
              db        'Requires Elf/OS 5+',10,13,0
              ldi       014h           ; set return code
              rtn                      ; return to caller

address:      dw        0
procbase:     dw        0
outputmode:   dw        0
highest:      dw        0
lowest:       dw        0
startaddr:    dw        0
vmemau:       dw        0,0
vmemsec:      dw        0,0
vmemrsec:     db        0
commandline:  dw        0
nextfixup:    dw        0
outputname:   ds        80
symbols:      dw        0

; ***************************************
; ***** Helper functions tied to R9 *****
; ***************************************
              org       ($+255) & 0ff00h
              sep       r3
helpers:      plo       re             ; save D
              lda       r3             ; get instruction
              plo       r9             ; jump to instruction
save_d:       glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; set rf to inline address
              phi       rf
              lda       r3
              plo       rf
              glo       re             ; get D
              str       rf             ; and save it
restore_rf:   ldxa                     ; recover rf
              phi       rf
              ldx
              plo       rf
              glo       re             ; recover D
              br        helpers-1      ; and return to caller

load_d:       glo       rf             ; save rf
              stxd
              ghi       rf
              str       r2
              lda       r3             ; set rf to inline address
              phi       rf
              lda       r3
              plo       rf
              ldn       rf             ; get value from address
              plo       re             ; save it
              br        restore_rf     ; and then clean up and return

save_ra:      glo       rf             ; save ra
              stxd
              ghi       rf
              str       r2
              lda       r3             ; get address from inline
              phi       rf
              lda       r3
              plo       rf
              ghi       ra             ; save rf at address
              str       rf
              inc       rf
              glo       ra
              str       rf
              ldxa                     ; restore ra
              phi       rf
              ldx
              plo       rf
              br        helpers-1      ; then return

save_rf:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       rf             ; save rf at address
              str       ra
              inc       ra
              glo       rf
              str       ra
restore_ra:   ldxa                     ; restore ra
              phi       ra
              ldx
              plo       ra
              br        helpers-1      ; then return

save_r7:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       r7             ; save rf at address
              str       ra
              inc       ra
              glo       r7
              str       ra
              br        restore_ra

save_r8:      glo       ra             ; save ra
              stxd
              ghi       ra
              str       r2
              lda       r3             ; get address from inline
              phi       ra
              lda       r3
              plo       ra
              ghi       r8             ; save rf at address
              str       ra
              inc       ra
              glo       r8
              str       ra
              br        restore_ra

load_rf:      lda       r3             ; get address
              phi       rf
              lda       r3
              plo       rf
              lda       rf             ; retrieve the value
              plo       re
              lda       rf
              plo       rf
              glo       re
              phi       rf
              br        helpers-1

load_ra:      lda       r3             ; get address
              phi       ra
              lda       r3
              plo       ra
              lda       ra             ; retrieve the value
              plo       re
              lda       ra
              plo       ra
              glo       re
              phi       ra
              br        helpers-1

load_rb:      lda       r3             ; get address
              phi       rb
              lda       r3
              plo       rb
              lda       rb             ; retrieve the value
              plo       re
              lda       rb
              plo       rb
              glo       re
              phi       rb
              br        helpers-1

load_rc:      lda       r3             ; get address
              phi       rc
              lda       r3
              plo       rc
              lda       rc             ; retrieve the value
              plo       re
              lda       rc
              plo       rc
              glo       re
              phi       rc
              br        helpers-1

load_rd:      lda       r3             ; get address
              phi       rd
              lda       r3
              plo       rd
              lda       rd             ; retrieve the value
              plo       re
              lda       rd
              plo       rd
              glo       re
              phi       rd
              br        helpers-1

load_r8:      lda       r3             ; get address
              phi       r8
              lda       r3
              plo       r8
              lda       r8             ; retrieve the value
              plo       re
              lda       r8
              plo       r8
              glo       re
              phi       r8
              br        helpers-1

load_r7:      lda       r3             ; get address
              phi       r7
              lda       r3
              plo       r7
              lda       r7             ; retrieve the value
              plo       re
              lda       r7
              plo       r7
              glo       re
              phi       r7
              br        helpers-1

incopy:       lda       r3
              str       rf
              inc       rf
              bnz       incopy
              dec       rf
              br        helpers-1

savesec:      ghi       r8
              str       rf
              inc       rf
              glo       r8
              str       rf
              inc       rf
              ghi       r7
              str       rf
              inc       rf
              glo       r7
              str       rf
              inc       rf
              br        helpers-1

loadsec:      lda       rf
              phi       r8
              lda       rf
              plo       r8 
              lda       rf
              phi       r7
              lda       rf
              plo       r7
              br        helpers-1


; ***************************************

start2:       call      o_inmsg        ; display banner
              db        'Link/02 v0.1',10,13
              db        'by Michael H. Riley',10,13,10,13,0

              mov       r9,helpers
              hlpr      save_ra,commandline ; save command line position
              ldi       0              ; clear outputname
              hlpr      save_d,outputname
              hlpr      save_d,fixups  ; clear fixups
              hlpr      save_d,flags   ; clear flags
              mov       rf,0ffffh      ; set lowest
              hlpr      save_rf,lowest
              hlpr      save_rf,startaddr ; and start address
              mov       rf,0           ; set highest
              hlpr      save_rf,highest
              hlpr      save_rf,procbase
              ldi       'E'            ; set output mode to Elf/OS
              hlpr      save_d,outputmode
              mov       rf,fixups      ; mark end of fixup table
              hlpr      save_rf,nextfixup
              mov       r7,k_himem     ; need to get end of memory
              lda       r7
              phi       rf
              lda       r7
              plo       rf
              ldi       0              ; mark end of symbol table
              str       rf
              hlpr      save_rf,symbols ; save symbol table address

; ********************************
; ***** Setup virtual memory *****
; ********************************
              mov       rf,memfile     ; point to vmem filename
              mov       rd,fildes      ; point to fildes
              mov       r7,3           ; create/truncate flags
              call      o_open         ; open the file
              lbnf      vmem_open      ; jump if opened file
              call      o_inmsg        ; display error
              db        'Could not open vmem.dat',10,13,0
              ldi       4              ; set return value
              rtn                      ; and return to OS
vmem_open:    mov       rf,file_sector ; point to file sector
              op        loadsec        ; retrieve sector
              mov       rf,vmemsec     ; point to vmem sector
              op        savesec        ; save this
              call      o_sectolmp     ; convert to lump number
              mov       rf,vmemau      ; point to vmem au
              op        savesec
              ldi       0              ; set vmem relsec to 0
              hlpr      save_d,vmemrsec
              mov       r8,1           ; expand file to 65536 bytes
              mov       r7,0
              mov       rc,0
              call      o_seek
              call      o_close        ; then close the file

; *********************
; ***** Main loop *****
; *********************

loop:         hlpr      load_ra,commandline ; recover command line position
trim:         lda       ra             ; move past any spaces
              smi       ' '
              lbz       trim
              dec       ra             ; move back to nonspace
              ldn       ra             ; see if end of command line
              lbz       finished       ; jump if finished
              smi       '-'            ; check for switches
              lbz       is_switch      ; jump if so

              mov       rf,buffer      ; need somewhere to copy filename
name_loop:    lda       ra             ; read byte from command line
              lbz       name_done      ; jump if done with name
              plo       re             ; keep a copy
              smi       ' '            ; check for space
              lbz       name_done      ; space ends name
              glo       re             ; recover character
              str       rf             ; write to buffer
              inc       rf
              lbr       name_loop      ; loop until name copied
name_done:    dec       ra             ; move back to non name character
              hlpr      save_ra,commandline ; save command line position
              ldi       0              ; terminate name
              str       rf
              mov       rf,buffer      ; point to beginning of name
              call      loadfile       ; and load the file
              lbr       loop           ; then back to main loop

is_switch:    inc       ra             ; move past -
              ldn       ra             ; get switch
              smi       'e'            ; check for -e
              lbnz      not_e          ; jump if not
              ldi       'E'            ; set Elf/OS mode
              hlpr      save_d,outputmode
              inc       ra             ; move past switch
              lbr       trim           ; and keep processing
not_e:        ldn       ra             ; get switch
              smi       'b'            ; check for -b
              lbnz      not_b          ; jump if not
              ldi       'B'            ; set binary mode
              hlpr      save_d,outputmode
              inc       ra             ; move past switch
              lbr       trim           ; and keep processing
not_b:        ldn       ra             ; get switch
              smi       'i'            ; check for -i
              lbnz      not_i          ; jump if not
              ldi       'I'            ; set intel mode
              hlpr      save_d,outputmode
              inc       ra             ; move past switch
              lbr       trim           ; and keep processing
not_i:        ldn       ra             ; get switch
              smi       'h'            ; check for -h
              lbnz      not_h          ; jump if not
              ldi       'H'            ; set RCS mode
              hlpr      save_d,outputmode
              inc       ra             ; move past switch
              lbr       trim           ; and keep processing
not_h:        ldn       ra             ; get switch
              smi       'o'            ; check for -o
              lbnz      not_o          ; jump if not
              inc       ra             ; move past switch
              mov       rf,outputname  ; point to output name
o_loop:       lda       ra             ; move past any spaces
              smi       ' '
              lbz       o_loop
              dec       ra             ; move back to non-space
              ldn       ra             ; check for end of command line
              lbz       o_error        ; jump if error
o_copy:       lda       ra             ; read character from command line
              lbz       o_done         ; jump if done
              plo       re             ; keep a copy
              smi       ' '            ; check for space
              lbz       o_done         ; space ends name
              glo       re             ; recover character
              str       rf             ; store intto outputname
              inc       rf
              lbr       o_copy         ; finish copying name
o_done:       dec       ra             ; move back to non-name character
              ldi       0              ; terminate name
              str       rf
              lbr       trim           ; continue processing command line

o_error:      call      o_inmsg        ; display error
              db        'Unexpeced end of command line',10,13,0
              ldi       9              ; set return code
              rtn                      ; and return to os

not_o:        ldn       ra             ; get switch
              smi       's'            ; check for -s
              lbnz      not_s          ; jump if not
              hlpr      load_d,flags   ; get flags
              ori       1              ; set show symbols flag
              hlpr      save_d,flags   ; and put it back
              inc       ra             ; move past switch
              lbr       trim           ; and keep processing

not_s:
sw_error:     call      o_inmsg        ; display error
              db        'Unknown switch: ',0
              ldn       ra
              call      o_type
              call      o_inmsg
              db        10,13,0
              ldi       9              ; set error
              rtn                      ; and return


finished:     mov       rf,fixups      ; point to fixups table
              ldn       rf             ; check for fixups
              lbz       nofixups       ; jump if no fixups
              call      dofixups       ; do fixups

nofixups:     call      o_inmsg        ; display data
              db        'Writing output : ',0
              mov       rf,outputname
              call      o_msg
              call      o_inmsg
              db        10,13,0

              call      o_inmsg
              db        'Lowest Address : ',0
              hlpr      load_rd,lowest
              mov       rf,buffer
              call      f_hexout4
              ldi       0
              str       rf
              mov       rf,buffer
              call      o_msg
              call      o_inmsg
              db        10,13,0

              call      o_inmsg
              db        'Highest Address: ',0
              hlpr      load_rd,highest
              mov       rf,buffer
              call      f_hexout4
              ldi       0
              str       rf
              mov       rf,buffer
              call      o_msg
              call      o_inmsg
              db        10,13,0
              
              mov       rf,fixups      ; need to check for unresolved references
              ldn       rf             ; get first byte
              lbz       no_unresolv    ; jump if no unresolved references
              call      o_inmsg        ; display message
              db        10,13,'Unresolved references:',10,13,0
unresolv_lp:  ldn       rf             ; get byte from fixup name
              lbz       no_unresolv    ; jump if hit end of table
              call      o_inmsg
              db        '  ',0
uname_lp:     lda       rf             ; get byte from name
              lbz       uname_dn       ; jump if done with name
              call      o_type         ; output name character
              lbr       uname_lp       ; loop until done
uname_dn:     inc       rf             ; move past type
              inc       rf             ; move past address
              inc       rf
              inc       rf             ; move past offset
              call      o_inmsg
              db        10,13,0
              lbr       unresolv_lp    ; loop for remaining entries

no_unresolv:  hlpr      load_d,flags   ; get flags
              ani       1              ; check for show symbols
              lbz       no_symbols     ; jump if show symbols not specified
              call      o_inmsg
              db        10,13,'Symbols:',10,13,0
              hlpr      load_rf,symbols ; point to symbol table
sym_loop:     ldn       rf             ; see if done with symbols
              lbz       no_symbols     ; jump if no more symbols
              call      o_inmsg
              db        '  ',0
              ldi       0              ; clear counter
              plo       rc
sym_name:     lda       rf             ; get byte from symbol name
              lbz       pad_loop       ; jump if done with name
              call      o_type         ; display byte
              inc       rc             ; increment counter
              lbr       sym_name       ; loop until done with name
pad_loop:     glo       rc             ; see if enough characters output
              smi       20
              lbdf      pad_done       ; jump if done with padding
              ldi       ' '            ; output a space
              call      o_type
              inc       rc             ; increment counter
              lbr       pad_loop       ; continue til enough padding added
pad_done:     lda       rf             ; get symbol value
              phi       rd
              lda       rf
              plo       rd
              push      rf             ; save rf
              mov       rf,buffer      ; where to put conversion
              call      f_hexout4      ; conver to ascii hex
              ldi       0              ; terminate
              str       rf
              mov       rf,buffer      ; point to conversion
              call      o_msg          ; and display it
              call      o_inmsg        ; display cr/lf
              db        10,13,0
              pop       rf             ; recover table position
              lbr       sym_loop       ; and show remaining symbols

no_symbols:
              hlpr      load_d,outputmode
              plo       re             ; save mode
              smi       'B'            ; check binary mode
              lbz       binary
              glo       re             ; recover mode
              smi       'E'            ; check Elf/OS mode
              lbz       elfos          ; jump if so
              glo       re             ; recover mode
              smi       'H'            ; check RCS hex
              lbz       rcshex         ; jump if so
              glo       re             ; recover mode
              smi       'I'            ; check Intel hex
              lbz       intel          ; jump if so
              lbr       return

binary:       call      writebinary    ; write binary file
              lbr       return         ; then return

elfos:        call      writeelfos     ; write elfos executable
              lbr       return         ; then return

rcshex:       call      writercs       ; write RCS hex file
              lbr       return         ; then return

intel:        call      writeintel     ; write intel hex file
              lbr       return

return:       ldi       0              ; set return code
              rtn                      ; return to OS

memfile:      db        'vmem.dat',0
buffer:       ds        128
fildes:       dw        0,0
              dw        dta
file_eof:     dw        0
file_flags:   db        0
file_dirsec:  dw        0,0
file_dirofs:  dw        0
file_sector:  dw        0,0
file_bytes:   db        0
file_ptr:     dw        0
file_line:    ds        80
dta:          ds        512

vmemdta:      ds        512
flags:        db        0

              public    address
              public    buffer
              public    fildes
              public    highest
              public    incopy
              public    load_d
              public    load_r7
              public    load_r8
              public    load_ra
              public    load_rb
              public    load_rc
              public    load_rd
              public    load_rf
              public    loadsec
              public    lowest
              public    nextfixup
              public    outputname
              public    procbase
              public    save_d
              public    save_r7
              public    save_r8
              public    save_ra
              public    save_rf
              public    savesec
              public    startaddr
              public    symbols
              public    vmemau
              public    vmemdta
              public    vmemsec
              public    vmemrsec

              end       begin



