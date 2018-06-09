; Virtual Memory Management
;
; Glossary:
; bank: 16 kilobytes of memory
; page: 256 bytes of memory
; block: a block of virtual memory of at least 1, at most 127 pages (32512 bytes)
;
; Block Identifier: 2 bytes, root page identifier
;
; Page Identifier: 2 bytes
; byte 0: bank of page (to be sent to 7FFD)
; byte 1: high byte of page address
;
; Root page structure
; byte 255: number of pages in the block (1 .. 127)
; For 1-page blocks, bytes 0..254 contain the payload
; For at most 2-page blocks, bytes 0..253 contain at most 127 page identifiers
;
; Free memory: A linked list of reusable blocks

; Page in memory bank
; Input: A = memory bank
bank:	macro
	ld	bc,$7FFD
	out	(c),a
	endm

; Block deallocation
; Input: HL = block identifier
mfree:	ld	de,(free_list)
	ld	(free_list),hl
	ld	a,l
	bank
	ld	l,255
	ld	a,(hl)
	inc	l
	cp	1	; single-page block?
	jr	z, mfree1
	ld	a,(hl)	; get to first page
	inc	l
	ld	h,(hl)
	bank
	dec	l
mfree1:	ld	(hl),e
	inc	l
	ld	(hl),d
	ret

; Page allocation
; Output: DE = page identifier, Z set on error
palloc:	ld	hl,(free_list)
	ld	a,l
	or	h
	ret	z	; memory full
	bank
	ld	l,255
	dec	(hl)
	jr	z,palloc1
	ld	l,(hl)
	sla	l
	ld	e,(hl)
	inc	l
	ld	d,(hl)
	dec	l
	dec	l
	dec	l
	ret	nz	; block has not become single-page
	ld	a,(hl)
	inc	l
	ld	h,(hl)
	bank
	ld	l,255
	ld	(hl),1
	ld	l,a
	push	de
	call	mfree	; clears Z flag
	pop	de
	ret
palloc1:inc	l
	ld	a,(hl)
	inc	l	; clears Z flag
	ld	h,(hl)
	ld	l,a
	ld	de,(free_list)
	ld	(free_list),hl
	ret

; Block allocation
; Input: B = number of pages in block (1 .. 127)
; Output: DE = root page identifier, Z set on error
malloc:	ld	a,b
	cp	1
	jr	nz,malloc1
	call	palloc
	ret	z	; unable to allocate single page
	ld	a,e
	bank
	ld	h,d
	ld	l,255
	ld	(hl),1
	ret
malloc1:push	bc
	call	palloc
	ld	a,e
	bank
	pop	bc
	ret	z	; unable to allocate root page
	ld	h,d
	ld	l,255
	ld	(hl),0	; reset page count
mallocl:push	bc
	push	de
	call	palloc
	pop	hl
	jr	z,mallocz
	ld	a,l
	bank
	ld	l,255
	inc	(hl)
	ld	l,(hl)
	sla	l
	dec	l
	ld	(hl),d
	dec	l	; cannot be 0 in the last iteration
	ld	(hl),e
	pop	bc
	djnz	mallocl
	ret
mallocz:pop	bc
	call	mfree
	xor	a
	ret
