.486

STRING_OUT MACRO INFO
	LEA DX,INFO
	MOV AX,0900H
	INT 21H
ENDM
FILE_OPEN MACRO FILE_PATH,FILEHAND,MODE
       MOV AH,3DH
       MOV AL,MODE
       LEA DX,FILE_PATH
       INT 21H
       JC ERROR
       MOV FILEHAND,AX
ENDM
FILE_READ MACRO FILEHAND,POS
       MOV AH,3FH
       MOV BX,FILEHAND
       MOV CX,512
       LEA DX,POS
       INT 21H
       JC ERROR
ENDM
FILE_WRITE MACRO FILEHAND,POS,LEN
       MOV AH,40H
       MOV BX,FILEHAND
       MOV CX,LEN
       LEA DX,POS
       INT 21H
       CMP AX,LEN
       JNZ ERROR
ENDM
FILE_CREATE MACRO PATH,FILEHAND
       MOV AH,3CH
       MOV CX,00
       LEA DX,PATH
       INT 21H
       MOV FILEHAND,AX
ENDM
FILE_CLOSE MACRO FILEHAND
       MOV AH,3EH
       MOV BX,FILEHAND
       INT 21H
ENDM

SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS
DSEG   SEGMENT USE16
    FILEHAND1 DW ?
    FILEHAND2 DW ?
    PATH1 DB 'D:\delblank.asm',00H
    PATH2 DB 'D:\result.txt',00H
    ERROR_INFO DB 'ERROR!','$'
    BUF DB 512 DUP(?)
    LEN1 DW ?
    BUF_OUT DB 512 DUP(?)
    
    LEN2 DW ?
DSEG   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DSEG,SS:SSEG
PUBLIC MAIN5
; main
;description

MAIN5 PROC
    INIT:
       MOV AX,DSEG
       MOV DS,AX

       MOV BX,0
       MOV CX,0
       MOV SI,0
       MOV DI,0

       FILE_OPEN PATH1,FILEHAND1,0
       FILE_READ FILEHAND1,BUF
       MOV LEN1,AX
       FILE_CLOSE FILEHAND1
       
       LEA BX,BUF
       MOV DI,LEN1
       MOV BYTE PTR[BX+DI],'$'
       STRING_OUT BUF

       CALL REMOVE_SP

       LEA BX,BUF_OUT
       SUB DI,BX
       MOV LEN2,DI
       MOV BYTE PTR[BX+DI],'$'
       STRING_OUT BUF_OUT

       FILE_CREATE PATH2,FILEHAND2
       FILE_OPEN PATH2,FILEHAND2,1
       FILE_WRITE FILEHAND2,BUF_OUT,LEN2
       FILE_CLOSE FILEHAND2
       JMP EXIT
       
    ERROR:
       STRING_OUT ERROR_INFO
    EXIT:
       RET
MAIN5 ENDP

REMOVE_SP PROC
       LEA SI,BUF
       LEA DI,BUF_OUT
       MOV BX,0 ; BUF pointer
       ;MOV CX,0 ; count LEN2
    DEL_BP_LOOP:
       MOV AL,[SI+BX]
       CMP AL,20H
       JZ CHECK

       CMP AL,60H
       JNA MOVE
       CMP AL,7AH
       JA MOVE
       SUB AL,20H
    MOVE:
       MOV [DI],AL
       INC DI
    CHECK:
       INC BX
       CMP BX,LEN1
       JNZ DEL_BP_LOOP

       RET
REMOVE_SP ENDP
CODE   ENDS
       END  MAIN5