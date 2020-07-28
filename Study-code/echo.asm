.ORIG	x3000		
		LD 	r1, nl
		NOT r1, r1
		ADD r1, r1, #1
		LD 	r2, strg

input	TRAP x23
		STR r0, r2, #0
		ADD r3, r1, r0
		BRz oput
		ADD r2, r2, #1
		BRnzp input
output	LD  r2, strg
output1	LDR r0, r2, #0
		TRAP x21
		ADD r3, r1, r0
		BRz done
		ADD r2, r2, #1
		BRnzp ouput1
done	TRAP x25

nl		.FILL x0A
strg	.FILL x4000