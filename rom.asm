; system variables
	include	"sysvars.asm"
; restarts
	org 0
rst0:	di
	ld	sp,(inittab)
	jp	minit
	defb	255
rst8:
; external sources
	include "memory.asm"
