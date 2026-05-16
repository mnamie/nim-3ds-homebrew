when defined(nintendo3ds):
  let devkitPro = getEnv("DEVKITPRO", "C:\\devkitPro")
  let devkitArm = getEnv("DEVKITARM", devkitPro & "\\devkitARM")

  switch "cpu", "arm"
  switch "os", "standalone"
  switch "gc", "arc"

  switch "gcc.exe",       devkitArm & "\\bin\\arm-none-eabi-gcc"
  switch "gcc.linkerexe", devkitArm & "\\bin\\arm-none-eabi-gcc"

  # Replace gcc.options.always entirely — removes -mno-ms-bitfields which
  # Nim's global nim.cfg adds on Windows but arm-none-eabi-gcc rejects.
  switch "gcc.options.always",
    "-w -fmax-errors=3 -fno-strict-aliasing" &
    " -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft" &
    " -D__3DS__ -D_3DS"

  switch "cincludes", devkitPro & "\\libctru\\include"

  switch "compileOnly", "on"
  switch "nimcache", "nimcache"
