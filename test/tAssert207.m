MODULE tAssert207;

VAR x: INTEGER;

BEGIN
  x := 3;
  ASSERT(x = 2, 999)
END tAssert207.

(*<<
Runtime error: assertion failed (999) on line 7 in module tAssert207
In procedure tAssert207.%main
   called from MAIN
>>*)

(*[[
!! SYMFILE #tAssert207 STAMP #tAssert207.%main 1
!! END STAMP
!! 
MODULE tAssert207 STAMP 0
ENDHDR

PROC tAssert207.%main 0 2 0
!   x := 3;
CONST 3
STGW tAssert207.x
!   ASSERT(x = 2, 999)
LDGW tAssert207.x
CONST 2
JEQ 2
CONST 999
EASSERT 7
LABEL 2
RETURN
END

! Global variables
GLOVAR tAssert207.x 4

! End of file
]]*)