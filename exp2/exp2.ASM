.486
DATA SEGMENT USE16
	INPUT1     DB "What's your name?",'$'
	INPUT2     DB "Which class are you in?",'$'
	INPUTEMPTY DB "Your input is empty!",'$'
	OUTPUT1    DB "Your name is ",'$'
	OUTPUT2    DB ", and your class is ",'$'
	OUTPUT3    DB ". confirm(y/n)",'$'
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

CODE SEGMENT USE16
	            ASSUME CS:CODE,DS:DATA
	BEG:        MOV    AX,DATA
	            MOV    DS,AX

	INPUTCODE1: 
	; input hint1
	            LEA    DX, INPUT1
	            MOV    AH, 09H
	            INT    21H
	; input string1
	            LEA    DX,BUF1
	            MOV    AH,0AH
	            INT    21H
	; add $
	            LEA    DI,BUF1+2
	            MOVZX  BX,BUF1+1
	            MOV    BYTE PTR [DI+BX],'$'
	; output \n
	            MOV    DL,0AH
	            MOV    AH,02H
	            INT    21H
	; input check
	            CMP    BX,0
	            JZ     EmptyCheck1
	            JNZ    INPUTCODE2
	
	; report error
	EmptyCheck1:LEA    DX, INPUTEMPTY
	            MOV    AH, 09H
	            INT    21H
	; output \n
	            MOV    DL,0AH
	            MOV    AH,02H
	            INT    21H
	            JMP    INPUTCODE1
	
	
	INPUTCODE2: 
	; input hint2
	            LEA    DX, INPUT2
	            MOV    AH, 09H
	            INT    21H
	; input string2
	            LEA    DX,BUF2
	            MOV    AH,0AH
	            INT    21H
	; add $
	            LEA    DI,BUF2+2
	            MOVZX  BX,BUF2+1
	            MOV    BYTE PTR [DI+BX],'$'
	; output \n
	            MOV    DL,0AH
	            MOV    AH,02H
	            INT    21H
	; input check
	            CMP    BX,0
	            JZ     EmptyCheck2
	            JNZ    OUTPUTCODE
	
	
	EmptyCheck2:
	; report error
	            LEA    DX, INPUTEMPTY
	            MOV    AH, 09H
	            INT    21H
	; output \n
	            MOV    DL,0AH
	            MOV    AH,02H
	            INT    21H
	            JMP    INPUTCODE2

	; output string (loop)
	;       MOV CL,BUF+1
	;       LEA BX,BUF+2

	; S:    MOV DL,[BX]
	;       MOV AH,02H
	;       INT 21H
	;      INC BX
	;       LOOP S

	
	OUTPUTCODE: 
	;output string
	            LEA    DX,OUTPUT1
	            MOV    AH, 09H
	            INT    21H
	            
	            LEA    DX,BUF1+2
	            MOV    AH, 09H
	            INT    21H
	            
	            LEA    DX,OUTPUT2
	            MOV    AH, 09H
	            INT    21H
	            
	            LEA    DX,BUF2+2
	            MOV    AH, 09H
	            INT    21H

	            LEA    DX,OUTPUT3
	            MOV    AH, 09H
	            INT    21H
	; input confirm
	            LEA    DX,BUF3
	            MOV    AH,0AH
	            INT    21H
	; add $
	            LEA    DI,BUF3+2
	            MOVZX  BX,BUF3+1
	            MOV    BYTE PTR [DI+BX],'$'
	;check
	            MOV    AL,BUF3+2
	            CMP    AL,'Y'
	            JZ     T
	            CMP    AL,'y'
	            JZ     T

	; T: back to begin
	F:          MOV    DL,0AH
	            MOV    AH,02H
	            INT    21H
	            JMP    INPUTCODE1

	; F: end
	T:          MOV    AH,4CH
	            INT    21H

CODE   ENDS
       END  BEG