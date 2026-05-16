## Simple framebuffer API matching libctru's gfx.h
##
## The 3DS uses portrait screens rotated 90°. Physical dimensions:
##   Top screen:    240 wide × 400 tall
##   Bottom screen: 240 wide × 320 tall

import types
import gspgpu

type
  gfxScreen_t* {.size: 4.} = enum
    GFX_TOP = 0    ## Top screen
    GFX_BOTTOM = 1 ## Bottom (touch) screen

  gfx3dSide_t* {.size: 4.} = enum
    GFX_LEFT = 0  ## Left eye framebuffer (use this when not in 3D mode)
    GFX_RIGHT = 1 ## Right eye framebuffer (stereoscopic 3D only)

# Pixel packing helpers (implemented in Nim, matching the C macros)
func rgb565*(r, g, b: int): u16 =
  u16((b and 0x1F) or ((g and 0x3F) shl 5) or ((r and 0x1F) shl 11))

func rgb8to565*(r, g, b: int): u16 =
  u16(((b shr 3) and 0x1F) or (((g shr 2) and 0x3F) shl 5) or
      (((r shr 3) and 0x1F) shl 11))

# Initialization
proc gfxInitDefault*() {.importc, header: "<3ds.h>".}
proc gfxInit*(topFormat, bottomFormat: GSPGPU_FramebufferFormat,
               vrambuffers: bool) {.importc, header: "<3ds.h>".}
proc gfxExit*() {.importc, header: "<3ds.h>".}

# Display mode control
proc gfxSet3D*(enable: bool) {.importc, header: "<3ds.h>".}
proc gfxIs3D*(): bool {.importc, header: "<3ds.h>".}
proc gfxIsWide*(): bool {.importc, header: "<3ds.h>".}
proc gfxSetWide*(enable: bool) {.importc, header: "<3ds.h>".}

proc gfxSetScreenFormat*(screen: gfxScreen_t,
  format: GSPGPU_FramebufferFormat) {.importc, header: "<3ds.h>".}
proc gfxGetScreenFormat*(screen: gfxScreen_t): GSPGPU_FramebufferFormat
  {.importc, header: "<3ds.h>".}
proc gfxSetDoubleBuffering*(screen: gfxScreen_t,
  enable: bool) {.importc, header: "<3ds.h>".}

# Rendering and presentation
proc gfxGetFramebuffer*(screen: gfxScreen_t, side: gfx3dSide_t,
  width, height: ptr u16): ptr u8 {.importc, header: "<3ds.h>".}
proc gfxFlushBuffers*() {.importc, header: "<3ds.h>".}
proc gfxScreenSwapBuffers*(scr: gfxScreen_t,
  hasStereo: bool) {.importc, header: "<3ds.h>".}
proc gfxSwapBuffers*() {.importc, header: "<3ds.h>".}
proc gfxSwapBuffersGpu*() {.importc, header: "<3ds.h>".}
