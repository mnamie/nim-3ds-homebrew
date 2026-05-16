## Core type aliases matching libctru's types.h

type
  u8* = uint8
  u16* = uint16
  u32* = uint32
  u64* = uint64
  s8* = int8
  s16* = int16
  s32* = int32
  s64* = int64

  Handle* = u32 ## Resource handle
  Result* = s32 ## Function result (negative = failure)

  ThreadFunc* = proc (arg: pointer) {.cdecl.}
  VoidFn* = proc () {.cdecl.}
