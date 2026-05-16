## APT (Applet) service bindings matching libctru's apt.h

import types

type
  NS_APPID* {.size: 4.} = enum
    APPID_NONE = 0x000
    APPID_HOMEMENU = 0x101
    APPID_CAMERA = 0x110
    APPID_FRIENDS_LIST = 0x112
    APPID_GAME_NOTES = 0x113
    APPID_WEB = 0x114
    APPID_INSTRUCTION_MANUAL = 0x115
    APPID_NOTIFICATIONS = 0x116
    APPID_MIIVERSE = 0x117
    APPID_MIIVERSE_POSTING = 0x118
    APPID_AMIIBO_SETTINGS = 0x119
    APPID_APPLICATION = 0x300
    APPID_ESHOP = 0x301
    APPID_SOFTWARE_KEYBOARD = 0x401
    APPID_APPLETED = 0x402
    APPID_PNOTE_AP = 0x404
    APPID_SNOTE_AP = 0x405
    APPID_ERROR = 0x406
    APPID_MINT = 0x407
    APPID_EXTRAPAD = 0x408
    APPID_MEMOLIB = 0x409

  APT_AppletPos* {.size: 4.} = enum
    APTPOS_NONE = -1
    APTPOS_APP = 0
    APTPOS_APPLIB = 1
    APTPOS_SYS = 2
    APTPOS_SYSLIB = 3
    APTPOS_RESIDENT = 4

  APT_QueryReply* {.size: 4.} = enum
    APTREPLY_REJECT = 0
    APTREPLY_ACCEPT = 1
    APTREPLY_LATER = 2

  APT_Signal* {.size: 4.} = enum
    APTSIGNAL_NONE = 0
    APTSIGNAL_HOMEBUTTON = 1
    APTSIGNAL_HOMEBUTTON2 = 2
    APTSIGNAL_SLEEP_QUERY = 3
    APTSIGNAL_SLEEP_CANCEL = 4
    APTSIGNAL_SLEEP_ENTER = 5
    APTSIGNAL_SLEEP_WAKEUP = 6
    APTSIGNAL_SHUTDOWN = 7
    APTSIGNAL_POWERBUTTON = 8
    APTSIGNAL_POWERBUTTON2 = 9
    APTSIGNAL_TRY_SLEEP = 10
    APTSIGNAL_ORDERTOCLOSE = 11

  APT_Command* {.size: 4.} = enum
    APTCMD_NONE = 0
    APTCMD_WAKEUP = 1
    APTCMD_REQUEST = 2
    APTCMD_RESPONSE = 3
    APTCMD_EXIT = 4
    APTCMD_MESSAGE = 5
    APTCMD_HOMEBUTTON_ONCE = 6
    APTCMD_HOMEBUTTON_TWICE = 7
    APTCMD_DSP_SLEEP = 8
    APTCMD_DSP_WAKEUP = 9
    APTCMD_WAKEUP_EXIT = 10
    APTCMD_WAKEUP_PAUSE = 11
    APTCMD_WAKEUP_CANCEL = 12
    APTCMD_WAKEUP_CANCELALL = 13
    APTCMD_WAKEUP_POWERBUTTON = 14
    APTCMD_WAKEUP_JUMPTOHOME = 15
    APTCMD_SYSAPPLET_REQUEST = 16
    APTCMD_WAKEUP_LAUNCHAPP = 17

  APT_HookType* {.size: 4.} = enum
    APTHOOK_ONSUSPEND = 0
    APTHOOK_ONRESTORE = 1
    APTHOOK_ONSLEEP = 2
    APTHOOK_ONWAKEUP = 3
    APTHOOK_ONEXIT = 4
    APTHOOK_COUNT = 5

  APT_AppletAttr* = u8

  aptHookFn* = proc (hook: APT_HookType, param: pointer) {.cdecl.}
  aptMessageCb* = proc (user: pointer, sender: NS_APPID,
                         msg: pointer, msgsize: csize_t) {.cdecl.}

  aptHookCookie* {.importc: "aptHookCookie",
                   header: "<3ds/services/apt.h>", bycopy.} = object
    next*: ptr aptHookCookie
    callback*: aptHookFn
    param*: pointer

  aptCaptureBufInfo* {.importc: "aptCaptureBufInfo",
                       header: "<3ds/services/apt.h>", bycopy.} = object
    size*: u32
    is3D*: u32
    # top and bottom sub-structs omitted for simplicity

