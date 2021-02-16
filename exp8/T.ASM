.486
INFO_OUT MACRO INFO
	LEA DX,INFO
	MOV AH, 09H
	INT 21H
ENDM

OPEN MACRO 
    PUSH AX
    IN  AL, 61H
	OR  AL, 00000011B
	OUT 61H, AL         	;接通扬声器
    POP AX
ENDM
CLOSE MACRO
    PUSH AX
    IN   AL, 61H
	AND  AL, 11111100B
	OUT  61H, AL         	;关闭扬声器
    POP AX 
ENDM
SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS

DSEG   SEGMENT USE16
    TABF DW 261,294,330,349,392,440,493
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
    RIGHT:
    RET
CHAR_JUDGE ENDP

PUBLIC MAIN6
; main
MAIN6 PROC
    INIT:
        MOV AX,DSEG
        MOV DS,AX
        MOV BX,0
        MOV CX,0
        MOV DX,0
        MOV DI,0
        MOV SI,0

    SOUND_LOOP:
        MOV AX,0
        INT 16H

    BEG:
        MOV FLAG,0
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
        OPEN
        SUB AL,31H
        MOVZX SI,AL
        SHL SI,1

        MOV DX, 12H
	    MOV AX, 34DEH
        LEA BX,TABF 	;SI为频率表指针
        MOV DI,WORD PTR[BX+SI] ;频率转换为计数值
	    SHL DI,CL
        DIV DI
        OUT 42H,AL
        MOV AL,AH
	    OUT 42H,AL       	;高8位送2号计数器
        
	    PUSHF           ;延时子程序
        MOV DI,01FFH
        
    DELAY_LOOP1:
        MOV DX,00FFH
        DELAY_LOOP2:
        MOV AH,01H
        INT 16H
        JNZ NEW_CHAR
        DEC DX
        CMP DX,0
        JNZ DELAY_LOOP2
        DEC DI
        CMP DI,0
        JNZ DELAY_LOOP1
        

        POPF
        CLOSE
        JMP SOUND_LOOP
    EXIT:
        CLOSE
        RET
    NEW_CHAR:
        POPF
        CLOSE
        JMP SOUND_LOOP
MAIN6 ENDP    
CODE   ENDS
       END  MAIN6

