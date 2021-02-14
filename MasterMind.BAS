#DEFINE "DBG ", "'"
'#DEFINE "DBG ", ""
'#MMDEBUG ON

OPTION BREAK 0
DBG OPTION BREAK 3

OPTION EXPLICIT
OPTION DEFAULT NONE
OPTION BASE 0
OPTION CRLF CR

'MasterMind
CONST VERSION.MM = "0.01"

CONST MIN_FW.MM = 5.06
CONST MAX_COLS.MM = 9, MAX_ROWS.MM = 20
CONST R.MM = 10 'position diameter
CONST LEFT.MM = CHR$(130), RIGHT.MM = CHR$(131), ENTER.MM = CHR$(13)
CONST HELP.MM = 350
CONST XX.MM = 3*8 'positon of first color (after row #)

DIM INTEGER COLS.MM     'max columns in row
DIM INTEGER ROWS.MM     'max rows to play
DIM INTEGER COLORS.MM   'max used colors in row
DIM INTEGER EMPTY.MM    'can be position also empty?
DIM INTEGER REPEAT.MM   'can be some color used more than once?
DIM INTEGER PAL.MM(19)  'palette for cursor
DIM INTEGER CRSR.MM = 1 'CURSOR column position
DIM INTEGER CUR_X.MM, CUR_Y.MM 'absolute CURSOR position
DIM INTEGER TIME.MM
DIM INTEGER ROW.MM = 1, OK.MM = -1, NOK.MM = -1

DIM STRING MM(MAX_ROWS.MM) LENGTH MAX_COLS.MM
DIM STRING ENABLED.MM = "0123456789", CURRENT.MM = "", SECRET.MM = ""
DIM INTEGER COLOR.MM(MAX_COLS.MM)

ON KEY 157, MM.printScreen
MM.init
MM.set(4, 12, 4, 0, 0) 'set game field to COLUMNS, ROWS, COLORS, EMPTY, REPEAT
MM.game
END

SUB MM.printScreen
  SAVE IMAGE "ScreenShot.BMP"
END SUB

SUB MM.game
  'main game
  
  FONT 1
  DIM INTEGER qq, ok, nok, w = 3*MM.INFO(FONTWIDTH)

  MM.newGame
  DO 
    MM.key
  LOOP
END SUB

SUB MM.key
  LOCAL STRING k = INKEY$
  LOCAL INTEGER hlp

  DO WHILE k = ""
    k = INKEY$
    IF (TIMER\1000) <> TIME.MM THEN
      MM.time
    ENDIF
  LOOP
  SELECT CASE LCASE$(k)
    CASE LEFT.MM
      IF CRSR.MM > 1 THEN
        MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 0)
        INC CRSR.MM, -1
        INC CUR_X.MM, -2.5*R.MM
        MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 1)
      ENDIF

    CASE RIGHT.MM
      IF CRSR.MM < COLS.MM THEN
        MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 0)
        INC CRSR.MM, 1
        INC CUR_X.MM, 2.5*R.MM
        MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 1)
      ENDIF

    CASE ENTER.MM
      'next round
      MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 0)
      MM.eval
      MM.drawEval(XX.MM + 10 + COLS.MM*2.5*R.MM, 1.25*R.MM + 2.5*R.MM*ROW.MM, OK.MM, NOK.MM)
      IF OK.MM = COLS.MM THEN 
        MM.endGame(" YOU HAVE WON! ")
      ELSE
        IF ROW.MM < ROWS.MM THEN
          INC ROW.MM        
          INC CUR_Y.MM, 2.5*R.MM
          TEXT 0, 1.25*R.MM+2.5*R.MM*ROW.MM, STR$(ROW.MM, 2) + ".", "LM", 1,,RGB(WHITE), RGB(NOTBLACK)
          CRSR.MM = 1
          CUR_X.MM = XX.MM + (CRSR.MM-1)*2.5*R.MM
          MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 1)
        ELSE
          MM.endGame(" YOU HAVE LOST! ")
        ENDIF
      ENDIF

    CASE "c"
      IF COLS.MM < MAX_COLS.MM THEN
        INC COLS.MM
        COLORS.MM = MAX(COLS.MM, COLORS.MM)
      ELSE
        COLS.MM = 1
      ENDIF
      IF CRSR.MM > COLS.MM THEN
        MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 0)
        CRSR.MM = COLS.MM
        CUR_X.MM = XX.MM + (CRSR.MM-1)*2.5*R.MM
        MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 1)
      ENDIF
      MM.newGame
      
    CASE "b"
      IF COLORS.MM < 9 THEN
        INC COLORS.MM
      ELSE
        COLORS.MM = COLS.MM
      ENDIF
      MM.newGame

    CASE "r"
      IF ROWS.MM < MAX_ROWS.MM THEN
        INC ROWS.MM
      ELSE
        ROWS.MM = 1
      ENDIF
      MM.newGame

    CASE "n"
      MM.newGame

    CASE "q"
      OPTION BREAK 3
      CLS
      END

    CASE "m"
      REPEAT.MM = 1 - REPEAT.MM
      MM.newGame

    CASE "e"
      EMPTY.MM = 1 - EMPTY.MM
      MM.newGame

    CASE ELSE
      hlp = INSTR(ENABLED.MM, k)
      IF hlp > 0 THEN
        MM.drawRow(CUR_X.MM, CUR_Y.MM + 1.25*R.MM, k, 0)
        MID$(CURRENT.MM, CRSR.MM, 1) = k
        IF CRSR.MM < COLS.MM THEN
          MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 0)
          INC CRSR.MM, 1
          INC CUR_X.MM, 2.5*R.MM
          MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 1)
        ENDIF
      ENDIF

  END SELECT
