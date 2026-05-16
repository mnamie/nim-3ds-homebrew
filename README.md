# nim-3ds-homebrew

Nintendo 3DS homebrew written in [Nim](https://nim-lang.org/), cross-compiled to ARM via devkitPro. Includes hand-written FFI bindings for [libctru](https://libctru.devkitpro.org/) and a multi-page interactive demo that exercises the major subsystems.

A write-up of how this works is on my blog: [Writing Nintendo 3DS homebrew in Nim](https://namie.me/posts/nim-3ds-homebrew/)

## Prerequisites

- [devkitPro](https://devkitpro.org/wiki/Getting_Started) with the **3DS development** packages (`3ds-dev` group)
- [Nim](https://nim-lang.org/install.html) 2.x on your `PATH`
- GNU `make` — available in devkitPro's MSYS2 shell, or install separately

## Building

```sh
make
```

This produces `nim-3ds-homebrew.3dsx` in the project root. The build pipeline is:

1. Nim compiles `src/demo.nim` to C (into `nimcache/`) via `--compileOnly`
2. `arm-none-eabi-gcc` compiles and links those C files against libctru
3. `3dsxtool` packages the ELF into a `.3dsx` homebrew file

```sh
make clean   # remove build artifacts
```

## Project structure

```
nim-3ds-homebrew/
├── src/
│   ├── main.nim           # Hello World entry point
│   ├── demo.nim           # Multi-page API demo (what the Makefile builds)
│   ├── panicoverride.nim  # Required for --os:standalone
│   └── ctru/              # libctru FFI bindings
│       ├── types.nim      # u8/u16/u32/u64, Handle, Result
│       ├── result.nim     # Result code helpers and constants
│       ├── gspgpu.nim     # GPU/display service
│       ├── gfx.nim        # Framebuffer management
│       ├── console.nim    # Text console
│       ├── hid.nim        # Input (buttons, touch, circle pad, sensors)
│       ├── apt.nim        # Applet manager
│       ├── os.nim         # OS info, timing, system calls
│       └── env.nim        # Homebrew environment
├── config.nims            # Nim cross-compilation config
├── Makefile
└── nim-3ds-homebrew.nimble
```

## The demo

The demo (`src/demo.nim`) is a four-page interactive program. Cycle pages with **L/R**, exit with **START**.

| Page | What it shows |
|------|---------------|
| System | Kernel/firmware version, New 3DS detection, WiFi strength, 3D slider, heap sizes, APT state |
| Input | All buttons, touch coordinates, circle pad, C-stick (New 3DS), per-frame key bitmasks |
| Sensors | Live accelerometer and gyroscope readings (enabled on first visit) |
| Timing | Per-frame time, estimated FPS, uptime, raw system tick counter |

## Cross-compilation notes

Nim targets `--os:standalone --gc:arc` rather than `--os:linux`. The Linux target pulls in `sys/mman.h` for `mmap`, which newlib doesn't provide. Standalone mode uses Nim's own static heap allocator and works cleanly with devkitARM.

On Windows, Nim's global `nim.cfg` appends `-mno-ms-bitfields` to compiler flags — a MinGW workaround that `arm-none-eabi-gcc` rejects. `config.nims` overrides `gcc.options.always` entirely to strip it out.

## Running

Copy `nim-3ds-homebrew.3dsx` to your 3DS (via the Homebrew Launcher) or open it in an emulator of your choice.
