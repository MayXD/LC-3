		.ORIG x3000
		LD	R1,SIX
		LD	R2,NUMBER
		AND	R3,R3,#0

;The inner loop
;
AGAIN	ADD	R3,R3,R2
		ADD	R1,R1,#-1
		BRp	AGAIN
;
		HALT
;
NUMBER	.BLKW 1
SIX		.FILL x0006
;
		.END