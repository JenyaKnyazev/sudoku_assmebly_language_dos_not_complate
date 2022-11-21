STA SEGMENT STACK
	DW 60 DUP(?)
STA ENDS
DATA SEGMENT
	MATRIX DB 81 DUP(?)
	IS_CORRECT_BOOL DB ?
	ROW DB ?
	COL DB ?
	VAL DB ?
	RANDOM_NUMBER DB ?
	SCREAN_START_POSITION_COL DB 31
	SCREAN_START_POSITION_ROW DB 1
	ROWS_MSG DB 'ROW: $'
	COLS_MSG DB 'COL: $'
	VALUE_MSG DB 'VALUE: $'
	WAIT_MSG DB 'PLEASE WAIT$'
	GAME_MSG DB 'GAME GAME  $'
	WIN_MSG DB  'YOU WIN$'
	LOSE_MSG DB 'YOU LOSE$'
	IS_SOLVED_BOOL DB ?
	IS_FINISHED_BOOL DB ?
	GAME_OVER_MSG DB 'GAME OVER$'
DATA ENDS
STACK_PUSH_REGISTERS MACRO
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH DI
	PUSH SI
ENDM
STACK_POP_REGISTERS MACRO
	POP SI
	POP DI
	POP DX
	POP CX
	POP BX
	POP AX
ENDM
CODE SEGMENT
	ASSUME CS:CODE,DS:DATA,SS:STA
MAIN:
	MOV AX,DATA
	MOV DS,AX
	CALL CLEAR
	CALL PRINT_EMPTY_BOARD
	CALL GENERATE_FIRST_ELEMENTS
	MOV DH,12
	MOV DL,52
	MOV AH,2
	INT 10H
	MOV DX,OFFSET GAME_MSG
	MOV AH,9
	INT 21H
	MOV CX,9
	RUN_MAIN:
	CALL INPUT
	CALL CHECK_FINISH
	CMP IS_FINISHED_BOOL,0
	JE RUN_MAIN
	MOV DH,23
	MOV DL,0
	MOV AH,2
	INT 10H
	;CALL SOLVED
	;CMP IS_SOLVED_BOOL,1
	;JE NEXT3
	;MOV DX,OFFSET LOSE_MSG
	;JMP FINISH_MAIN
	;NEXT3:
	;MOV DX,OFFSET WIN_MSG
	;FINISH_MAIN:
	MOV DX,OFFSET GAME_OVER_MSG
	MOV AH,9
	INT 21H
	MOV AH,4CH
	INT 21H
CLEAR PROC
	MOV BH,0
	MOV AH,2
	MOV DX,0
	RUN_CLEAR1:
	MOV DL,0
	RUN_CLEAR2:
	INT 10H
	MOV BL,DL
	MOV DL,' '
	INT 21H
	MOV DL,BL
	INC DL
	CMP DL,79
	JNG RUN_CLEAR2
	INC DH
	CMP DH,24
	JNG RUN_CLEAR1
	RET
CLEAR ENDP
PRINT_EMPTY_BOARD PROC
	MOV AH,2
	MOV BH,0
	MOV DL,SCREAN_START_POSITION_COL
	DEC DL
	MOV DH,0
	MOV SI,9
	RUN_BOARD1:
	MOV CX,19
	MOV DL,SCREAN_START_POSITION_COL
	DEC DL
	RUN_BOARD2:
	INT 10H
	MOV BL,DL
	MOV DL,'-'
	INT 21H
	MOV DL,BL
	INC DL
	LOOP RUN_BOARD2
	INC DH
	MOV CX,10
	MOV DL,SCREAN_START_POSITION_COL
	DEC DL
	RUN_BOARD3:
	INT 10H
	MOV BL,DL
	MOV DL,'|'
	INT 21H
	MOV DL,BL
	ADD DL,2
	LOOP RUN_BOARD3
	INC DH
	DEC SI
	JNZ RUN_BOARD1
	MOV CX,19
	MOV DL,SCREAN_START_POSITION_COL
	DEC DL
	RUN_BOARD4:
	INT 10H
	MOV BL,DL
	MOV DL,'-'
	INT 21H
	MOV DL,BL
	INC DL
	LOOP RUN_BOARD4
	MOV DL,SCREAN_START_POSITION_COL
	MOV DH,21
	INT 10H
	MOV DX,OFFSET ROWS_MSG
	MOV AH,9
	INT 21H
	MOV DL,SCREAN_START_POSITION_COL
	MOV DH,22
	MOV AH,2
	INT 10H
	MOV DX,OFFSET COLS_MSG
	MOV AH,9
	INT 21H
	MOV DL,SCREAN_START_POSITION_COL
	SUB DL,2
	MOV DH,23
	MOV AH,2
	INT 10H
	MOV DX,OFFSET VALUE_MSG
	MOV AH,9
	INT 21H
	MOV DH,12
	MOV DL,52
	MOV AH,2
	INT 10H
	MOV DX,OFFSET WAIT_MSG
	MOV AH,9
	INT 21H
	RET
