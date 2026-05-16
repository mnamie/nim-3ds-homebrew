import ctru

proc printf(fmt: cstring) {.importc, header: "<stdio.h>", varargs.}

gfxInitDefault()
discard consoleInit(GFX_TOP, nil)

printf("Hello from Nim on 3DS!\n")
printf("Press START to exit.\n")

while aptMainLoop():
  hidScanInput()
  if (hidKeysDown() and KEY_START) != 0:
    break
  gfxFlushBuffers()
  gfxSwapBuffers()
  gspWaitForVBlank()

gfxExit()
