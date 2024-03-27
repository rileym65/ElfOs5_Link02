#include      macros.inc
#include      bios.inc
#include      kernel.inc

              proc      final

libraries:    ds        256
libpath:      ds        256
fixups:       db        0

              public    fixups
              public    libpath
              public    libraries

              endp