PRINT_EMPTY_BOARD ENDP
GENERATE_RANDOM_1_9 PROC
	STACK_PUSH_REGISTERS
	CALL DELAY
	MOV AH,2H
	INT 1AH
	MOV AX,DX
	MOV DX,0
	MOV BX,9
	DIV BX
	INC DL
	MOV RANDOM_NUMBER,DL
	STACK_POP_REGISTERS
	RET
GENERATE_RANDOM_1_9 ENDP
DELAY PROC
	STACK_PUSH_REGISTERS
	MOV BX,20H
	RUN_DELAY2:
	MOV CX,0FFFFH
	RUN_DELAY:
	LOOP RUN_DELAY
	DEC BX
	JNZ RUN_DELAY2
	STACK_POP_REGISTERS
	RET
DELAY ENDP
INPUT PROC
	STACK_PUSH_REGISTERS
	MOV BH,0
	MOV AH,2
	MOV DL,36
	MOV DH,21
	INT 10H
	MOV AH,1
	INT 21H
	SUB AL,48
	MOV ROW,AL
	MOV AH,2
	MOV DL,36
	MOV DH,22
	INT 10H
	MOV AH,1
	INT 21H
	SUB AL,48
	MOV COL,AL
	MOV AH,2
	MOV DL,36
	MOV DH,23
	INT 10H
	MOV AH,1
	INT 21H
	SUB AL,48
	MOV VAL,AL
	CALL INPUT_TO_MATRIX
	CALL INPUT_TO_CONSOLE
	STACK_POP_REGISTERS
	RET
INPUT ENDP
INPUT_TO_MATRIX PROC
	STACK_PUSH_REGISTERS
	MOV AH,0
	MOV AL,ROW
	DEC AL
	MOV BL,9
	MUL BL
	ADD AL,COL
	DEC AL
	MOV SI,OFFSET MATRIX
	ADD SI,AX
	MOV AL,VAL
	MOV [SI],AL
	STACK_POP_REGISTERS
	RET
INPUT_TO_MATRIX ENDP
INPUT_TO_CONSOLE PROC
	STACK_PUSH_REGISTERS
	MOV BH,0
	MOV AL,ROW
	DEC AL
	MOV AH,0
	MOV BL,2
	MUL BL
	MOV DH,AL
	ADD DH,SCREAN_START_POSITION_ROW
	MOV AL,COL
	DEC AL
	MUL BL
	MOV DL,AL
	ADD DL, SCREAN_START_POSITION_COL
	MOV AH,2
	INT 10H
	CMP VAL,0
	JE ZERO
	MOV DL,VAL
	ADD DL,48
	JMP FINSIH_INPUT_CONSOLE
	ZERO:
	MOV DL,' '
	FINSIH_INPUT_CONSOLE:
	INT 21H
	STACK_POP_REGISTERS
	RET
