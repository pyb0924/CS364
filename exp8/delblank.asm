.486
SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS

DSEG   SEGMENT USE16

DSEG   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DSEG,SS:SSEG
; main
MAIN PROC
    INIT:
       MOV AX,DSEG
       MOV DS,AX

    EXIT:
       MOV AH,4CH
       INT 21H
MAIN ENDP    
CODE   ENDS
       END  MAIN