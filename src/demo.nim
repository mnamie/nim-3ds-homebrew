## demo.nim — API exercise covering most libctru subsystems.
##
## Pages (cycle with L / R):
##   1  System    — kernel version, New 3DS, wifi, 3D slider, heap sizes, APT state
##   2  Input     — all buttons, touch position, circle pad
##   3  Sensors   — accelerometer and gyroscope (enabled on first visit)
##   4  Timing    — per-frame timing via TickCounter and osGetTime

import ctru

proc printf(fmt: cstring) {.importc, header: "<stdio.h>", varargs.}

# ── ANSI helpers (cstring so they pass through printf varargs safely) ────────
const
  CYN: cstring = "\x1b[36;1m"
  YLW: cstring = "\x1b[33;1m"
  GRN: cstring = "\x1b[32;1m"
  RED: cstring = "\x1b[31;1m"
  WHT: cstring = "\x1b[37;1m"
  RST: cstring = "\x1b[0m"
  CLR: cstring = "\x1b[2J" # clear screen
  HOME: cstring = "\x1b[H" # cursor to top-left

# ── Helpers ──────────────────────────────────────────────────────────────────
func yn(b: bool): cstring = (if b: cstring"yes" else: cstring"no")
func okFail(b: bool): cstring = (if b: cstring"enabled" else: cstring"FAILED")

# ── State ────────────────────────────────────────────────────────────────────
type Page = enum pgSystem, pgInput, pgSensors, pgTiming

var
  page = pgSystem
  topCon, botCon: PrintConsole
  accelEnabled = false
  gyroEnabled = false
  ticker: TickCounter
  frameMs: cdouble = 0.0
  totalFrames: uint32 = 0
  # Uptime in ms since aptMainLoop first ran
  startTime: u64 = 0

# ── Page: System ─────────────────────────────────────────────────────────────
proc drawSystem() =
  printf("%s%s", CLR, HOME)
  printf("%s=== Nim 3DS API Demo ===\x1b[0m\n", CYN)
  printf("%s[ 1/4 ] System Info\x1b[0m\n\n", YLW)

  var isNew: bool
  discard APT_CheckNew3DS(addr isNew)

  let kv = osGetKernelVersion()
  let fv = osGetFirmVersion()

  printf("Homebrew:    %s%s%s\n", GRN, envIsHomebrew().yn, RST)
  printf("New 3DS:     %s\n",   isNew.yn)
  printf("Kernel:      %d.%d.%d\n",
    getVersionMajor(kv).cint, getVersionMinor(kv).cint, getVersionRevision(kv).cint)
  printf("Firmware:    %d.%d.%d\n",
    getVersionMajor(fv).cint, getVersionMinor(fv).cint, getVersionRevision(fv).cint)
  printf("\n")

  let wifi = osGetWifiStrength()
  let slider = osGet3DSliderState()
  let wifiBar: cstring = case wifi
    of 0: cstring"[--]"
    of 1: cstring"[x-]"
    of 2: cstring"[xx]"
    else: cstring"[XX]"
  printf("WiFi:        %u/3  %s\n", wifi.cuint, wifiBar)
  printf("3D Slider:   %.2f\n", slider.cdouble)
  printf("Headset:     %s\n", (if osIsHeadsetConnected(): cstring"connected" else: cstring"no"))
  printf("\n")

  printf("Heap:        %u KB\n", (envGetHeapSize() div 1024).cuint)
  printf("Linear heap: %u KB\n", (envGetLinearHeapSize() div 1024).cuint)
  printf("\n")

  printf("GPU right:   %s\n", gspHasGpuRight().yn)
  printf("Sleep OK:    %s\n", aptIsSleepAllowed().yn)
  printf("Home OK:     %s\n", aptIsHomeAllowed().yn)

# ── Page: Input ──────────────────────────────────────────────────────────────
proc btnCh(keys: u32, mask: u32): cint =
  (if (keys and mask) != 0: 'X'.ord else: '.'.ord).cint

proc drawInput() =
  printf("%s%s", CLR, HOME)
  printf("%s=== Nim 3DS API Demo ===\x1b[0m\n", CYN)
  printf("%s[ 2/4 ] Input Test\x1b[0m\n\n", YLW)

  let held = hidKeysHeld()
  let downed = hidKeysDown()
  let upped = hidKeysUp()

  var touch: touchPosition
  var circle: circlePosition
  hidTouchRead(addr touch)
  hidCircleRead(addr circle)

  printf("Face:    A:%c  B:%c  X:%c  Y:%c\n",
    btnCh(held, KEY_A), btnCh(held, KEY_B),
    btnCh(held, KEY_X), btnCh(held, KEY_Y))
  printf("Shldr:   L:%c  R:%c  ZL:%c ZR:%c\n",
    btnCh(held, KEY_L), btnCh(held, KEY_R),
    btnCh(held, KEY_ZL), btnCh(held, KEY_ZR))
  printf("D-Pad:   U:%c  D:%c  L:%c  R:%c\n",
    btnCh(held, KEY_DUP), btnCh(held, KEY_DDOWN),
    btnCh(held, KEY_DLEFT), btnCh(held, KEY_DRIGHT))
  printf("Other:   Sel:%c  Sta:%c  Tch:%c\n",
    btnCh(held, KEY_SELECT), btnCh(held, KEY_START), btnCh(held, KEY_TOUCH))
  printf("\n")

  printf("Circle pad:  dx=%4d  dy=%4d\n", circle.dx.cint, circle.dy.cint)
  printf("C-Stick:     U:%c D:%c L:%c R:%c  (New 3DS)\n",
    btnCh(held, KEY_CSTICK_UP), btnCh(held, KEY_CSTICK_DOWN),
    btnCh(held, KEY_CSTICK_LEFT), btnCh(held, KEY_CSTICK_RIGHT))
  printf("\n")

  if (held and KEY_TOUCH) != 0:
    printf("Touch:  %sx=%3d  y=%3d%s\n", GRN, touch.px.cint, touch.py.cint, RST)
  else:
    printf("Touch:  not pressed\n")

  printf("\n")
  printf("Pressed  this frame: %08X\n", downed.cuint)
  printf("Released this frame: %08X\n", upped.cuint)

