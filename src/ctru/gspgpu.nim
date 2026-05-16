## GSPGPU service bindings matching libctru's gspgpu.h

import types

const
  GSP_SCREEN_TOP* = 0.u32
  GSP_SCREEN_BOTTOM* = 1.u32
  GSP_SCREEN_WIDTH* = 240.u32
  GSP_SCREEN_HEIGHT_TOP* = 400.u32
  GSP_SCREEN_HEIGHT_TOP_2X* = 800.u32
  GSP_SCREEN_HEIGHT_BOTTOM* = 320.u32

type
  GSPGPU_FramebufferFormat* {.size: 4.} = enum
    GSP_RGBA8_OES = 0   ## RGBA8 — 4 bytes per pixel
    GSP_BGR8_OES = 1    ## BGR8  — 3 bytes per pixel (default)
    GSP_RGB565_OES = 2  ## RGB565 — 2 bytes per pixel
    GSP_RGB5_A1_OES = 3 ## RGB5A1 — 2 bytes per pixel
    GSP_RGBA4_OES = 4   ## RGBA4  — 2 bytes per pixel

  GSPGPU_Event* {.size: 4.} = enum
    GSPGPU_EVENT_PSC0 = 0 ## Memory fill completed
    GSPGPU_EVENT_PSC1 = 1
    GSPGPU_EVENT_VBlank0 = 2
    GSPGPU_EVENT_VBlank1 = 3
    GSPGPU_EVENT_PPF = 4  ## Display transfer finished
    GSPGPU_EVENT_P3D = 5  ## Command list processing finished
    GSPGPU_EVENT_DMA = 6
    GSPGPU_EVENT_MAX = 7

  GSPGPU_FramebufferInfo* {.importc: "GSPGPU_FramebufferInfo",
                             header: "<3ds/services/gspgpu.h>",
                                 bycopy.} = object
    active_framebuf*: u32
    framebuf0_vaddr*: ptr u32
    framebuf1_vaddr*: ptr u32
    framebuf_widthbytesize*: u32
    format*: u32
    framebuf_dispselect*: u32
    unk*: u32

  GSPGPU_CaptureInfoEntry* {.importc: "GSPGPU_CaptureInfoEntry",
                              header: "<3ds/services/gspgpu.h>",
                                  bycopy.} = object
    framebuf0_vaddr*: ptr u32
    framebuf1_vaddr*: ptr u32
    format*: u32
    framebuf_widthbytesize*: u32

  GSPGPU_CaptureInfo* {.importc: "GSPGPU_CaptureInfo",
                         header: "<3ds/services/gspgpu.h>", bycopy.} = object
    screencapture*: array[2, GSPGPU_CaptureInfoEntry]

  GSPGPU_PerfLogEntry* {.importc: "GSPGPU_PerfLogEntry",
                          header: "<3ds/services/gspgpu.h>", bycopy.} = object
    lastDurationUs*: u32
    totalDurationUs*: u32

  GSPGPU_PerfLog* {.importc: "GSPGPU_PerfLog",
                    header: "<3ds/services/gspgpu.h>", bycopy.} = object
    entries*: array[7, GSPGPU_PerfLogEntry] # GSPGPU_EVENT_MAX = 7

func gspGetBytesPerPixel*(format: GSPGPU_FramebufferFormat): cuint =
  case format
  of GSP_RGBA8_OES: 4
  of GSP_BGR8_OES: 3
  else: 2

proc gspInit*() {.importc, header: "<3ds.h>".}
proc gspExit*() {.importc, header: "<3ds.h>".}

proc gspGetSessionHandle*(): ptr Handle {.importc, header: "<3ds.h>".}
proc gspHasGpuRight*(): bool {.importc, header: "<3ds.h>".}

proc gspPresentBuffer*(screen, swap: cuint, fb_a, fb_b: pointer,
                        stride, mode: u32): bool {.importc, header: "<3ds.h>".}
