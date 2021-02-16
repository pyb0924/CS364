.486
STRING_INPUT MACRO BUF
    LEA   DX,BUF
	MOV    AH,0AH
	INT    21H
ENDM
INFO_OUT MACRO INFO
	LEA 	DX,INFO
	MOV    AH, 09H
	INT    21H
ENDM
ENDL MACRO 
    MOV DL,0AH
    MOV AH,02H
	INT 21H
ENDM
SSEG SEGMENT USE16
	STK DW 100 DUP(?)
SSEG ENDS



DSEG   SEGMENT USE16
    CHANGE_INFO DB "This function ends! ",'$'
    INPUT_ERROR_INFO DB "INPUTERROR! ",'$'
    END_INFO DB "Program Exited! ",'$' 
    INPUT_INFO DB "Please input your function order(1~6,input 0 to exit!) ",'$'
    BUF DB 2
        DB ?
        DB 2 DUP(?)
DSEG   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DSEG,SS:SSEG
EXTRN MAIN1
EXTRN MAIN2
EXTRN MAIN3
EXTRN MAIN4
EXTRN MAIN5
EXTRN MAIN6
; main
MAIN PROC
    INIT:
       MOV AX,DSEG
       MOV DS,AX
       INFO_OUT INPUT_INFO
       STRING_INPUT BUF
       ENDL
       LEA BX,BUF
       MOV AL,[BX+2]
       CMP AL,31H
       JZ F1
       CMP AL,32H
       JZ F2
       CMP AL,33H
       JZ F3
       CMP AL,34H
       JZ F4
       CMP AL,35H
       JZ F5
       CMP AL,36H
       JZ F6
       CMP AL,30H
       JZ EXIT
       INFO_OUT INPUT_ERROR_INFO
       ENDL
       JMP INIT
       
    F1:
       CALL FAR PTR MAIN1 ;OK
       ENDL
       JMP INIT

    F2:
       CALL FAR PTR MAIN2 ;OK
       ENDL
       JMP INIT
    F3:
       CALL FAR PTR MAIN3 ;OK
       JMP INIT

    F4:
       CALL FAR PTR MAIN4 ;OK
       ENDL
       JMP INIT
    F5:       
       CALL FAR PTR MAIN5 ;OK
       ENDL
       JMP INIT
       
    F6:       
       CALL FAR PTR MAIN6 ; TODO 一直响
       ENDL
       JMP INIT
    EXIT:
       INFO_OUT END_INFO
       MOV AH,4CH
       INT 21H
MAIN ENDP    
CODE   ENDS
       END  MAIN