END SUB

SUB MM.newGame
  LOCAL INTEGER i

  CRSR.MM = 1
  CUR_X.MM = XX.MM + (CRSR.MM-1)*2.5*R.MM
  CUR_Y.MM = 2.5*R.MM
  SECRET.MM = MM.randomRow()
  BOX 0, 0, HELP.MM, MM.VRES, 0,, RGB(NOTBLACK)
  ROW.MM = 1
  TEXT 0, 1.25*R.MM+2.5*R.MM, STR$(ROW.MM, 2) + ".", "LM", 1,,RGB(WHITE), RGB(NOTBLACK)
  MM.drawRow(XX.MM, 1.25*R.MM, MM.emptyRow(), 1)
  TIMER = 0
  CURRENT.MM = SPACE$(COLS.MM)
  ENABLED.MM = ""
  IF EMPTY.MM THEN ENABLED.MM = CHR$(48)
  FOR i = 1 TO COLORS.MM
    CAT ENABLED.MM, CHR$(48 + i)
  NEXT i
  MM.drawHelp
  MM.cursor(CUR_X.MM, CUR_Y.MM, 1+2.5*R.MM, 1+2.5*R.MM, 1)
END SUB

SUB MM.eval
  LOCAL INTEGER i, j

  OK.MM = 0
  NOK.MM = 0
  FOR i = 1 TO COLS.MM
    IF MID$(CURRENT.MM, i, 1) = MID$(SECRET.MM, i, 1) THEN
      INC OK.MM
    ELSE
      FOR j = 1 TO COLS.MM
        IF i <> j THEN
          IF MID$(CURRENT.MM, i, 1) = MID$(SECRET.MM, j, 1) THEN
            INC NOK.MM
            EXIT FOR
          ENDIF 
        ENDIF
      NEXT j
    ENDIF
  NEXT i
END SUB

SUB MM.drawOutlineText(x AS INTEGER, y AS INTEGER, txt AS STRING, c1 AS INTEGER, c2 AS INTEGER, pg AS INTEGER)
  LOCAL INTEGER h = MM.INFO(FONTHEIGHT), w = LEN(txt) * MM.INFO(FONTWIDTH)

  PAGE WRITE 1
  CLS RGB(BLACK)
  TEXT 0, 0, txt, "LT",,,c1
  PAGE WRITE pg
  BLIT 0, 0, x-1, y - 1, w, h, 1, 4  
  BLIT 0, 0, x-1, y + 1, w, h, 1, 4  
  BLIT 0, 0, x+1, y - 1, w, h, 1, 4  
  BLIT 0, 0, x+1, y + 1, w, h, 1, 4  
  PAGE WRITE 1
  CLS RGB(BLACK)
  TEXT 0, 0, txt, "LT",,,c2
  PAGE WRITE pg
  BLIT 0, 0, x, y, w, h, 1, 4  
