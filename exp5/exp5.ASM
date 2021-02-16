.486
INFO_OUT MACRO INFO
	         LEA DX,INFO
	         MOV AH, 09H
	         INT 21H
ENDM

STRING_INPUT MACRO BUF1
	             LEA DX,BUF1
	             MOV AH,0AH
	             INT 21H
ENDM

CHAR_OUT MACRO CHAR
       MOV DL,CHAR
       MOV AH,02H
       INT 21H
ENDM

SSEG SEGMENT USE16
	STK  DB 20 DUP(?)
SSEG ENDS

DSEG SEGMENT USE16
       BUF DB 5
           DB ?
           DB 5 DUP(?)
       DATA_STR DB 5 DUP(?)
       DATA_NUM DW ?
       BASE DB 10
       INPUT_INFO DB "Please input a 4-bit hexadecimal number: ",'$'
       EQ_INFO DB "H=",'$'
       
       FLAG DB ?


DSEG   ENDS
CODE SEGMENT USE16
	ASSUME CS:CODE,DS:DSEG,SS:SSEG
CHAR_JUDGE PROC
       MOV FLAG,0
       CMP AL,30H
       JB CHAR_WRONG
       CMP AL,46H
       JA CHAR_WRONG
       CMP AL,3AH
       JB CHAR_RIGHT
       CMP AL,41H
       JB CHAR_WRONG
       
       CHAR_RIGHT:
       RET
       CHAR_WRONG:
       MOV FLAG,1
       RET
       
CHAR_JUDGE ENDP

CHAR_TO_NUM PROC
       CMP AL,3CH
       JA A_TO_F
       SUB AL,30H
       RET
       A_TO_F:
       SUB AL,55
       RET  
ENDP
;description
STR_TO_NUM PROC
       LEA DI,DATA_STR
       MOV AX,0
       MOV CX,4
    STR_TO_NUM_PUSH:
       MOV AL,[DI]
       CALL CHAR_TO_NUM
       PUSH AX
       INC DI
       LOOP STR_TO_NUM_PUSH

       MOV BX,0
       MOV CX,0
       MOV SI,4
    STR_TO_NUM_POP:
       POP AX
       SHL AX,CL
       ADD BX,AX
       ADD CL,4
       DEC SI
       CMP SI,0
       JNZ STR_TO_NUM_POP

       MOV DATA_NUM,BX
       RET
STR_TO_NUM ENDP

;description
DATA_OUTPUT PROC
       MOV AX,DATA_NUM
       MOV CX,0
       MOV DX,0
       MOV BX,10

    DATA_OUTPUT_PUSH:
       DIV BX
       ADD DX,30H
       PUSH DX
       MOV DX,0
       INC CX
       CMP AX,0

       JNZ DATA_OUTPUT_PUSH

    DATA_OUTPUT_POP:
       POP DX
       CHAR_OUT DL
       LOOP DATA_OUTPUT_POP

       RET

DATA_OUTPUT ENDP

PUBLIC MAIN4
MAIN4 PROC
    INIT:
	MOV    AX,DSEG
	MOV    DS,AX
       INFO_OUT INPUT_INFO

       MOV CX,4
       LEA BX,DATA_STR

    INPUT_LOOP:
       MOV AH,07H
       INT 21H
       CALL CHAR_JUDGE
       CMP FLAG,1
       JZ INPUT_LOOP
       MOV [BX],AL
       INC BX
       CHAR_OUT AL
       LOOP INPUT_LOOP

       MOV BYTE PTR[BX],'$'

       CALL STR_TO_NUM

       CHAR_OUT 0AH
       INFO_OUT DATA_STR
       INFO_OUT EQ_INFO
       
       CALL DATA_OUTPUT

    EXIT:
	MOV    AH,4CH
	INT    21H
MAIN4 ENDP
CODE   ENDS
       END  MAIN4