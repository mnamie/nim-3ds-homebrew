## HID (Human Interface Device) service bindings matching libctru's hid.h

import types

# Button bitmasks — use with hidKeysHeld/hidKeysDown/hidKeysUp
const
  KEY_A* = 1'u32 shl 0             ## A button
  KEY_B* = 1'u32 shl 1             ## B button
  KEY_SELECT* = 1'u32 shl 2        ## Select button
  KEY_START* = 1'u32 shl 3         ## Start button
  KEY_DRIGHT* = 1'u32 shl 4        ## D-Pad Right
  KEY_DLEFT* = 1'u32 shl 5         ## D-Pad Left
  KEY_DUP* = 1'u32 shl 6           ## D-Pad Up
  KEY_DDOWN* = 1'u32 shl 7         ## D-Pad Down
  KEY_R* = 1'u32 shl 8             ## R shoulder
  KEY_L* = 1'u32 shl 9             ## L shoulder
  KEY_X* = 1'u32 shl 10            ## X button
  KEY_Y* = 1'u32 shl 11            ## Y button
  KEY_ZL* = 1'u32 shl 14           ## ZL (New 3DS only)
  KEY_ZR* = 1'u32 shl 15           ## ZR (New 3DS only)
  KEY_TOUCH* = 1'u32 shl 20        ## Touchscreen touched
  KEY_CSTICK_RIGHT* = 1'u32 shl 24 ## C-Stick Right (New 3DS only)
  KEY_CSTICK_LEFT* = 1'u32 shl 25  ## C-Stick Left  (New 3DS only)
  KEY_CSTICK_UP* = 1'u32 shl 26    ## C-Stick Up    (New 3DS only)
  KEY_CSTICK_DOWN* = 1'u32 shl 27  ## C-Stick Down  (New 3DS only)
  KEY_CPAD_RIGHT* = 1'u32 shl 28   ## Circle Pad Right
  KEY_CPAD_LEFT* = 1'u32 shl 29    ## Circle Pad Left
  KEY_CPAD_UP* = 1'u32 shl 30      ## Circle Pad Up
  KEY_CPAD_DOWN* = 1'u32 shl 31    ## Circle Pad Down

  # Generic directional aliases (D-Pad OR Circle Pad)
  KEY_UP* = KEY_DUP or KEY_CPAD_UP
  KEY_DOWN* = KEY_DDOWN or KEY_CPAD_DOWN
  KEY_LEFT* = KEY_DLEFT or KEY_CPAD_LEFT
  KEY_RIGHT* = KEY_DRIGHT or KEY_CPAD_RIGHT

type
  touchPosition* {.importc: "touchPosition",
                   header: "<3ds/services/hid.h>", bycopy.} = object
    px*: u16 ## Touch X position
    py*: u16 ## Touch Y position

  circlePosition* {.importc: "circlePosition",
                    header: "<3ds/services/hid.h>", bycopy.} = object
    dx*: s16 ## Circle Pad X (-156..156)
    dy*: s16 ## Circle Pad Y (-156..156)

  accelVector* {.importc: "accelVector",
                 header: "<3ds/services/hid.h>", bycopy.} = object
    x*: s16
    y*: s16
    z*: s16

  angularRate* {.importc: "angularRate",
                 header: "<3ds/services/hid.h>", bycopy.} = object
    x*: s16 ## Roll
    z*: s16 ## Yaw
    y*: s16 ## Pitch

  HID_Event* {.size: 4.} = enum
    HIDEVENT_PAD0 = 0
    HIDEVENT_PAD1 = 1
    HIDEVENT_Accel = 2
    HIDEVENT_Gyro = 3
    HIDEVENT_DebugPad = 4
    HIDEVENT_MAX = 5

proc hidInit*(): Result {.importc, header: "<3ds.h>".}
proc hidExit*() {.importc, header: "<3ds.h>".}

proc hidSetRepeatParameters*(delay, interval: u32) {.importc,
    header: "<3ds.h>".}

proc hidScanInput*() {.importc, header: "<3ds.h>".}
proc hidKeysHeld*(): u32 {.importc, header: "<3ds.h>".}
proc hidKeysDown*(): u32 {.importc, header: "<3ds.h>".}
proc hidKeysDownRepeat*(): u32 {.importc, header: "<3ds.h>".}
proc hidKeysUp*(): u32 {.importc, header: "<3ds.h>".}

proc hidTouchRead*(pos: ptr touchPosition) {.importc, header: "<3ds.h>".}
proc hidCircleRead*(pos: ptr circlePosition) {.importc, header: "<3ds.h>".}
proc hidAccelRead*(vector: ptr accelVector) {.importc, header: "<3ds.h>".}
proc hidGyroRead*(rate: ptr angularRate) {.importc, header: "<3ds.h>".}

proc hidWaitForEvent*(id: HID_Event, nextEvent: bool) {.importc,
    header: "<3ds.h>".}
proc hidWaitForAnyEvent*(nextEvents: bool, cancelEvent: Handle,
  timeout: s64): Result {.importc, header: "<3ds.h>".}

proc HIDUSER_GetHandles*(outMemHandle, eventpad0, eventpad1,
  eventaccel, eventgyro, eventdebugpad: ptr Handle): Result
  {.importc, header: "<3ds.h>".}

proc HIDUSER_EnableAccelerometer*(): Result {.importc, header: "<3ds.h>".}
proc HIDUSER_DisableAccelerometer*(): Result {.importc, header: "<3ds.h>".}
proc HIDUSER_EnableGyroscope*(): Result {.importc, header: "<3ds.h>".}
proc HIDUSER_DisableGyroscope*(): Result {.importc, header: "<3ds.h>".}
proc HIDUSER_GetGyroscopeRawToDpsCoefficient*(coeff: ptr cfloat): Result
  {.importc, header: "<3ds.h>".}
proc HIDUSER_GetSoundVolume*(volume: ptr u8): Result {.importc,
    header: "<3ds.h>".}
