;FILENAME: MUSIC.ASM
.486
DATA SEGMENT USE16
	TABF DW  -1,261,350,350,350,441,393,350,393,441
	     DW  350,350,441,525,589,589,589,525,441
	     DW  441,350,393,350,393,441,350,293,294,262
	     DW  350,589,525,441,440,350,393,350,393,589
	     DW  525,441,440,525,589,700,525,441,440,350
	     DW  393,350,393,441,350,294,292,262,350,0
	TABT DB  4,4,6,2,4,4,6,2,4,4
	     DB  6,2,4,4,12,1,3,6,2
	     DB  4,4,6,2,4,4,6,2,4,4
	     DB  12,4,6,2,4,4,6,2,4,4
	     DB  6,2,4,4,12,4,6,2,4,4
	     DB  6,2,4,4,6,2,4,4,12
	N    EQU 150000                                 	;微秒
DATA ENDS

CODE SEGMENT USE16
	ASSUME CS:CODE, DS:DATA
MAIN PROC
	BEG:  MOV    AX, DATA
	      MOV    DS, AX
	OPEN: IN     AL, 61H
	      OR     AL, 00000011B
	      OUT    61H, AL         	;接通扬声器
	AGA:  LEA SI,TABF 	;SI为频率表指针
	      LEA DI,TABT 	;DI为时间表指针
	LAST: CMP    WORD PTR[SI], 0 	;奏完一遍
	      JE     AGA
	      MOV    DX, 12H
	      MOV    AX, 34DEH
	      DIV    WORD  PTR[SI]   	;频率转换为计数值
	      OUT    42H, AL         	;低8位送2号计数器
	      MOV    AL, AH
	      OUT    42H, AL         	;高8位送2号计数器
	      CALL   DELAY           	;延时
	      ADD    SI, 2           	;频率表指针加2
	      INC    DI              	;时间表指针加1
	      MOV    AH, 1
	      INT    16H             	;有键入？
	      JZ     LAST            	;否
	CLOSE:IN     AL, 61H
	      AND    AL, 11111100B
	      OUT    61H, AL         	;关闭扬声器
	      MOV    AX, 4CH
	      INT    21H
MAIN ENDP
	
DELAY PROC                   		;延时子程序
	      MOV    EAX, 0
	      MOV    AL, [DI]
	      IMUL   EAX, EAX, N     	;EAX为演奏时间(微秒)
	      MOV    DX, AX
	      ROL    EAX, 16
	      MOV    CX, AX
	      MOV    AH, 86H
	      INT    15H
	      RET
DELAY ENDP
CODE ENDS
	END	MAIN