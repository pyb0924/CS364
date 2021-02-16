;exp1
.486
DATA   SEGMENT USE16
NUMA   DB ?
NUMB   DB 36H,18H
SUB1   DB ?
DIV1   DB ?
RES    DB ?
DATA   ENDS
CODE   SEGMENT USE16
       ASSUME CS:CODE,DS:DATA
BEG:   MOV AX,DATA
       MOV DS,AX
; sub
       MOV AH,NUMB
       MOV AL,[NUMB+1]
       MOV SUB1,AH
       SUB SUB1,AL
; div
       MOVZX AX,NUMB
       
       ;MOV DL,[NUMB+1]
       DIV [NUMB+1]
       MOV DIV1,AL
       MOV RES,AH

;loop pause
       MOV CX,40000
S:     NOP

       LOOP S

       MOV AH,4CH
       INT 21H
CODE   ENDS
       END  BEG
