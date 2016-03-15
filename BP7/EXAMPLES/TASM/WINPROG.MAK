winprog.exe: winprog.obj winprog.res
  TLINK winprog,,,,winprog
  RC winprog.res

winprog.res: winprog.rc
  RC -r winprog.rc

winprog.obj: winprog.asm winprog.inc winprog.ash
  TASM winprog