# ── Page: Sensors ────────────────────────────────────────────────────────────
proc enableSensors() =
  if not accelEnabled:
    let r = HIDUSER_EnableAccelerometer()
    accelEnabled = rSucceeded(r)
  if not gyroEnabled:
    let r = HIDUSER_EnableGyroscope()
    gyroEnabled = rSucceeded(r)

proc drawSensors() =
  enableSensors()

  var accel: accelVector
  var gyro: angularRate
  hidAccelRead(addr accel)
  hidGyroRead(addr gyro)

  printf("%s%s", CLR, HOME)
  printf("%s=== Nim 3DS API Demo ===\x1b[0m\n", CYN)
  printf("%s[ 3/4 ] Sensors\x1b[0m\n\n", YLW)

  printf("Accelerometer: %s\n", accelEnabled.okFail)
  printf("  X: %6d\n", accel.x.cint)
  printf("  Y: %6d\n", accel.y.cint)
  printf("  Z: %6d\n", accel.z.cint)
  printf("\n")

  printf("Gyroscope:     %s\n", gyroEnabled.okFail)
  printf("  Roll  (X): %6d\n", gyro.x.cint)
  printf("  Pitch (Y): %6d\n", gyro.y.cint)
  printf("  Yaw   (Z): %6d\n", gyro.z.cint)
  printf("\n")
  printf("(Tilt or rotate the console)\n")

# ── Page: Timing ─────────────────────────────────────────────────────────────
proc drawTiming() =
  printf("%s%s", CLR, HOME)
  printf("%s=== Nim 3DS API Demo ===\x1b[0m\n", CYN)
  printf("%s[ 4/4 ] Timing\x1b[0m\n\n", YLW)

  let uptimeMs = osGetTime() - startTime
  let uptimeSec = uptimeMs div 1000
  let uptimeMin = uptimeSec div 60

  printf("Frame time:  %.3f ms\n", frameMs)
  printf("FPS (est):   %.1f\n", (if frameMs > 0.0: 1000.0 / frameMs else: 0.0))
  printf("Frame count: %u\n", totalFrames.cuint)
  printf("\n")
  printf("Uptime:      %um %02us\n", uptimeMin.cuint, (uptimeSec mod 60).cuint)
  printf("osGetTime(): %llu ms\n", uptimeMs.culonglong)
  printf("\n")

  let ticksNow = svcGetSystemTick()
  printf("Tick now:    %llu\n", ticksNow.culonglong)
  printf("ARM11 clock: %u MHz\n", (SYSCLOCK_ARM11 div 1_000_000).cuint)
  printf("ms/tick:     %.6f\n", (1000.0 / SYSCLOCK_ARM11.float64))

# ── Bottom screen navigation ─────────────────────────────────────────────────
proc drawNav() =
  discard consoleSelect(addr botCon)
  printf("%s%s", CLR, HOME)
  printf("%sL/R: change page    START: quit%s\n\n", YLW, RST)
  printf("Pages:\n")
  for i, name in [cstring"System", "Input", "Sensors", "Timing"]:
    if i == page.ord:
      printf("  %s> %s%s\n", GRN, name, RST)
    else:
      printf("    %s\n", name)

# ── Main ─────────────────────────────────────────────────────────────────────
gfxInitDefault()
discard consoleInit(GFX_TOP, addr topCon)
discard consoleInit(GFX_BOTTOM, addr botCon)

startTime = osGetTime()
tickCounterStart(ticker)

while aptMainLoop():
  hidScanInput()
  let keys = hidKeysDown()

  if (keys and KEY_START) != 0:
    break
  if (keys and KEY_R) != 0:
    page = Page((page.ord + 1) mod 4)
  if (keys and KEY_L) != 0:
    page = Page((page.ord + 3) mod 4) # +3 mod 4 = -1 mod 4

  # Measure frame time before rendering
  tickCounterUpdate(ticker)
  frameMs = osTickCounterRead(addr ticker)
  inc totalFrames

  # Draw active page on top screen
  discard consoleSelect(addr topCon)
  case page
  of pgSystem: drawSystem()
  of pgInput: drawInput()
  of pgSensors: drawSensors()
  of pgTiming: drawTiming()

  # Draw nav on bottom screen
  drawNav()

  gfxFlushBuffers()
  gfxSwapBuffers()
  gspWaitForVBlank()

gfxExit()
