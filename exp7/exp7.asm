.486
INPUT MACRO BUF1
	LEA DX,BUF1
	MOV AH,0AH
	INT 21H
ENDM
INFO_OUT MACRO INFO
	LEA DX,INFO
	MOV AH, 09H
	INT 21H
ENDM

CHAR_OUT MACRO CHAR
       MOV DL,CHAR
       MOV AH,02H
       INT 21H
ENDM
SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS

DSEG   SEGMENT USE16
    TABF DW 261,294,330,349,392,440,493
    N    EQU 150000
    BUF DB 2
        DB ?
        DB 2 DUP(?)
    RANGE DB 0
    FLAG DB 0
    INPUT_ERROR_INFO DB 'InputERROR!','$'
DSEG   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DSEG,SS:SSEG
;description
CHAR_JUDGE PROC
    CMP AL,30H
    JNB CHAR_JUDGE2
    MOV FLAG,1
    CHAR_JUDGE2:
    CMP AL,38H
    JNA RIGHT
    MOV FLAG,1
    INFO_OUT INPUT_ERROR_INFO
    CHAR_OUT 0AH
    RIGHT:
    RET
CHAR_JUDGE ENDP
; main
MAIN PROC
    INIT:
        MOV AX,DSEG
        MOV DS,AX
        IN  AL, 61H
	    OR  AL, 00000011B
	    OUT 61H, AL         	;接通扬声器
        LEA BX,TABF 	;SI为频率表指针
        MOV CL,0

    SOUND_LOOP:
        MOV FLAG,0
        MOV AX,0
        INT 16H

        CALL CHAR_JUDGE
        CMP FLAG,1
        JZ SOUND_LOOP

	    CMP AL,30H   	
        JZ EXIT
        CMP AL,38H
        JNZ READ_KEY
        XOR CL,1
        JMP SOUND_LOOP

    READ_KEY:    
        SUB AL,31H
        MOVZX SI,AL
        SHL SI,1

        MOV DX, 12H
	    MOV AX, 34DEH
        MOV DI,WORD PTR[BX+SI]   	;频率转换为计数值
	    SHL DI,CL
        DIV DI
        OUT 42H,AL
        MOV AL,AH
	    OUT 42H,AL         	;高8位送2号计数器
	    ;CALL DELAY           	;延时 
        JMP SOUND_LOOP   

    EXIT:
        IN     AL, 61H
	    AND    AL, 11111100B
	    OUT    61H, AL         	;关闭扬声器
        MOV AH,4CH
        INT 21H
MAIN ENDP    
CODE   ENDS
       END  MAIN

