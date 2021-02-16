.486
DATA SEGMENT USE16
	INPUT1     DB "What's your name? ",'$'
	INPUT2     DB "Which class are you in? ",'$'
	INPUTEMPTY DB "Your input is empty! ",'$'
	INPUTWRONG DB "You have input wrong characters! ",'$'
	OUTPUT1    DB "Your name is ",'$'
	OUTPUT2    DB ", and your class is ",'$'
	OUTPUT3    DB ". confirm(y/n)? ",'$'
	BUF1       DB 20
	           DB ?
	           DB 20 DUP(?)
	BUF2       DB 20
	           DB ?
	           DB 20 DUP(?)
	BUF3       DB 2
	           DB ?
	           DB 2 DUP(?)
DATA   ENDS

; output char in DL
CHAR_OUT MACRO CHAR
		MOV 	DL,CHAR
		MOV    AH,02H
	    INT    21H
ENDM

;output string in DX
STRING_OUT  MACRO STR
	LEA DX,STR
	MOV    AH, 09H
	INT    21H
ENDM

CODE SEGMENT USE16
	             ASSUME CS:CODE,DS:DATA
	; main
PUBLIC MAIN1
MAIN1 PROC FAR
	             MOV    AX,DATA
	             MOV    DS,AX
	INPUT_NAME:  
	; output hint1
	            STRING_OUT INPUT1
	; input string1
	             LEA    SI,BUF1
	             CALL   STRING_INPUT
	; check empty
	             MOVZX  AX,BUF1+1
	             CALL   STRING_EMPTY
	             JZ     INPUT_NAME
	; check character
	             LEA    BX,BUF1
	             ADD    BX,2
	             MOVZX  CX,BUF1+1
	             MOV    AL,0
	             CALL   STRING_CHAR
	             CMP    AL,0
	             JNZ    INPUT_NAME
	; output \n
	             CHAR_OUT 0AH

	INPUT_CLASS: 
	; output hint2
	             STRING_OUT INPUT2
	; input string2
	             LEA    SI,BUF2
	             CALL   STRING_INPUT
	;check empty
	             MOVZX  AX,BUF2+1
	             CALL   STRING_EMPTY
	             JZ     INPUT_CLASS
	; check character
	             LEA    BX,BUF2
	             ADD    BX,2
	             MOVZX  CX,BUF2+1
	             MOV    AL,0
	             CALL   STRING_CHAR
	             CMP    AL,0
	             JNZ    INPUT_CLASS
	; output \n
	            CHAR_OUT 0AH
	;output your info
	             STRING_OUT OUTPUT1
	             STRING_OUT BUF1+2
	             STRING_OUT OUTPUT2
	             STRING_OUT BUF2+2
	             STRING_OUT OUTPUT3
	; input confirm
	             LEA    SI,BUF3
	             CALL   STRING_INPUT

	;check
	             MOV    AL,BUF3+2
	             CMP    AL,'Y'
	             JZ     T
	             CMP    AL,'y'
	             JZ     T

	; T: back to begin
	F:           CHAR_OUT 0AH
	             JMP    INPUT_NAME
	;program end
	T:           RET
	             
MAIN1 ENDP

; input string in SI
STRING_INPUT PROC
	             MOV    DX,SI
	             MOV    AH,0AH
	             INT    21H
	; add $
	             ADD    DX,2
	             MOV    BX,DX
	             MOVZX  SI,[SI+1]
	             MOV    BYTE PTR BX[SI],'$'
	             RET
STRING_INPUT ENDP
	
;check if len(str)=0
STRING_EMPTY PROC
	             CMP    AX,0
	             JZ     EMTPY_INFO
	             RET
	EMTPY_INFO:  
	             CHAR_OUT 0AH
	             STRING_OUT INPUTEMPTY
	             RET
STRING_EMPTY ENDP

;check illegal char
STRING_CHAR PROC
	CHAR_BEGIN:  
	             CMP    BYTE PTR[BX],30H
	             JB     CHAR_WRONG
	             CMP    BYTE PTR[BX],7AH
	             JA     CHAR_WRONG
	             CMP    BYTE PTR[BX],39H
	             JA     CHAR_1
	             JMP    CHAR_LOOP
	CHAR_1:      CMP    BYTE PTR[BX],41H
	             JB     CHAR_WRONG
	             CMP    BYTE PTR[BX],5AH
	             JA     CHAR_2
	             JMP    CHAR_LOOP
	CHAR_2:      CMP    BYTE PTR[BX],61H
	             JB     CHAR_WRONG
	             
	CHAR_LOOP:   INC    BX
	             LOOP   CHAR_BEGIN
	             RET
	CHAR_WRONG:  
	             MOV    AL,1
	             CHAR_OUT 0AH
	             STRING_OUT INPUTWRONG
				 CHAR_OUT 0AH
	             RET
STRING_CHAR ENDP

CODE   ENDS
       END  MAIN1