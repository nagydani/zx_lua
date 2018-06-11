	include "sysvars.asm"
; userspace Lua interpreter
	org	$8000
	include "memory.asm"
	include	"align.asm"
	ret
endp2:
