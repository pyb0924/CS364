.486
SET_DISP_MODE MACRO MODE
    MOV AX,0
    MOV AL,MODE
    INT 10H
ENDM
MOVE_CURSOR MACRO
    MOV AH,02H
    MOV BH,00H
    MOV DH,CURSOR_ROW
    MOV DL,CURSOR_COLUMN
    INT 10H    
ENDM
SCRN_CLR MACRO CLR
    MOV AH,06H
    MOV AL,0
    MOV BH,CLR
    MOV CX,0
    MOV DX,184FH
    INT 10H
ENDM
SCREEN_ROLLUP MACRO
    MOV AH,07H
    MOV AL,0
    MOV BH,00H
    MOV CX,0
    MOV DX,184FH
    INT 10H
ENDM
CHAR_OUT MACRO CHAR,N,COLOR
	MOV AL,CHAR
    MOV BH,00H
    MOV BL,COLOR
    MOV CX,N
	MOV AH, 09H
	INT 10H
ENDM
INFO_OUT MACRO INFO
	LEA DX,INFO
	MOV AX, 0900H
	INT 21H
ENDM
STRING_INPUT MACRO BUF1
		LEA DX,BUF1
	    MOV AH,0AH
        INT 21H
ENDM
ENDL MACRO 
    MOV DL,0AH
    MOV AH,02H
	INT 21H 
ENDM
PAUSE MACRO 
    MOV AH,86H
    MOV CX,0
    MOV DX,60000
    INT 15H
ENDM
INC_CURSOR MACRO 
    LOCAL RENEW_COLUMN2
    MOV AL,CURSOR_COLUMN
    INC AL
    CMP AL,BOARD_RIGHT
    JNA RENEW_COLUMN2
    SUB AL,BOARD_LEN
    CMP FLAG,0
    JNZ RENEW_COLUMN2
    PUSH AX
    MOV AL,COUNT
    DEC AL
    MOV COUNT,AL
    POP AX
RENEW_COLUMN2:
    MOV CURSOR_COLUMN,AL
    MOVE_CURSOR
ENDM
DATA_CHECK MACRO
    LOCAL DATA_CHECK_END
    LEA BX,DATABUF
    MOV FLAG,0
    INPUT_EMPTY
    CMP FLAG,1
    JZ DATA_CHECK_END
    CHAR_CHECK
    DATA_CHECK_END:
    NOP
ENDM
;check wrong characters
CHAR_CHECK MACRO
    LOCAL CHAR_CHECK_LOOP
    LOCAL CHAR_WRONG
    LOCAL CHAR_CHECK_END
    MOVZX CX,[BX+1]
    CHAR_CHECK_LOOP:
    MOV AL,[BX+2]
    CMP AL,30H
    JB CHAR_WRONG
    CMP AL,39H
    JA CHAR_WRONG
    INC BX
    LOOP CHAR_CHECK_LOOP
    JMP CHAR_CHECK_END
    CHAR_WRONG:
    MOV FLAG,1
    INFO_OUT INPUT_WRONG_INFO
    CHAR_CHECK_END:
    NOP
ENDM
INPUT_EMPTY MACRO
    LOCAL EMPTY_END
    MOV AL,[BX+1]
    CMP AL,0
    JNZ EMPTY_END
	ENDL
	INFO_OUT INPUT_EMPTY_INFO
	MOV FLAG,1
    EMPTY_END:
    NOP
ENDM
;transfer string to num
DATA_INPUT MACRO
    LOCAL STR_TO_NUM_PUSH
    LOCAL STR_TO_NUM_POP
    LEA BX,DATABUF
    MOVZX CX,[BX+1]
    MOV AX,0
    STR_TO_NUM_PUSH:
    MOV AL,[BX+2]
    SUB AL,30H
    INC BX
    PUSH AX
    LOOP STR_TO_NUM_PUSH

    LEA BX,DATABUF
    MOV DX,0
    MOV DI,1 ;base
    MOVZX CX,[BX+1]
    MOV BX,0
    STR_TO_NUM_POP:
    POP AX
    MUL DI
    ADD BX,AX
    MOV AX,DI
    SAL AX,3
    SAL DI,1
    ADD DI,AX
    LOOP STR_TO_NUM_POP
    MOV DS:[BP],BX
ENDM
OF_CHECK MACRO DATA,MAX,REINPUT
    LOCAL OF_CHECK_END
    MOV AX,DATA
    MOV DX,MAX
    CMP AX,DX
    JB OF_CHECK_END

    INFO_OUT INPUT_OF_INFO
    JMP REINPUT
    OF_CHECK_END:
    NOP
ENDM
INPUT MACRO INFO,REINPUT,POS
    INFO_OUT INFO
    STRING_INPUT DATABUF
    DATA_CHECK
    CMP FLAG,1
    JZ REINPUT
    LEA BP,POS
    DATA_INPUT
    ENDL
ENDM
SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS
DSEG SEGMENT USE16
    BUF DB 12
        DB ?
	    DB 12 DUP(?)
    DATABUF DB 4
            DB ?
            DB 4 DUP(?)
    CENTER_X DW ?             
    CENTER_Y DW ?            
    RADIUS   DW 50
    R_MAX    DW 100
    LABEL_X  DW ?              
    LABEL_Y  DW ?               
    X_OFFSET DW ?
    DISTANCE DW ?
    RECT_SIZE DW ?
    FLAG DB ?                   ;check disp to end
    CURSOR_ROW DB 12
    CURSOR_COLUMN DB 10
    BOARD_RIGHT DB 69
    BOARD_LEN DB 60
    COUNT DB 5

    STRING_INPUT_INFO DB "Please input string to display: ",'$'
    X_INPUT_INFO DB "Please input X-axis of center(0~319): ",'$'
    Y_INPUT_INFO DB "Please input Y-axis of center(0~199): ",'$'
    R_INPUT_INFO DB "Please input radius(1~100): ",'$'
    INPUT_EMPTY_INFO DB "INPUTERROR:Your input is empty! Please input again! ",'$'
	INPUT_WRONG_INFO DB "INPUTERROR:You have input wrong characters! Please input again! ",'$'
    INPUT_OF_INFO DB "INPUTERROR:Your input overflowed! Please input again! ",'$'

DSEG   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DSEG,SS:SSEG
DRAW_BY_COLUMN PROC
      MOV CX , CENTER_X      
      SUB CX , RADIUS         ;left
      COLUMN_DRAW:
      CMP CX , LABEL_X       ; draw to the last column
      JNA COLUMN_NEXT
      JMP DRAW2

      COLUMN_NEXT:
      MOV AX , CX      ;row num
      SUB AX , CENTER_X
      IMUL AX         ; delta x^2

      MOV SI,DISTANCE
      SUB SI, AX
      CALL SQRT

      MOV X_OFFSET,SI
      MOV DX, CENTER_Y
      ADD DX,X_OFFSET

      MOV AL , 02              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H
      SUB DX,X_OFFSET
      SUB DX,X_OFFSET
      MOV AL , 03              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      INC CX
      JMP COLUMN_DRAW
DRAW_BY_COLUMN ENDP
DRAW_BY_ROW PROC
      MOV DX,CENTER_Y
      SUB DX,RADIUS
      ROW_DRAW:
      CMP DX , LABEL_Y       ; draw to the last row
      JNA ROW_NEXT
      JMP DRAW3

      ROW_NEXT:
      MOV AX , DX      ;col num
      SUB AX , CENTER_Y
      PUSH DX
      IMUL AX         ; delta x^2
      POP DX

      MOV SI,DISTANCE
      SUB SI, AX
      CALL SQRT

      MOV X_OFFSET,SI
      MOV CX, CENTER_X
      ADD CX,X_OFFSET

      MOV AL , 02              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      SUB CX,X_OFFSET
      SUB CX,X_OFFSET
      MOV AL , 03              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      INC DX
      JMP ROW_DRAW
DRAW_BY_ROW ENDP
DRAW_RECT PROC
      MOV AX,RADIUS
      MUL AX
      SHR AX,1
      MOV SI,AX
      CALL SQRT
      
      MOV CX,CENTER_X
      MOV DX,CENTER_Y
      SUB DX,SI
      MOV DI,CENTER_Y
      ADD DI,SI

      DRAW_VERT:
      SUB CX,SI               ;draw left
      MOV AL , 05             ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      ADD CX,SI              ;draw right
      ADD CX,SI
      INT 10H
      SUB CX,SI
      
      INC DX
      CMP DX,DI
      JNA DRAW_VERT

      MOV CX,CENTER_X
      MOV DX,CENTER_Y
      SUB CX,SI
      MOV DI,CENTER_X
      ADD DI,SI
      DRAW_HORI:

      SUB DX,SI               ;draw up
      MOV AL , 05             ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      ADD DX,SI              ;draw down
      ADD DX,SI
      INT 10H
      SUB DX,SI
      
      INC CX
      CMP CX,DI
      JNA DRAW_HORI

      RET
DRAW_RECT ENDP
SQRT PROC ; sqrt(SI)
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
      MOV CX,0
      SQRT_LOOP:
      MOV BX,CX
      ADD BX,BX
      INC BX      ;BX=2*CX+1
      SUB SI,BX
      JC SQRT_END
      INC CX
      JMP SQRT_LOOP
      SQRT_END:
      MOV SI,CX
      POP DX
      POP CX
      POP BX
      POP AX
      RET
SQRT ENDP
DRAW_PROC PROC
      SET_DISP_MODE 04H
      SCRN_CLR 00H

      MOV AX , CENTER_X           ; set down right axis
      ADD AX , RADIUS
      MOV LABEL_X , AX            
      MOV AX , CENTER_Y
      ADD AX , RADIUS
      MOV LABEL_Y , AX                             

      MOV AX , RADIUS
      MUL AX
      MOV DISTANCE , AX         ;r^2

    DRAW1:     
      CALL DRAW_BY_COLUMN
    DRAW2:
      CALL DRAW_BY_ROW
    DRAW3:
      CALL DRAW_RECT
      
      RET
DRAW_PROC ENDP
STRING_OUT PROC
       LEA BX,BUF
       MOV CX,0
       MOV CL,BYTE PTR[BX+1]
       MOV DX,1 ;COLOR
       STRING_OUT_LOOP:
       PUSH CX
       MOV AL,BYTE PTR[BX+2]
       PUSH BX
       CHAR_OUT AL,1,DL
       INC DL
       CMP DL,8
       JNZ CHANGE_COLOR
       SUB DL,7
    CHANGE_COLOR:
       PUSH DX
       INC_CURSOR
       POP DX
       POP BX
       INC BX
       POP CX
       LOOP STRING_OUT_LOOP


       LEA BX,BUF
       MOV CL,BYTE PTR[BX+1]
       MOV AL,CURSOR_COLUMN
       SUB AL,CL
       CMP AL,10
       JNB RENEW_COLUMN1
       ADD AL,BOARD_LEN
       MOV FLAG,1
    RENEW_COLUMN1:
       MOV CURSOR_COLUMN,AL
       RET
STRING_OUT ENDP
MAX_CAL PROC
    MOV AX,CENTER_X
    MOV BX,CENTER_Y
    MOV CX,320
    MOV DX,200
    SUB CX,AX
    SUB DX,BX

    CMP AX,BX
    JNA CMP1
    MOV AX,BX
    CMP1:
    CMP CX,DX
    JNA CMP2
    MOV CX,DX
    CMP2:
    CMP AX,CX
    JNA CMP_END
    MOV AX,CX
    CMP_END:
    MOV R_MAX,AX

    RET
MAX_CAL ENDP
; main
PUBLIC MAIN3
MAIN3 PROC
    INIT:
        MOV AX,DSEG
        MOV DS,AX
    
        INFO_OUT STRING_INPUT_INFO
        ; input content to disp
        STRING_INPUT BUF
        ; calculater edge condition
        LEA BX,BUF
        MOV AL,BOARD_RIGHT
        SUB AL,10
        MOV BOARD_LEN,AL

        ; screen init
        SET_DISP_MODE 02H
        SCRN_CLR 00H
        MOVE_CURSOR
        ; roll display
    OUT_LOOP:
        CMP COUNT,0
        JZ DRAW
        CMP CURSOR_COLUMN,40
        JNZ BEGIN_OUT
        MOV FLAG,0
    BEGIN_OUT:
        CALL STRING_OUT
        PAUSE
        SCRN_CLR 00H
        INC_CURSOR
        JMP OUT_LOOP
    DRAW:
        ;SCREEN_ROLLUP
        SCRN_CLR 07H
        MOV CURSOR_ROW,0
        MOV CURSOR_COLUMN,0
        MOVE_CURSOR
    X_INPUT:
        INPUT X_INPUT_INFO,X_INPUT,CENTER_X
        OF_CHECK CENTER_X,320,X_INPUT
    Y_INPUT:
        INPUT Y_INPUT_INFO,Y_INPUT,CENTER_Y
        OF_CHECK CENTER_Y,200,Y_INPUT

        CALL MAX_CAL
    R_INPUT:
        INPUT R_INPUT_INFO,R_INPUT,RADIUS
        OF_CHECK RADIUS,R_MAX,R_INPUT

        CALL DRAW_PROC
    EXIT:
        MOV AH,4CH
        INT 21H
MAIN3 ENDP

CODE   ENDS
       END  MAIN3