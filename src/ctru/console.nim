## Console/text output bindings matching libctru's console.h

import types
import gfx

type
  ConsolePrint* = proc (con: pointer, c: cint): bool {.cdecl.}

  ConsoleFont* {.importc: "ConsoleFont", header: "<3ds/console.h>",
      bycopy.} = object
    gfx*: ptr u8      ## Pointer to font graphics
    asciiOffset*: u16 ## Offset to first valid character in font table
    numChars*: u16    ## Number of characters in the font graphics

  PrintConsole* {.importc: "PrintConsole", header: "<3ds/console.h>",
      bycopy.} = object
    font*: ConsoleFont
    frameBuffer*: ptr u16
    cursorX*: cint
    cursorY*: cint
    prevCursorX*: cint
    prevCursorY*: cint
    consoleWidth*: cint
    consoleHeight*: cint
    windowX*: cint
    windowY*: cint
    windowWidth*: cint
    windowHeight*: cint
    tabSize*: cint
    fg*: u16
    bg*: u16
    flags*: cint
    PrintChar*: ConsolePrint
    consoleInitialised*: bool

  debugDevice* {.size: 4.} = enum
    debugDevice_NULL = 0    ## Swallows stderr
    debugDevice_SVC = 1     ## stderr via svcOutputDebugString
    debugDevice_CONSOLE = 2 ## stderr to 3DS console window

# Console flags (for PrintConsole.flags)
const
  CONSOLE_COLOR_BOLD* = 1 shl 0
  CONSOLE_COLOR_FAINT* = 1 shl 1
  CONSOLE_ITALIC* = 1 shl 2
  CONSOLE_UNDERLINE* = 1 shl 3
  CONSOLE_BLINK_SLOW* = 1 shl 4
  CONSOLE_BLINK_FAST* = 1 shl 5
  CONSOLE_COLOR_REVERSE* = 1 shl 6
  CONSOLE_CONCEAL* = 1 shl 7
  CONSOLE_CROSSED_OUT* = 1 shl 8
  CONSOLE_FG_CUSTOM* = 1 shl 9
  CONSOLE_BG_CUSTOM* = 1 shl 10
  CONSOLE_COLOR_FG_BRIGHT* = 1 shl 11
  CONSOLE_COLOR_BG_BRIGHT* = 1 shl 12

# ANSI escape code color strings (pass directly to printf)
const
  CONSOLE_RESET* = "\x1b[0m"
  CONSOLE_BLACK* = "\x1b[30m"
  CONSOLE_RED* = "\x1b[31;1m"
  CONSOLE_GREEN* = "\x1b[32;1m"
  CONSOLE_YELLOW* = "\x1b[33;1m"
  CONSOLE_BLUE* = "\x1b[34;1m"
  CONSOLE_MAGENTA* = "\x1b[35;1m"
  CONSOLE_CYAN* = "\x1b[36;1m"
  CONSOLE_WHITE* = "\x1b[37;1m"

proc consoleSetFont*(console: ptr PrintConsole,
  font: ptr ConsoleFont) {.importc, header: "<3ds.h>".}
proc consoleSetWindow*(console: ptr PrintConsole,
  x, y, width, height: cint) {.importc, header: "<3ds.h>".}
proc consoleGetDefault*(): ptr PrintConsole {.importc, header: "<3ds.h>".}
proc consoleSelect*(console: ptr PrintConsole): ptr PrintConsole
  {.importc, header: "<3ds.h>".}
proc consoleInit*(screen: gfxScreen_t,
  console: ptr PrintConsole): ptr PrintConsole {.importc, header: "<3ds.h>", discardable.}
proc consoleDebugInit*(device: debugDevice) {.importc, header: "<3ds.h>".}
proc consoleClear*() {.importc, header: "<3ds.h>".}
