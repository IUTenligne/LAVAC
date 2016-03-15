dllprog.dll: dllprog.obj dllprog.def
  TLINK dllprog,,,,dllprog
  RC dllprog.dll

dllprog.obj: dllprog.asm
  TASM dllprog
