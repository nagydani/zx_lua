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
; byte 255:
;   bits 0-6: number of pages in the block (1 .. 127)
;   bit	7: GC marker bit, always 0 for free blocks
; For 1-page blocks, bytes 0..254 contain the payload
; For at most 2-page blocks, bytes 0..253 contain at most 127 page identifiers
;
; Free memory: A linked list of reusable blocks

; Page in memory bank
; Input: A = memory bank
bank:	macro
	call	bank_r
	endm

bank_r:	ld	c,a
	ld	a,(BANK_M)
	and	$F8
	or	c
	ld	(BANK_M),a
	ld	bc,$7FFD
	out	(c),a
	ret

mshort1:push	de
	ld	l,255
	ld	b,(hl)
	push	bc
	inc	l
	ld	e,(hl)
	inc	l
	ld	d,(hl)
	ld	a,(BANK_M)
	and	7
	ld	l,a		; restore l
	ex	de,hl
	push	hl
	call	pcopy
	ex	de,hl
	dec	l
	pop	af
	and	$80	; retain GC bit
	inc	a
	ld	(hl),a
	call	pfree_hl
	pop	hl
	jr	pfree

; Shorten block by one page
; DO NOT call on single-page blocks!
; Input: HL = root block
mshort:	ld	a,l
	bank
	ld	l,255
	dec	(hl)
	ld	l,(hl)
	sla	l
	ld	e,(hl)
	inc	l
	ld	d,(hl)
	ld	a,l
	cp	3
	jr	z,mshort1	; becomes single-page block
	; continue with pfree_hl
pfree_hl:
	ex	de,hl
	; continue with pfree

; Page deallocation
; Input: HL = page identifier
pfree:	ld	a,l		; make it a single-page block
	bank
	ld	l,255
	ld	(hl),1
	ld	a,(BANK_M)	; restore L
	and	7
	ld	l,a
	; continue with mfree

; Block deallocation
; Input: HL = block identifier
mfree:	ld	de,(FREE_L)
	ld	(FREE_L),hl
	ld	a,l
	bank
	ld	l,255
	res	7,(hl)	; clear GC bit
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
palloc:	ld	hl,(FREE_L)
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
	ld	de,(FREE_L)
	ld	(FREE_L),hl
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

; Copy page content
; Input:
; HL = source page
; DE = target page
; Output:
; HL' = source page
; DE' = destination page
; destination page paged in, pointed by DE.
pcopy:	push	hl
	push	de
	exx
	pop	de
	pop	hl
	ld	b,0
pcopyl:	exx
	ld	a,l
	bank
	exx
	ld	l,b
	ld	a,(hl)
	ex	af,af'
	exx
	ld	a,e
	bank
	exx
	ld	e,b
	ex	af,af'
	ld	(de),a
	djnz	pcopyl
	ret

; Append page to block
; Input: HL = root page
mappend:ld	a,l
	bank
	ld	l,255
	ld	a,(hl)
	inc	a
	and	$7F
	ret	z	; block too long
	push	hl
	call	palloc
	pop	hl
	ret	z	; memory full
	ld	a,(hl)
	cp	1
	jr	z,mapp1	; append second page
	inc	(hl)
	add	a,a
	ld	l,a
	ld	(hl),e
	inc	l
	ld	(hl),d
	ret
mapp1:	push	de
	push	hl
	call	palloc
	pop	hl
	jr	nz,mapp2
	pop	hl
	ld	a,l
	bank
	ld	l,255
	ld	(hl),1
	and	7
	call	mfree	; free second page, if failed to allocate third
	cp	a	; set Z flag
	ret
mapp2:	call	pcopy
	exx
	ld	a,l	; make first page root
	bank
	ld	l,255
	ld	(hl),2
	inc	l
	ld	(hl),e
	inc	l
	ld	(hl),d
	pop	de
	inc	l
	ld	(hl),e
	inc	l	; clears Z flag
	ld	(hl),d
	ret

; Test and initialization of memory
inittab:
	defw	endp2	; leave space for interpreter, also bank 2
	defw	$C000
	defw	$6000	; leave space for screen 0, system variables and stack, also bank 5
	defw	$C001
	defw	$C003
	defw	$C004
	defw	$C006
	defw	$DB07	; leave space for screen 1
inittab_end:

; Starting point
minit:	ld	de,inittab
	ld	b,inittab_end-inittab
minitl0:ld	a,(de)
	ld	c,a
	exx
	bank
	exx
	inc	de
	ld	a,(de)
	ld	h,a
	ld	l,0
minitl1:inc	a
	ld	(hl),c
	inc	l
	ld	(hl),a
	or	$C0
	inc	a
	ld	a,(hl)
	inc	hl	; do not touch Z flag
	jr	nz,minitl1
	ld	a,l
	rrca
	ld	l,255
	ld	(hl),a
	djnz	minitl0
	ld	hl,0
	ld	(FREE_L),hl
	ld	hl,inittab
	ld	b,inittab_end-inittab
	ld	e,0
minitl2:ld	a,(hl)
	ld	c,a
	inc	hl
	exx
	bank
	exx
	ld	d,(hl)
	inc	hl
	ld	a,(de)
	cp	c
	jr	nz,banknf	; bank not found
	push	hl
	ld	l,c
	ld	h,d
	call	mfree
	ld	e,0
	pop	hl
banknf:	djnz	minitl2
