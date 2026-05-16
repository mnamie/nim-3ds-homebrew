## OS utility bindings matching libctru's os.h

import types

# System clock constants (Hz)
const
  SYSCLOCK_SOC* = 16_756_991'u32
  SYSCLOCK_SYS* = SYSCLOCK_SOC * 2
  SYSCLOCK_SDMMC* = SYSCLOCK_SYS * 2
  SYSCLOCK_ARM9* = SYSCLOCK_SYS * 4
  SYSCLOCK_ARM11* = SYSCLOCK_ARM9 * 2
  SYSCLOCK_ARM11_LGR1* = SYSCLOCK_ARM11 * 2
  SYSCLOCK_ARM11_LGR2* = SYSCLOCK_ARM11 * 3
  SYSCLOCK_ARM11_NEW* = SYSCLOCK_ARM11_LGR2

  CPU_TICKS_PER_MSEC* = SYSCLOCK_ARM11.float / 1000.0
  CPU_TICKS_PER_USEC* = SYSCLOCK_ARM11.float / 1_000_000.0

# Virtual address space landmarks
const
  OS_HEAP_AREA_BEGIN* = 0x08000000'u32
  OS_HEAP_AREA_END* = 0x0E000000'u32
  OS_MAP_AREA_BEGIN* = 0x10000000'u32
  OS_MAP_AREA_END* = 0x14000000'u32
  OS_FCRAM_VADDR* = 0x30000000'u32
  OS_FCRAM_PADDR* = 0x20000000'u32
  OS_FCRAM_SIZE* = 0x10000000'u32
  OS_VRAM_VADDR* = 0x1F000000'u32
  OS_VRAM_PADDR* = 0x18000000'u32
  OS_VRAM_SIZE* = 0x00600000'u32
  OS_DSPRAM_VADDR* = 0x1FF00000'u32
  OS_DSPRAM_SIZE* = 0x00080000'u32

func systemVersion*(major, minor, revision: int): u32 =
  u32((major shl 24) or (minor shl 16) or (revision shl 8))
func getVersionMajor*(v: u32): int = int(v shr 24)
func getVersionMinor*(v: u32): int = int((v shr 16) and 0xFF)
func getVersionRevision*(v: u32): int = int((v shr 8) and 0xFF)

type
  osTimeRef_s* {.importc: "osTimeRef_s",
                 header: "<3ds/os.h>", bycopy.} = object
    value_ms*: u64    ## ms since 1900-01-01 at last update
    value_tick*: u64  ## system ticks at last update
    sysclock_hz*: s64 ## measured ARM11 clock in Hz
    drift_ms*: s64    ## measured RTC drift in ms

  TickCounter* {.importc: "TickCounter",
                 header: "<3ds/os.h>", bycopy.} = object
    elapsed*: u64   ## CPU ticks between last two measurements
    reference*: u64 ## Reference tick snapshot

  OS_VersionBin* {.importc: "OS_VersionBin",
                   header: "<3ds/os.h>", bycopy.} = object
    build*: u8
    minor*: u8
    mainver*: u8
    reserved_x3*: u8
    region*: cchar
    reserved_x5*: array[3, u8]

proc osConvertVirtToPhys*(vaddr: pointer): u32 {.importc, header: "<3ds.h>".}
proc osConvertOldLINEARMemToNew*(vaddr: pointer): pointer {.importc,
    header: "<3ds.h>".}
proc osStrError*(error: Result): cstring {.importc, header: "<3ds.h>".}
proc osGetTimeRef*(): osTimeRef_s {.importc, header: "<3ds.h>".}
proc osGetTime*(): u64 {.importc, header: "<3ds.h>".}
proc osTickCounterRead*(cnt: ptr TickCounter): cdouble {.importc,
    header: "<3ds.h>".}
proc osSetSpeedupEnable*(enable: bool) {.importc, header: "<3ds.h>".}
proc osGetSystemVersionData*(nver, cver: ptr OS_VersionBin): Result
  {.importc, header: "<3ds.h>".}
proc osGetSystemVersionDataString*(nver, cver: ptr OS_VersionBin,
  sysverstr: cstring, maxsize: u32): Result {.importc, header: "<3ds.h>".}

# Tick counter helpers (matching the C inline functions, calling svcGetSystemTick)
proc svcGetSystemTick*(): u64 {.importc, header: "<3ds.h>".}

proc tickCounterStart*(cnt: var TickCounter) {.inline.} =
  cnt.reference = svcGetSystemTick()

proc tickCounterUpdate*(cnt: var TickCounter) {.inline.} =
  let now = svcGetSystemTick()
  cnt.elapsed = now - cnt.reference
  cnt.reference = now

# Shared config accessors (matching os.h inline functions)
proc osGetWifiStrength*(): u8 {.importc, header: "<3ds.h>".}
proc osGet3DSliderState*(): cfloat {.importc, header: "<3ds.h>".}
proc osIsHeadsetConnected*(): bool {.importc, header: "<3ds.h>".}
proc osGetFirmVersion*(): u32 {.importc, header: "<3ds.h>".}
proc osGetKernelVersion*(): u32 {.importc, header: "<3ds.h>".}