INPUT_TO_CONSOLE ENDP
CHECK_POSIBLE PROC
	STACK_PUSH_REGISTERS
	MOV IS_CORRECT_BOOL,0
	MOV DI,OFFSET MATRIX
	MOV AH,0
	MOV AL,ROW
	DEC AL
	MOV BL,9
	MUL BL
	ADD DI,AX
	MOV CX,9
	RUN_CHECK:
	MOV BL,[DI]
	CMP BL,VAL
	JE FINISH_CHECK2
	INC DI
	LOOP RUN_CHECK
	MOV DI,OFFSET MATRIX
	MOV BL,COL
	MOV BH,0
	ADD DI,BX
	DEC DI
	MOV CX,9
	RUN_CHECK2:
	MOV BL,[DI]
	CMP BL,VAL
	JE FINISH_CHECK
	ADD DI,9
	LOOP RUN_CHECK2
	JMP NEXT2
	FINISH_CHECK2:
	JMP FINISH_CHECK
	NEXT2:
	MOV DI,OFFSET MATRIX
	ADD DI,AX
	MOV AL,COL
	DEC AL
	MOV AH,0
	ADD DI,AX
	MOV BL,3
	DIV BL
	MOV AL,AH
	MOV AH,0
	SUB DI,AX
	MOV AL,ROW
	DEC AL
	MOV BL,3
	DIV BL
	MOV AL,AH
	MOV AH,0
	MOV BL,9
	MUL BL
	SUB DI,AX
	MOV BX,3
	RUN_CHECK3:
	MOV CX,3
	RUN_CHECK4:
	MOV BL,[DI]
	CMP BL,VAL
	JE FINISH_CHECK
	INC DI
	LOOP RUN_CHECK4
	SUB DI,3
	ADD DI,9
	DEC BX
	CMP BX,0
	JG RUN_CHECK3
	MOV IS_CORRECT_BOOL,1
	FINISH_CHECK:
	CMP VAL,0
	JNE FINISH_CHECK3
	MOV IS_CORRECT_BOOL,1
	FINISH_CHECK3:
	STACK_POP_REGISTERS
	RET
CHECK_POSIBLE ENDP
GENERATE_FIRST_ELEMENTS PROC
	MOV CX,10
	RUN_TEST:
	CALL GENERATE_RANDOM_1_9
	MOV AL,RANDOM_NUMBER
	MOV ROW,AL
	CALL GENERATE_RANDOM_1_9
	MOV AL,RANDOM_NUMBER
	MOV COL,AL
	CALL GENERATE_RANDOM_1_9
	MOV AL,RANDOM_NUMBER
	MOV VAL,AL
	CALL CHECK_POSIBLE
	CMP IS_CORRECT_BOOL,0
	JE RUN_TEST
	CALL INPUT_TO_MATRIX
	CALL INPUT_TO_CONSOLE
	LOOP RUN_TEST
	RET
GENERATE_FIRST_ELEMENTS ENDP
SOLVED PROC
	MOV IS_SOLVED_BOOL,0
	MOV ROW,1
	MOV COL,1
	MOV SI,OFFSET MATRIX
	MOV DI,81
	RUN_SOLVED:
	MOV CX,9
	RUN_SOLVED2:
	MOV AL,0
	MOV AH,[SI]
	MOV [SI],AL
	MOV VAL,AH
	CALL CHECK_POSIBLE
	MOV [SI],AH
	CMP IS_CORRECT_BOOL,0
	JE FINISH_SOLVED
	INC SI
	INC COL
	LOOP RUN_SOLVED2
	MOV COL,1
	INC ROW
	SUB DI,9
	CMP DI,0
	JNE RUN_SOLVED
	MOV IS_SOLVED_BOOL,1
	FINISH_SOLVED:
	RET
SOLVED ENDP
CHECK_FINISH PROC
	MOV IS_FINISHED_BOOL,0
	MOV SI,OFFSET MATRIX
	MOV CX,81
	RUN_FINISH:
	MOV AL,[SI]
	CMP AL,0
	JE FINISH
	INC SI
	LOOP RUN_FINISH
	MOV IS_FINISHED_BOOL,1
	FINISH:
	RET
CHECK_FINISH ENDP
CODE ENDS
END MAIN
