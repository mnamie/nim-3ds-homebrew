{.used.}

proc rawoutput(s: string) =
  discard

proc panic(s: string) {.noreturn.} =
  while true: discard
