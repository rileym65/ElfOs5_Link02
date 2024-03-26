#include      macros.inc
#include      bios.inc
#include      kernel.inc

; *****************************************************
; ***** Check that vmem has correct sector loaded *****
; ***** D - Relative sector number                *****
; *****************************************************
              proc      checkvmem

              extrn     load_d
              extrn     loadsec
              extrn     save_d
              extrn     savesec
              extrn     vmemau
              extrn     vmemdta
              extrn     vmemsec
              extrn     vmemrsec

              stxd                     ; save relative sector
              hlpr      load_d,vmemrsec ; get currently loaded relative sector
              irx                      ; point back to passed value
              sm                       ; see if loaded matches requested
              lbz       done           ; jump if so
              ldx                      ; recover desired sector
              hlpr      save_d,vmemrsec ; save new relative sector
              push      r7             ; save consumed registers
              push      r8
              push      ra
              push      rb
              push      rf
              mov       rf,vmemsec     ; get currently loaded sector
              op        loadsec
              ghi       r8
              ori       0e0h
              phi       r8
              mov       rf,vmemdta
              call      d_idewrite     ; save sector to disk
              mov       rf,vmemau      ; point to vmem starting au
              op        loadsec        ; and read it
              ldi       0              ; setup relative sector
              phi       rb
              plo       rb
              phi       ra
              hlpr      load_d,vmemrsec
              plo       ra
              call      o_relsec       ; get new sector
              mov       rf,vmemsec     ; write new sector number
              op        savesec
              ghi       r8
              ori       0e0h
              phi       r8
              mov       rf,vmemdta
              call      d_ideread      ; read new sector from disk
              pop       rf             ; recover used registers
              pop       rb
              pop       ra
              pop       r8
              pop       r7
done:         rtn                      ; return to caller

              endp