END SUB

SUB MM.cursor(x AS INTEGER, y AS INTEGER, w AS INTEGER, h AS INTEGER, onOff AS INTEGER)
  IF onOff THEN
    LOCAL INTEGER i, c = 0
    FOR i = x TO x + w - 1
      PIXEL i, y, MAP(100 + c)
      PIXEL i, y+1, MAP(100 + c)
      c = (c + 1) MOD 20
    NEXT i
    FOR i = y TO y + h - 1
      PIXEL x + w - 1, i, MAP(100 + c)
      PIXEL x + w, i, MAP(100 + c)
      c = (c + 1) MOD 20
    NEXT i
    FOR i = x + w - 1 TO x STEP -1
      PIXEL i, y + h - 1, MAP(100 + c)
      PIXEL i, y + h, MAP(100 + c)
      c = (c + 1) MOD 20
    NEXT i
    FOR i = y + h - 1 TO y STEP - 1
      PIXEL x, i, MAP(100 + c)
      PIXEL x+1, i, MAP(100 + c)
      c = (c + 1) MOD 20
    NEXT i
    SETTICK 100, cursorChange, 1
  ELSE
    BOX x, y, w+1, h+1, 2, RGB(NOTBLACK)
    SETTICK 0, 0, 1
  ENDIF
END SUB

SUB cursorChange
  LOCAL INTEGER i, store = PAL.MM(0)

  FOR i = 1 TO 19
    PAL.MM(i - 1) = PAL.MM(i)
    MAP(100+i) = PAL.MM(i) 
  NEXT i
  PAL.MM(19) = store
  MAP(100) = store
  MAP SET
END SUB

SUB MM.time
  FONT 5
  PAGE WRITE 2
  LOCAL INTEGER w = 5*MM.INFO(FONTWIDTH), h = MM.INFO(FONTHEIGHT)
  TIME.MM = TIMER / 1000
  LOCAL STRING tm = STR$(TIME.MM\60, 2, 0, "0") + ":" + STR$(TIME.MM MOD 60, 2, 0, "0")
  CLS RGB(NOTBLACK)
  MM.drawOutlineText(MM.HRES - w - 1, 1, tm, RGB(GREEN), COLOR.MM(8), 2)
  PAGE WRITE 0
  BLIT MM.HRES - w - 1, 0, MM.HRES - w - 1, 0, w + 2, h + 2, 2
  FONT 1
END SUB

