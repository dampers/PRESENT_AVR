
/*
 * enc.s
 *
 * Created: 2023-04-22 오후 7:46:08
 *  Author: MYOUNGSU
 */ 
 
  	.global PRESENT_enc
	.type PRESENT_enc, @function

#define ZERO  R1

#define P0  R2
#define P1  R3
#define P2  R4
#define P3  R5
#define P4  R6
#define P5  R7
#define P6  R8
#define P7  R9

#define T0  R14
#define T1  R15
#define T2  R16
#define T3  R17
#define T4  R18
#define T5  R19
#define T6  R20
#define T7  R21
#define T8  R22
#define T9  R23
#define CNT_OUT R24

.macro LOAD_PT pointer
	LDD P0,  \pointer+0
	LDD P1,  \pointer+1
	LDD P2,  \pointer+2
	LDD P3,  \pointer+3
	LDD P4,  \pointer+4
	LDD P5,  \pointer+5
	LDD P6,  \pointer+6
	LDD P7,  \pointer+7
.endm

.macro STORE_CT pointer
	STD \pointer+0,  P0
	STD \pointer+1,  P1
	STD \pointer+2,  P2
	STD \pointer+3,  P3
	STD \pointer+4,  P4
	STD \pointer+5,  P5
	STD \pointer+6,  P6
	STD \pointer+7,  P7
.endm

.macro PUSH_REGS 
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R14
    PUSH R15
    PUSH R16
    PUSH R17
.endm

.macro POP_REGS
	POP R17
	POP R16
	POP R15
	POP R14
	POP R9
	POP R8
	POP R7
	POP R6
	POP R5
	POP R4
	POP R3
	POP R2
.endm

.macro ADD_ROUND reg0, reg1, reg2, reg3, reg4, reg5, reg6, reg7, tmp
	LD  \tmp, X+
	EOR \reg0, \tmp
	LD  \tmp, X+
	EOR \reg1, \tmp
	LD  \tmp, X+
	EOR \reg2, \tmp
	LD  \tmp, X+
	EOR \reg3, \tmp
	
	LD  \tmp, X+
	EOR \reg4, \tmp
	LD  \tmp, X+
	EOR \reg5, \tmp
	LD  \tmp, X+
	EOR \reg6, \tmp
	LD  \tmp, X+
	EOR \reg7, \tmp
.endm



.macro P0_1 X2, X0, T
	// 	t = (X[2] ^ (X[0] >> 1)) & 0x55;
	LSR \T
	EOR \T, \X2
	ANDI \T, 0x55

	// X[2] = X[2] ^ t
	EOR \X2, \T
	
	LSL \T
	EOR \X0, \T
.endm

.macro P0_2 X4, X0, T
	// 	t = (X[4] ^ (X[0] >> 2)) & 0x33;
	LSR \T
	LSR \T
	EOR \T, \X4
	ANDI \T, 0x33

	// X[4] = X[4] ^ t
	EOR \X4, \T
	
	LSL \T
	LSL \T
	EOR \X0, \T
.endm

.macro P_0 X0, X1, X2, X3, X4, X5, X6, X7, T0, T1

	// 6 X 4 = 24 cycles
	MOVW \T0, \X4
	P0_1 \X7, \X5, \T1
	P0_1 \X6, \X4, \T0
	MOVW \T0, \X0
	P0_1 \X3, \X1, \T1
	P0_1 \X2, \X0, \T0
	// 26 cycles

	// 8 X 4 = 32 cycles
	MOVW \T0, \X2
	P0_2 \X7, \X3, \T1
	P0_2 \X6, \X2, \T0
	MOVW \T0, \X0
	P0_2 \X5, \X1, \T1
	P0_2 \X4, \X0, \T0
	// 34 cycles

	// 60 cycles
.endm


.macro P1_1 X2, X0, T
	// 	t = (X[2] ^ (X[0] >> 4)) & 0x0F;
	SWAP \T
	EOR \T, \X2
	ANDI \T, 0x0F

	// X[2] = X[2] ^ t
	EOR \X2, \T
	
	// X[0] ^= T << 4
	SWAP \T
	EOR \X0, \T
.endm

.macro P1_2 X4, X1, T

	MOV \T, \X4
	MOV \X4, \X1
	MOV \X1, \T

.endm

.macro P_1 X0, X1, X2, X3, X4, X5, X6, X7, T0, T1
	// 9 X 4 == 36
	MOVW \T0, \X4
	P1_1 \X7,\X5,\T1
	P1_1 \X6,\X4,\T0
	MOVW \T0, \X0
	P1_1 \X3,\X1,\T1
	P1_1 \X2,\X0,\T0

	// 3 X 2 = 6
	P1_2 \X6,\X3,\T1
	P1_2 \X4,\X1,\T1
