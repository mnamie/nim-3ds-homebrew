## Result code helpers matching libctru's result.h

import types

template rSucceeded*(res: Result): bool = res >= 0
template rFailed*(res: Result): bool = res < 0

func rLevel*(res: Result): int = (res.int shr 27) and 0x1F
func rSummary*(res: Result): int = (res.int shr 21) and 0x3F
func rModule*(res: Result): int = (res.int shr 10) and 0xFF
func rDescription*(res: Result): int = res.int and 0x3FF

func makeResult*(level, summary, module, description: int): Result =
  Result(((level and 0x1F) shl 27) or ((summary and 0x3F) shl 21) or
         ((module and 0xFF) shl 10) or (description and 0x3FF))

# Level values
const
  RL_SUCCESS* = 0
  RL_INFO* = 1
  RL_STATUS* = 25
  RL_TEMPORARY* = 26
  RL_PERMANENT* = 27
  RL_USAGE* = 28
  RL_REINITIALIZE* = 29
  RL_RESET* = 30
  RL_FATAL* = 31

# Summary values
const
  RS_SUCCESS* = 0
  RS_NOP* = 1
  RS_WOULDBLOCK* = 2
  RS_OUTOFRESOURCE* = 3
  RS_NOTFOUND* = 4
  RS_INVALIDSTATE* = 5
  RS_NOTSUPPORTED* = 6
  RS_INVALIDARG* = 7
  RS_WRONGARG* = 8
  RS_CANCELED* = 9
  RS_STATUSCHANGED* = 10
  RS_INTERNAL* = 11

# Module values (most common)
const
  RM_COMMON* = 0
  RM_KERNEL* = 1
  RM_FS* = 17
  RM_HID* = 19
  RM_CAM* = 20
  RM_GSP* = 10
  RM_SOC* = 28
  RM_AM* = 32
  RM_MIC* = 35
  RM_HTTP* = 40
  RM_DSP* = 41
  RM_SSL* = 46
  RM_FRIENDS* = 49
  RM_APPLET* = 51
  RM_NIM* = 52
  RM_PTM* = 53
  RM_AC* = 39
  RM_SDMC* = 61
  RM_BOSS* = 62
  RM_NFC* = 93
  RM_APPLICATION* = 254

# Common descriptions
const
  RD_SUCCESS* = 0
  RD_INVALID_RESULT_VALUE* = 0x3FF
  RD_TIMEOUT* = RD_INVALID_RESULT_VALUE - 1
  RD_OUT_OF_RANGE* = RD_INVALID_RESULT_VALUE - 2
  RD_ALREADY_EXISTS* = RD_INVALID_RESULT_VALUE - 3
  RD_NOT_FOUND* = RD_INVALID_RESULT_VALUE - 5
  RD_ALREADY_INITIALIZED* = RD_INVALID_RESULT_VALUE - 6
  RD_NOT_INITIALIZED* = RD_INVALID_RESULT_VALUE - 7
  RD_INVALID_HANDLE* = RD_INVALID_RESULT_VALUE - 8
  RD_INVALID_POINTER* = RD_INVALID_RESULT_VALUE - 9
  RD_NOT_IMPLEMENTED* = RD_INVALID_RESULT_VALUE - 11
  RD_OUT_OF_MEMORY* = RD_INVALID_RESULT_VALUE - 12
  RD_BUSY* = RD_INVALID_RESULT_VALUE - 15
  RD_NO_DATA* = RD_INVALID_RESULT_VALUE - 16
