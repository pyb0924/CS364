.486
SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS

DSEG   SEGMENT USE16
    DATA DD -9876543,-7654321,987651234,0
    SIGN DB ?
	N=4
DSEG   ENDS

CHAR_OUT MACRO CHAR
	MOV DL,CHAR
    MOV AH,02H
	INT 21H
ENDM


CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DSEG,SS:SSEG
; main
DATA_OUTPUT PROC
	;LOCAL NUM_TO_STRING_PUSH
	;LOCAL NUM_TO_STRING_POP
		MOV EAX,0
		MOV EDX,0
		MOV EAX,[DI]
		MOV SIGN,0
		MOV CX,0
		TEST EAX,80000000H
		JZ NUM_TO_STRING_PUSH
		; process negative num
		MOV SIGN,2DH
		NEG EAX	;change to unsigned num
NUM_TO_STRING_PUSH:
		MOV EBX,10
		DIV EBX
		ADD DX,30H
		PUSH DX
		MOV DX,0
		INC CX; n-bit decimal
		CMP AX,0
		JNZ NUM_TO_STRING_PUSH
		MOV DL,SIGN
		CMP DL,0
		JZ NUM_TO_STRING_POP
		CHAR_OUT DL
NUM_TO_STRING_POP:
		POP DX
		CHAR_OUT DL
		LOOP NUM_TO_STRING_POP

		RET
ENDP

OUTPUT PROC ;DATA,NUM;USE: DX(info),DI(data),SI(num）
;LOCAL RES_OUTPUT
	;STRING_OUT  INFO;output hint info
	MOV SI,N
	LEA DI,DATA	
RES_OUTPUT:
	CALL DATA_OUTPUT
	CHAR_OUT 20H
	ADD DI,4
	DEC SI
	CMP SI,0
	JNZ RES_OUTPUT

	RET
ENDP


MAIN PROC
       MOV AX,DSEG
       MOV DS,AX
       LEA DI,DATA

       CALL OUTPUT 

       MOV AH,4CH
       INT 21H
MAIN ENDP    
CODE   ENDS
       END  MAIN