.endm


.macro S_BOX X0, X1, X2, X3, X4, X5, X6, X7, T0_0, T0_1, T1_0, T1_1, T2_0, T2_1, T3_0, T3_1, T4_0, T4_1
	//T[0] = X[1] ^ X[2];
	MOVW \T0_0, \X2
	EOR \T0_0, \X4
	EOR \T0_1, \X5
	
	//T[1] = X[2] & T[0];
	MOVW \T1_0, \X4
	AND \T1_0, \T0_0
	AND \T1_1, \T0_1
	
	//T[2] = X[3] ^ T[1];
	MOVW \T2_0, \X6
	EOR \T2_0, \T1_0
	EOR \T2_1, \T1_1

	//T[4] = X[0] ^ T[2];
	MOVW \T4_0, \X0
	EOR \T4_0, \T2_0
	EOR \T4_1, \T2_1

	//T[1] = T[0] & T[2];
	MOVW \T1_0, \T0_0
	AND \T1_0, \T2_0
	AND \T1_1, \T2_1

	//T[0] = T[0] ^ T[4];
	EOR \T0_0, \T4_0
	EOR \T0_1, \T4_1


	//T[1] = T[1] ^ X[2];
	EOR \T1_0, \X4
	EOR \T1_1, \X5
	

	
	//T[3] = X[0] | T[1];
	MOVW \T3_0, \X0
	OR \T3_0, \T1_0
	OR \T3_1, \T1_1
	
	//X[1] = T[0] ^ T[3];
	MOVW \X2, \T0_0
	EOR \X2, \T3_0
	EOR \X3, \T3_1

	//X[0] = ~ X[0];
	COM \X0
	COM \X1
	
	//T[1] = T[1] ^ X[0];
	EOR \T1_0, \X0
	EOR \T1_1, \X1

	//X[3] = X[1] ^ T[1];
	MOVW \X6, \X2
	EOR \X6, \T1_0
	EOR \X7, \T1_1

	//T[1] = T[1] | T[0];
	OR \T1_0, \T0_0
	OR \T1_1, \T0_1

	//X[2] = T[2] ^ T[1];
	MOVW \X4, \T2_0
	EOR \X4, \T1_0
	EOR \X5, \T1_1

	//X[0] = T[4];
	MOVW \X0, \T4_0
	
.endm


PRESENT_enc:
	PUSH_REGS			// 24 cycles

	MOVW R30, R24		//PLAIN TEXT		1 cycles
	MOVW R26, R22		//ROUND KEY			1 cycles
	
	LOAD_PT Z			// 16 cycles

	LDI CNT_OUT, 15		// 1 cycles
	//BEGIN ROUND 
	
	LOOP:
	//1
	ADD_ROUND P0,P1,P2,P3,P4,P5,P6,P7,T0								// 24 cycles
	
	P_0 P0,P1,P2,P3,P4,P5,P6,P7,T8,T9									// 60 cycles
	S_BOX P0,P1,P2,P3,P4,P5,P6,P7,T0,T1,T2,T3,T4,T5,T6,T7,T8,T9			// 38 cycles
	P_1 P0,P1,P2,P3,P4,P5,P6,P7,T8,T9									// 32 cycles

	//2
	ADD_ROUND P0,P1,P2,P3,P4,P5,P6,P7,T0								// 24 cycles
	S_BOX P0,P1,P2,P3,P4,P5,P6,P7,T0,T1,T2,T3,T4,T5,T6,T7,T8,T9			// 38 cycles

	DEC CNT_OUT															// 1cycles
	CPSE CNT_OUT, ZERO													// 1 or 2
	RJMP LOOP															// 2 cycles

	ADD_ROUND P0,P1,P2,P3,P4,P5,P6,P7,T0								// 24 cycles
	
	P_1 P0,P1,P2,P3,P4,P5,P6,P7,T8,T9									// 32 cycles
	P_0 P0,P1,P2,P3,P4,P5,P6,P7,T8,T9									// 60 cycles

	S_BOX P0,P1,P2,P3,P4,P5,P6,P7,T0,T1,T2,T3,T4,T5,T6,T7,T8,T9			// 38 cycles

	ADD_ROUND P0,P1,P2,P3,P4,P5,P6,P7,T0								// 24 cycles

	STORE_CT Z															// 16 cycles

	POP_REGS															// 24 cycles
RET