SUB MM.drawHelp
  'draw help texts
  
  PAGE WRITE 2
  CLS RGB(NOTBLACK)
  FONT 5
  MM.drawOutlineText(HELP.MM + 1, 1, "MASTERMIND", RGB(CYAN), RGB(BLUE), 2)
  TEXT HELP.MM + 240, 4, "v" + VERSION.MM, "LT", 1,,RGB(CYAN)
  TEXT HELP.MM + 240, 17, "by JirSoft", "LT", 1,,RGB(CYAN)
  FONT 3
  LOCAL INTEGER y = 40, yy = y, h = MM.INFO(FONTHEIGHT), store, x = HELP.MM
  LOCAL STRING hlp

  MM.drawOutlineText(x, yy, "LEFT/RIGHT MOVES CURSOR", RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,h
  MM.drawOutlineText(x, yy, "KEY 0-9 SELECTS COLOR", RGB(YELLOW), RGB(NOTBLACK), 2)
  FONT 1
  store = COLS.MM
  COLS.MM = 10  
  MM.drawRow(x, yy+36, ENABLED.MM, 1)
  COLS.MM = store
  FONT 3
  INC yy,2*h
  MM.drawOutlineText(x, yy, "ENTER FINISHES ROUND", RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,1.5*h
  TEXT HELP.MM + 50, yy, "4 PERFECTLY RIGHT,", "LT",,,RGB(YELLOW), RGB(NOTBLACK)
  INC yy,h
  MM.drawEval(HELP.MM, yy, 4, 2)
  TEXT HELP.MM + 50, yy, "and 2 in WRONG pos", "LT",,,RGB(YELLOW), RGB(NOTBLACK)
  INC yy,2*h

  MM.drawOutlineText(x, yy, "NEW GAME WITH 'N'", RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,1.5*h

  MM.drawOutlineText(x, yy, "NUMBER OF COLUMNS: " + STR$(COLS.MM), RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,h
  TEXT x, yy, "change with 'C'  ", "LT",,,RGB(YELLOW), RGB(NOTBLACK)
  INC yy, 1.5*h

  MM.drawOutlineText(x, yy, "NUMBER OF COLOURS: " + STR$(COLORS.MM), RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,h
  TEXT x, yy, "change with 'B'  ", "LT",,,RGB(YELLOW), RGB(NOTBLACK)
  INC yy, 1.5*h

  MM.drawOutlineText(x, yy, "MAX NUMBER OF ROUNDS: " + STR$(ROWS.MM), RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,h
  TEXT x, yy, "change with 'R'  ", "LT",,,RGB(YELLOW), RGB(NOTBLACK)
  INC yy, 1.5*h

  IF EMPTY.MM THEN hlp = "YES" ELSE hlp = "NO"
  MM.drawOutlineText(x, yy, "EMPTY SPACES: " + hlp, RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,h
  TEXT x, yy, "change with 'E'  ", "LT",,,RGB(YELLOW), RGB(NOTBLACK)
  INC yy, 1.5*h

  IF REPEAT.MM THEN hlp = "YES" ELSE hlp = "NO"
  MM.drawOutlineText(x, yy, "SOME COLOR MORE TIMES: " + hlp, RGB(YELLOW), RGB(NOTBLACK), 2)
  INC yy,h
  TEXT x, yy, "change with 'M'  ", "LT",,,RGB(YELLOW), RGB(NOTBLACK)

  INC yy, 1.5*h
  MM.drawOutlineText(x, yy, "QUIT GAME WITH 'Q'", RGB(YELLOW), RGB(NOTBLACK), 2)

  FONT 1
  PAGE WRITE 0
  BLIT x, 0, x, 0, MM.HRES - HELP.MM, MM.VRES, 2
END SUB

FUNCTION MM.randomColor() AS INTEGER
  IF EMPTY.MM THEN
    MM.randomColor = CINT(RND * COLORS.MM)
  ELSE
    MM.randomColor = 1 + FIX(RND * COLORS.MM)
  ENDIF
END FUNCTION

FUNCTION MM.emptyRow() AS STRING
  MM.emptyRow = SPACE$(COLS.MM)
END FUNCTION

FUNCTION MM.randomRow() AS STRING
  LOCAL INTEGER i, j, c, ok
  
  MM.randomRow = CHR$(48 + MM.randomColor())
  FOR i = 2 TO COLS.MM
    ok = 0
    DO WHILE NOT ok
      c = 48 + MM.randomColor()
      ok = 1
      FOR j = 1 TO i-1
        IF ASC(MID$(MM.randomRow, j, 1)) = c AND NOT REPEAT.MM THEN
          ok = 0
          EXIT FOR
        ENDIF
      NEXT j
    LOOP
    CAT MM.randomRow, CHR$(c)
  NEXT i
END FUNCTION

SUB MM.set(c AS INTEGER, r AS INTEGER, cols AS INTEGER, empty AS INTEGER, rep AS INTEGER)
  COLS.MM = MIN(c, MAX_COLS.MM)
  COLORS.MM = COLS.MM
  ROWS.MM = MIN(r, MAX_ROWS.MM)
  COLORS.MM = MAX(MIN(cols, 9), COLS.MM)
  EMPTY.MM = (empty <> 0)
  REPEAT.MM = (rep <> 0)
END SUB

SUB MM.init
  LOCAL INTEGER i

  MODE 1, 8
  COLOR.MM(0) = RGB(NOTBLACK)
  COLOR.MM(1) = RGB(WHITE)
  COLOR.MM(2) = RGB(RED)
  COLOR.MM(3) = RGB(GREEN)
  COLOR.MM(4) = RGB(BLUE)
  COLOR.MM(5) = RGB(YELLOW)
  COLOR.MM(6) = RGB(CYAN)
  COLOR.MM(7) = RGB(MAGENTA)
  COLOR.MM(8) = &h006400 'dark green
  COLOR.MM(9) = &hC19A6B 'desert

  FOR i = 0 TO 19
    PAL.MM(i) = RGB(FIX(RND*256), FIX(RND*256), FIX(RND*256))
  NEXT i
  CLS COLOR.MM(0)
  TIMER = 0
END SUB

SUB MM.drawEval(x AS INTEGER, y AS INTEGER, ok AS INTEGER, nok AS INTEGER)
  LOCAL INTEGER i
  FOR i = 1 TO ok
    CIRCLE x + 1.25*R.MM/3 + (i-1)*2.5*R.MM/3, y-R.MM/2, R.MM/3, 0, 1, RGB(GREEN), RGB(GREEN)    
  NEXT i
  FOR i = 1 TO nok
    CIRCLE x + 1.25*R.MM/3 + (i-1)*2.5*R.MM/3, y+R.MM/2, R.MM/3, 0, 1, RGB(RED), RGB(RED) 
  NEXT i
END SUB

SUB MM.drawRow(x AS INTEGER, y AS INTEGER, row AS STRING, numbers AS INTEGER)
  LOCAL INTEGER i, c

  FOR i = 1 TO LEN(row)
    c = ASC(MID$(row, i, 1)) - 48
    IF c < 0 THEN
      CIRCLE x + 1.25*R.MM + (i-1)*2.5*R.MM, y, R.MM, 1, 1, COLOR.MM(1), COLOR.MM(0)
      TEXT x + 1.25*R.MM + (i-1)*2.5*R.MM, y, "?", "CM",,,COLOR.MM(1), COLOR.MM(0)
    ELSE
      IF c = 0 THEN
        CIRCLE x + 1.25*R.MM + (i-1)*2.5*R.MM, y, R.MM, 1, 1, COLOR.MM(1), COLOR.MM(c)
      ELSE
        CIRCLE x + 1.25*R.MM + (i-1)*2.5*R.MM, y, R.MM, 0, 1,, COLOR.MM(c)
      ENDIF
      IF numbers THEN
        IF c = 0 THEN
          TEXT x + 1.25*R.MM + (i-1)*2.5*R.MM, y, CHR$(c + 48), "CM",,,COLOR.MM(1), COLOR.MM(c)
        ELSE
          TEXT x + 1.25*R.MM + (i-1)*2.5*R.MM, y, CHR$(c + 48), "CM",,,COLOR.MM(0), COLOR.MM(c)
        ENDIF
      ENDIF
    ENDIF
  NEXT i
END SUB

SUB MM.endGame(txt AS STRING)
  FONT 5
  LOCAL INTEGER i, h = MM.INFO(FONTHEIGHT), w = MM.INFO(FONTWIDTH), c = 0, ww = w*LEN(txt)
  LOCAL INTEGER x = (MM.HRES - ww)\ 2, y = MM.VRES \ 2
  PAGE WRITE 2
  CLS RGB(NOTBLACK)
  FOR i = x TO x + ww - 1 + 3 * h
    LINE i - 3*h, y, i, y + 3*h, 1, MAP(100 + c)
    c = (c + 1) MOD 20
  NEXT i
  BOX x, y, ww, 3*h, 1, RGB(RED)
  MM.drawOutlineText(x, y + h, txt, RGB(NOTBLACK), RGB(NOTBLACK), 2)
  PAGE WRITE 0
  BLIT x, y, x, y, ww, 3*h, 2
  SETTICK 100, cursorChange, 1
  MM.drawRow(XX.MM, 1.25*R.MM, SECRET.MM)
  DO WHILE INKEY$<>"": LOOP
  DO WHILE INKEY$="": LOOP
  FONT 1
  SETTICK 0, 0, 1
  MM.newGame
END SUB

