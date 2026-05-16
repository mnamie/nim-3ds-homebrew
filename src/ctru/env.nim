## Homebrew environment bindings matching libctru's env.h

import types

const
  RUNFLAG_APTWORKAROUND* = 1'u32 shl 0 ## Use APT workaround
  RUNFLAG_APTREINIT* = 1'u32 shl 1     ## Reinitialize APT
  RUNFLAG_APTCHAINLOAD* = 1'u32 shl 2  ## Chainload APT on return

# These are C inline functions that read linker-defined symbols.
# Binding them via importc works because the C compiler sees the header
# and inlines the access directly.
proc envIsHomebrew*(): bool {.importc, header: "<3ds.h>".}
proc envGetHandle*(name: cstring): Handle {.importc, header: "<3ds.h>".}
proc envGetAptAppId*(): u32 {.importc, header: "<3ds.h>".}
proc envGetHeapSize*(): u32 {.importc, header: "<3ds.h>".}
proc envGetLinearHeapSize*(): u32 {.importc, header: "<3ds.h>".}
proc envGetSystemArgList*(): cstring {.importc, header: "<3ds.h>".}
proc envGetSystemRunFlags*(): u32 {.importc, header: "<3ds.h>".}
