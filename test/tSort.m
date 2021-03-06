MODULE tSort;

IMPORT Out;

TYPE List = POINTER TO Cell;
  Cell = RECORD
    ;;;;;;;;;;;;;;;;;;;;;;
    ;; data: INTEGER    ;;
    ;;;;;;;;;;;;;;;;;;;;;;
    ;; prev, next: List ;;
    ;;;;;;;;;;;;;;;;;;;;;;
  END;

PROCEDURE FindMin(xs: List): List;
  VAR p, q: List;
BEGIN
  p := xs.next;
  ASSERT(p # xs);
  q := p.next;
  WHILE q # xs DO
    IF q.data < p.data THEN p := q END;
    q := q.next
  END;
  RETURN p
END FindMin;

PROCEDURE Sort(xs: List; VAR ys: List);
  VAR p: List;
BEGIN
  NEW(ys);
  ys.prev := ys; ys.next := ys;

  WHILE xs.next # xs DO
    p := FindMin(xs);
    p.prev.next := p.next; p.next.prev := p.prev;
    p.prev := ys.prev; p.next := ys;
    ys.prev.next := p; ys.prev := p
  END
END Sort;

PROCEDURE Append(xs: List; d: INTEGER);
  VAR p: List;
BEGIN
  NEW(p); p.data := d;
  p.prev := xs.prev; p.next := xs;
  xs.prev.next := p; xs.prev := p
END Append;

PROCEDURE Test;
  VAR m, k: INTEGER; p, xs, ys: List;
BEGIN
  NEW(xs);
  xs.prev := xs; xs.next := xs;

  (* This is not very random ... *)
  m := 37;
  FOR k := 0 TO 24 DO 
    Out.Int(m, 3);
    Append(xs, m);
    m := (m + 61) MOD 100
  END;
  Out.Ln;

  Sort(xs, ys);

  p := ys.next;
  WHILE p # ys DO
    Out.Int(p.data, 3);
    p := p.next
  END;
  Out.Ln
END Test;

BEGIN 
  Test 
END tSort.

(*<<
 37 98 59 20 81 42  3 64 25 86 47  8 69 30 91 52 13 74 35 96 57 18 79 40  1
  1  3  8 13 18 20 25 30 35 37 40 42 47 52 57 59 64 69 74 79 81 86 91 96 98
>>*)

(*[[
!! (SYMFILE #tSort STAMP #tSort.%main 1)
!! (CHKSUM STAMP)
!! 
MODULE tSort STAMP 0
IMPORT Out STAMP
ENDHDR

PROC tSort.FindMin 8 3 0x00118001
! PROCEDURE FindMin(xs: List): List;
!   p := xs.next;
LDLW 12
NCHECK 17
LDNW 8
STLW -4
!   ASSERT(p # xs);
LDLW -4
LDLW 12
JNEQ L2
CONST 0
CONST 18
GLOBAL EASSERT
CALL 2
LABEL L2
!   q := p.next;
LDLW -4
NCHECK 19
LDNW 8
STLW -8
LABEL L3
!   WHILE q # xs DO
LDLW -8
LDLW 12
JEQ L5
!     IF q.data < p.data THEN p := q END;
LDLW -8
NCHECK 21
LOADW
LDLW -4
NCHECK 21
LOADW
JGEQ L8
LDLW -8
STLW -4
LABEL L8
!     q := q.next
LDLW -8
NCHECK 22
LDNW 8
STLW -8
JUMP L3
LABEL L5
!   RETURN p
LDLW -4
RETURN
END

PROC tSort.Sort 4 3 0x00310001
! PROCEDURE Sort(xs: List; VAR ys: List);
!   NEW(ys);
CONST 12
GLOBAL tSort.Cell
GLOBAL NEW
CALLW 2
LDLW 16
STOREW
!   ys.prev := ys; ys.next := ys;
LDLW 16
LOADW
LDLW 16
LOADW
NCHECK 31
STNW 4
LDLW 16
LOADW
LDLW 16
LOADW
NCHECK 31
STNW 8
LABEL L9
!   WHILE xs.next # xs DO
LDLW 12
NCHECK 33
LDNW 8
LDLW 12
JEQ L11
!     p := FindMin(xs);
LDLW 12
GLOBAL tSort.FindMin
CALLW 1
STLW -4
!     p.prev.next := p.next; p.next.prev := p.prev;
LDLW -4
NCHECK 35
LDNW 8
LDLW -4
NCHECK 35
LDNW 4
NCHECK 35
STNW 8
LDLW -4
NCHECK 35
LDNW 4
LDLW -4
NCHECK 35
LDNW 8
NCHECK 35
STNW 4
!     p.prev := ys.prev; p.next := ys;
LDLW 16
LOADW
NCHECK 36
LDNW 4
LDLW -4
NCHECK 36
STNW 4
LDLW 16
LOADW
LDLW -4
NCHECK 36
STNW 8
!     ys.prev.next := p; ys.prev := p
LDLW -4
LDLW 16
LOADW
NCHECK 37
LDNW 4
NCHECK 37
STNW 8
LDLW -4
LDLW 16
LOADW
NCHECK 37
STNW 4
JUMP L9
LABEL L11
RETURN
END

PROC tSort.Append 4 3 0x00110001
! PROCEDURE Append(xs: List; d: INTEGER);
!   NEW(p); p.data := d;
CONST 12
GLOBAL tSort.Cell
GLOBAL NEW
CALLW 2
STLW -4
LDLW 16
LDLW -4
NCHECK 44
STOREW
!   p.prev := xs.prev; p.next := xs;
LDLW 12
NCHECK 45
LDNW 4
LDLW -4
NCHECK 45
STNW 4
LDLW 12
LDLW -4
NCHECK 45
STNW 8
!   xs.prev.next := p; xs.prev := p
LDLW -4
LDLW 12
NCHECK 46
LDNW 4
NCHECK 46
STNW 8
LDLW -4
LDLW 12
NCHECK 46
STNW 4
RETURN
END

PROC tSort.Test 20 3 0x00007001
! PROCEDURE Test;
!   NEW(xs);
CONST 12
GLOBAL tSort.Cell
GLOBAL NEW
CALLW 2
STLW -16
!   xs.prev := xs; xs.next := xs;
LDLW -16
LDLW -16
NCHECK 53
STNW 4
LDLW -16
LDLW -16
NCHECK 53
STNW 8
!   m := 37;
CONST 37
STLW -4
!   FOR k := 0 TO 24 DO 
CONST 0
STLW -8
LABEL L12
LDLW -8
CONST 24
JGT L13
!     Out.Int(m, 3);
CONST 3
LDLW -4
GLOBAL Out.Int
CALL 2
!     Append(xs, m);
LDLW -4
LDLW -16
GLOBAL tSort.Append
CALL 2
!     m := (m + 61) MOD 100
LDLW -4
CONST 61
PLUS
CONST 100
MOD
STLW -4
!   FOR k := 0 TO 24 DO 
INCL -8
JUMP L12
LABEL L13
!   Out.Ln;
GLOBAL Out.Ln
CALL 0
!   Sort(xs, ys);
LOCAL -20
LDLW -16
GLOBAL tSort.Sort
CALL 2
!   p := ys.next;
LDLW -20
NCHECK 66
LDNW 8
STLW -12
LABEL L14
!   WHILE p # ys DO
LDLW -12
LDLW -20
JEQ L16
!     Out.Int(p.data, 3);
CONST 3
LDLW -12
NCHECK 68
LOADW
GLOBAL Out.Int
CALL 2
!     p := p.next
LDLW -12
NCHECK 69
LDNW 8
STLW -12
JUMP L14
LABEL L16
!   Out.Ln
GLOBAL Out.Ln
CALL 0
RETURN
END

PROC tSort.%main 0 1 0
!   Test 
GLOBAL tSort.Test
CALL 0
RETURN
END

! Descriptor for Cell
DEFINE tSort.Cell
WORD 0x0000000d
WORD 0
WORD tSort.Cell.%anc

DEFINE tSort.Cell.%anc
WORD tSort.Cell

! End of file
]]*)