proc aptInit*(): Result {.importc, header: "<3ds.h>".}
proc aptExit*() {.importc, header: "<3ds.h>".}

proc aptIsActive*(): bool {.importc, header: "<3ds.h>".}
proc aptShouldClose*(): bool {.importc, header: "<3ds.h>".}
proc aptIsSleepAllowed*(): bool {.importc, header: "<3ds.h>".}
proc aptSetSleepAllowed*(allowed: bool) {.importc, header: "<3ds.h>".}
proc aptHandleSleep*() {.importc, header: "<3ds.h>".}
proc aptIsHomeAllowed*(): bool {.importc, header: "<3ds.h>".}
proc aptSetHomeAllowed*(allowed: bool) {.importc, header: "<3ds.h>".}
proc aptShouldJumpToHome*(): bool {.importc, header: "<3ds.h>".}
proc aptCheckHomePressRejected*(): bool {.importc, header: "<3ds.h>".}
proc aptJumpToHomeMenu*() {.importc, header: "<3ds.h>".}
proc aptMainLoop*(): bool {.importc, header: "<3ds.h>".}

proc aptHook*(cookie: ptr aptHookCookie, callback: aptHookFn,
               param: pointer) {.importc, header: "<3ds.h>".}
proc aptUnhook*(cookie: ptr aptHookCookie) {.importc, header: "<3ds.h>".}
proc aptSetMessageCallback*(callback: aptMessageCb,
  user: pointer) {.importc, header: "<3ds.h>".}

proc aptLaunchLibraryApplet*(appId: NS_APPID, buf: pointer,
  bufsize: csize_t, handle: Handle) {.importc, header: "<3ds.h>".}
proc aptLaunchSystemApplet*(appId: NS_APPID, buf: pointer,
  bufsize: csize_t, handle: Handle) {.importc, header: "<3ds.h>".}

proc aptClearChainloader*() {.importc, header: "<3ds.h>".}
proc aptSetChainloader*(programID: u64, mediatype: u8) {.importc,
    header: "<3ds.h>".}
proc aptSetChainloaderToCaller*() {.importc, header: "<3ds.h>".}
proc aptSetChainloaderToSelf*() {.importc, header: "<3ds.h>".}

# Low-level APT IPC functions
proc APT_GetLockHandle*(flags: u16, lockHandle: ptr Handle): Result
  {.importc, header: "<3ds.h>".}
proc APT_Initialize*(appId: NS_APPID, attr: APT_AppletAttr,
  signalEvent, resumeEvent: ptr Handle): Result {.importc, header: "<3ds.h>".}
proc APT_Finalize*(appId: NS_APPID): Result {.importc, header: "<3ds.h>".}
proc APT_HardwareResetAsync*(): Result {.importc, header: "<3ds.h>".}
proc APT_Enable*(attr: APT_AppletAttr): Result {.importc, header: "<3ds.h>".}
proc APT_CheckNew3DS*(isNew: ptr bool): Result {.importc, header: "<3ds.h>".}
proc APT_GetProgramID*(pProgramID: ptr u64): Result {.importc,
    header: "<3ds.h>".}
proc APT_SetAppCpuTimeLimit*(percent: u32): Result {.importc,
    header: "<3ds.h>".}
proc APT_GetAppCpuTimeLimit*(percent: ptr u32): Result {.importc,
    header: "<3ds.h>".}
proc APT_GetSharedFont*(fontHandle: ptr Handle,
  mapAddr: ptr u32): Result {.importc, header: "<3ds.h>".}
proc APT_SendCaptureBufferInfo*(
  captureBuf: ptr aptCaptureBufInfo): Result {.importc, header: "<3ds.h>".}
proc APT_PrepareToCloseApplication*(cancelPreload: bool): Result
  {.importc, header: "<3ds.h>".}
