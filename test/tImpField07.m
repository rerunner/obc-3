MODULE tImpField07;
IMPORT t := xTypes07, Out;
VAR s: t.rec;
BEGIN
  s.x := 3;
  Out.Int(s.x, 0)
END tImpField07.

(*<<
>>*)

(*[[
!! SYMFILE #tImpField07 STAMP #tImpField07.%main 1
!! END STAMP
!! 
MODULE tImpField07 STAMP 0
IMPORT xTypes07 STAMP
IMPORT Out STAMP
ENDHDR

PROC tImpField07.%main 0 3 0
!   s.x := 3;
CONST 3
GLOBAL tImpField07.s
STNW 4
!   Out.Int(s.x, 0)
CONST 0
GLOBAL tImpField07.s
LDNW 4
GLOBAL Out.Int
CALL 2
RETURN
END

! Global variables
GLOVAR tImpField07.s 8

! End of file
]]*)