proc gspIsPresentPending*(screen: cuint): bool {.importc, header: "<3ds.h>".}

proc gspSetEventCallback*(id: GSPGPU_Event, cb: ThreadFunc,
                           data: pointer, oneShot: bool) {.importc,
                               header: "<3ds.h>".}
proc gspWaitForEvent*(id: GSPGPU_Event, nextEvent: bool) {.importc,
    header: "<3ds.h>".}
proc gspWaitForAnyEvent*(): GSPGPU_Event {.importc, header: "<3ds.h>".}

# Convenience wrappers matching the C macros
template gspWaitForVBlank*() = gspWaitForEvent(GSPGPU_EVENT_VBlank0, true)
template gspWaitForVBlank0*() = gspWaitForEvent(GSPGPU_EVENT_VBlank0, true)
template gspWaitForVBlank1*() = gspWaitForEvent(GSPGPU_EVENT_VBlank1, true)
template gspWaitForPSC0*() = gspWaitForEvent(GSPGPU_EVENT_PSC0, false)
template gspWaitForPSC1*() = gspWaitForEvent(GSPGPU_EVENT_PSC1, false)
template gspWaitForPPF*() = gspWaitForEvent(GSPGPU_EVENT_PPF, false)
template gspWaitForP3D*() = gspWaitForEvent(GSPGPU_EVENT_P3D, false)
template gspWaitForDMA*() = gspWaitForEvent(GSPGPU_EVENT_DMA, false)

proc gspSubmitGxCommand*(gxCommand: array[8, u32]): Result {.importc,
    header: "<3ds.h>".}

proc GSPGPU_AcquireRight*(flags: u8): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_ReleaseRight*(): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_SaveVramSysArea*(): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_ResetGpuCore*(): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_RestoreVramSysArea*(): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_SetLcdForceBlack*(flags: u8): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_SetLedForceOff*(disable: bool): Result {.importc,
    header: "<3ds.h>".}

proc GSPGPU_SetBufferSwap*(screenid: u32,
  framebufinfo: ptr GSPGPU_FramebufferInfo): Result {.importc,
      header: "<3ds.h>".}

proc GSPGPU_FlushDataCache*(adr: pointer, size: u32): Result {.importc,
    header: "<3ds.h>".}
proc GSPGPU_InvalidateDataCache*(adr: pointer, size: u32): Result {.importc,
    header: "<3ds.h>".}

proc GSPGPU_WriteHWRegs*(regAddr: u32, data: ptr u32, size: u8): Result
  {.importc, header: "<3ds.h>".}
proc GSPGPU_WriteHWRegsWithMask*(regAddr: u32, data: ptr u32, datasize: u8,
  maskdata: ptr u32, masksize: u8): Result {.importc, header: "<3ds.h>".}
proc GSPGPU_ReadHWRegs*(regAddr: u32, data: ptr u32, size: u8): Result
  {.importc, header: "<3ds.h>".}

proc GSPGPU_RegisterInterruptRelayQueue*(eventHandle: Handle, flags: u32,
  outMemHandle: ptr Handle, threadID: ptr u8): Result {.importc,
      header: "<3ds.h>".}
proc GSPGPU_UnregisterInterruptRelayQueue*(): Result {.importc,
    header: "<3ds.h>".}
proc GSPGPU_TriggerCmdReqQueue*(): Result {.importc, header: "<3ds.h>".}

proc GSPGPU_ImportDisplayCaptureInfo*(
  captureinfo: ptr GSPGPU_CaptureInfo): Result {.importc, header: "<3ds.h>".}

proc GSPGPU_SetPerfLogMode*(enabled: bool): Result {.importc,
    header: "<3ds.h>".}
proc GSPGPU_GetPerfLog*(outPerfLog: ptr GSPGPU_PerfLog): Result {.importc,
    header: "<3ds.h>".}
