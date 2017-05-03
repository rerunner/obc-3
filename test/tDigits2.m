MODULE tDigits2;

(*<<
381654729
>>*)

IMPORT Out, GC;

PROCEDURE Search(k, n: INTEGER; s: PROCEDURE (d1: INTEGER): BOOLEAN);
  VAR d, nn: INTEGER;

  PROCEDURE s1(d1: INTEGER): BOOLEAN;
  BEGIN RETURN (d1 # d) & s(d1) END s1;

BEGIN
  IF k = 10 THEN
    GC.Collect;
    Out.Int(n, 0); Out.Ln
  ELSE
    FOR d := 1 TO 9 DO
      nn := 10 * n + d;
      IF (nn MOD k = 0) & s(d) THEN
        Search(k+1, nn, s1)
      END
    END
  END
END Search;

PROCEDURE all(d1: INTEGER): BOOLEAN;
BEGIN
  RETURN TRUE
END all;

BEGIN
  Search(1, 0, all)
END tDigits2.

(*[[
!! (SYMFILE #tDigits2 STAMP #tDigits2.%main 1)
!! (CHKSUM STAMP)
!! 
MODULE tDigits2 STAMP 0
IMPORT Out STAMP
IMPORT GC STAMP
ENDHDR

PROC tDigits2.%1.s1 4 3 0
!   PROCEDURE s1(d1: INTEGER): BOOLEAN;
SAVELINK
!   BEGIN RETURN (d1 # d) & s(d1) END s1;
LDLW 12
LDEW -4
JNE L3
CONST 0
RETURNW
LABEL L3
LDLW 12
LDEW 24
LINK
LDEW 20
NCHECK 13
CALLW 1
RETURNW
END

PROC tDigits2.Search 8 5 0
! PROCEDURE Search(k, n: INTEGER; s: PROCEDURE (d1: INTEGER): BOOLEAN);
!   IF k = 10 THEN
LDLW 12
CONST 10
JNE L13
!     GC.Collect;
GLOBAL GC.Collect
CALL 0
!     Out.Int(n, 0); Out.Ln
CONST 0
LDLW 16
GLOBAL Out.Int
CALL 2
GLOBAL Out.Ln
CALL 0
RETURN
LABEL L13
!     FOR d := 1 TO 9 DO
CONST 1
STLW -4
LABEL L6
LDLW -4
CONST 9
JGT L7
!       nn := 10 * n + d;
LDLW 16
CONST 10
TIMES
LDLW -4
PLUS
STLW -8
!       IF (nn MOD k = 0) & s(d) THEN
LDLW -8
LDLW 12
ZCHECK 22
MOD
JNEZ L10
LDLW -4
LDLW 24
LINK
LDLW 20
NCHECK 22
CALLW 1
JEQZ L10
!         Search(k+1, nn, s1)
LOCAL 0
GLOBAL tDigits2.%1.s1
LDLW -8
LDLW 12
INC
GLOBAL tDigits2.Search
CALL 4
LABEL L10
!     FOR d := 1 TO 9 DO
INCL -4
JUMP L6
LABEL L7
RETURN
END

PROC tDigits2.all 0 5 0
! PROCEDURE all(d1: INTEGER): BOOLEAN;
!   RETURN TRUE
CONST 1
RETURNW
END

PROC tDigits2.%main 0 5 0
!   Search(1, 0, all)
CONST 0
GLOBAL tDigits2.all
CONST 0
CONST 1
GLOBAL tDigits2.Search
CALL 4
RETURN
END

! End of file
]]*)
