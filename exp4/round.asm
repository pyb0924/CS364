SSEG SEGMENT USE16
	STK DB 20 DUP(?)
SSEG ENDS
DSEG SEGMENT
      CENTER_X DW 150             ;原点坐标_X
      CENTER_Y DW 90              ;原点坐标_Y
      RADIUS   DW 50              ;半径_R
      LABEL_X  DW ?               ;外接正方形右边界
      LABEL_Y  DW ?               ;外接正方形下边界
      X_OFFSET DW ?
      RECT_SIZE DW ?
      DISTANCE DW ?
DSEG ENDS
CSEG SEGMENT
      ASSUME CS:CSEG , DS:DSEG, SS:SSEG
      ;description
DRAW_BY_COLUMN PROC
      MOV CX , CENTER_X      
      SUB CX , RADIUS         ;left
      COLUMN_DRAW:
      CMP CX , LABEL_X       ; draw to the last column
      JNA COLUMN_NEXT
      JMP DRAW2

      COLUMN_NEXT:
      MOV AX , CX      ;row num
      SUB AX , CENTER_X
      IMUL AX         ; delta x^2

      MOV SI,DISTANCE
      SUB SI, AX
      CALL SQRT

      MOV X_OFFSET,SI
      MOV DX, CENTER_Y
      ADD DX,X_OFFSET

      MOV AL , 02              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H
      SUB DX,X_OFFSET
      SUB DX,X_OFFSET
      MOV AL , 03              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      INC CX
      JMP COLUMN_DRAW
DRAW_BY_COLUMN ENDP
DRAW_BY_ROW PROC
      MOV DX,CENTER_Y
      SUB DX,RADIUS
      ROW_DRAW:
      CMP DX , LABEL_Y       ; draw to the last row
      JNA ROW_NEXT
      JMP DRAW3

      ROW_NEXT:
      MOV AX , DX      ;col num
      SUB AX , CENTER_Y
      PUSH DX
      IMUL AX         ; delta x^2
      POP DX

      MOV SI,DISTANCE
      SUB SI, AX
      CALL SQRT

      MOV X_OFFSET,SI
      MOV CX, CENTER_X
      ADD CX,X_OFFSET

      MOV AL , 02              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      SUB CX,X_OFFSET
      SUB CX,X_OFFSET
      MOV AL , 03              ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      INC DX
      JMP ROW_DRAW
DRAW_BY_ROW ENDP
;description
DRAW_RECT PROC
      MOV AX,RADIUS
      MUL AX
      SHR AX,1
      MOV SI,AX
      CALL SQRT
      
      MOV CX,CENTER_X
      MOV DX,CENTER_Y
      SUB DX,SI
      MOV DI,CENTER_Y
      ADD DI,SI

      DRAW_VERT:
      SUB CX,SI               ;draw left
      MOV AL , 05             ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      ADD CX,SI              ;draw right
      ADD CX,SI
      INT 10H
      SUB CX,SI
      
      INC DX
      CMP DX,DI
      JNA DRAW_VERT

      MOV CX,CENTER_X
      MOV DX,CENTER_Y
      SUB CX,SI
      MOV DI,CENTER_X
      ADD DI,SI
      DRAW_HORI:

      SUB DX,SI               ;draw up
      MOV AL , 05             ;COLOR
      MOV AH , 0CH             ;0C号子功能
      INT 10H

      ADD DX,SI              ;draw down
      ADD DX,SI
      INT 10H
      SUB DX,SI
      
      INC CX
      CMP CX,DI
      JNA DRAW_HORI

      RET
DRAW_RECT ENDP
SQRT PROC ; sqrt(SI)
      PUSH AX
      PUSH BX
      PUSH CX
      PUSH DX
      MOV CX,0
      SQRT_LOOP:
      MOV BX,CX
      ADD BX,BX
      INC BX      ;BX=2*CX+1
      SUB SI,BX
      JC SQRT_END
      INC CX
      JMP SQRT_LOOP
      SQRT_END:
      MOV SI,CX
      POP DX
      POP CX
      POP BX
      POP AX
      RET
SQRT ENDP
MAIN PROC FAR
      MOV AX , DSEG               ;装载DS段
      MOV DS , AX

      
      MOV AH,0                  ;设置图形显示模式4
      MOV AL,04H
      INT 10H

      MOV AX , CENTER_X           ; set down right axis
      ADD AX , RADIUS
      MOV LABEL_X , AX            
      MOV AX , CENTER_Y
      ADD AX , RADIUS
      MOV LABEL_Y , AX                             

      MOV AX , RADIUS
      MUL AX
      MOV DISTANCE , AX         ;r^2

DRAW1:     
      CALL DRAW_BY_COLUMN
DRAW2:
      CALL DRAW_BY_ROW

DRAW3:
      CALL DRAW_RECT
EXIT:
      MOV AH , 4CH
      INT 21H
MAIN ENDP
CSEG ENDS
END MAIN