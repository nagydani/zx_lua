	include "sysvars.asm"
; userspace Lua interpreter
	org	$8000
	jp	minit
	include "memory.asm"
	ld	hl,$2758
	exx
	ret
	include	"align.asm"
endp2:
