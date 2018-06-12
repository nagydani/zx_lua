; Virtual Memory Management
;
; Glossary
; bank: 16 kilobytes of physical RAM
; page: 256 bytes of memory
; block: a block of virtual memory of at least 1, at most 127 pages (32512 bytes)
; buffer: a block with data
;
; Buffer Identifier: 2 bytes, block identifier
;
; Block Identifier: 2 bytes, root page identifier
;
; Page Identifier: 2 bytes
; byte 0: bank of page (to be sent to 7FFD)
; byte 1: high byte of page address
;
; Root page structure
; byte 255:
;   bits 0-6: number of child pages of the block (1 .. 127) or 0 for single-page blocks
;   bit	7: GC marker bit, always 0 for free blocks
; For 1-page blocks, bytes 0..254 contain the payload
; For at most 2-page blocks, bytes 0..253 contain at most 127 page identifiers
;
; Buffer structure
; byte 254 of root page: number of payload bytes in last page
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

; Helper function for mshort. DO NOT call!
mshort1:ld	a,(BANK_M)
	and	7
	ld	l,a
	ex	de,hl
	call	pcopy
	exx
	xor	a
	ld	e,255
	ld	(de),a
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
	dec	l
	jr	z,mshort1	; becomes single-page block
	; continue with pfree_de

; Page deallocation
; Input: DE = page identifier
pfree_de:
	ex	de,hl
	; continue with pfree

; Page deallocation
; Input: HL = page identifier
pfree:	ld	a,l		; make it a single-page block
	bank
	ld	l,255
	ld	(hl),0
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
	or	a	; single-page block?
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
	ld	a,l
	bank
	ld	l,255
	ld	a,(hl)
	add	a,a
	jr	z,palloc1	; allocate single-page block
	dec	(hl)
	ld	l,a
	dec	l
	ld	d,(hl)
	dec	l
	ld	e,(hl)
	ret	nz	; has not become single-page
	ld	a,e
	bank
	ex	de,hl
	ld	l,0
	ld	c,(hl)
	inc	l
	ld	b,(hl)
	push	bc
	or	7
	ld	l,a
	ex	de,hl
	ld	a,(FREE_L)
	bank
	pop	bc
	ld	(hl),c
	inc	l
	ld	(hl),b
	ret
palloc1:ld	l,a
	ld	e,(hl)
	ld	a,(BANK_M)
	and	7
	inc	l	; clear Z flag
	ld	d,(hl)
	ld	l,a
	ex	de,hl
	ld	(FREE_L),hl
	ret

; Buffer allocation
; Input: BC buffer length
; Output: DE = block identifier, Z set on error
balloc:	push	bc
	ld	a,b
	or	a
	jr	nz,balloc1	; multi-page block
	ld	a,c
	cp	254
	jr	nc,balloc2	; multi-page block
	call	msingle
	pop	bc
	ret	z
	dec	l	; clear Z flag
	ld	(hl),c
	ret
balloc1:ld	a,c
	or	a
	jr	z,ballocz	;no increment
balloc2:inc	b
ballocz:push	bc
	call	malloc1
	pop	bc
	ret	z
	dec	l	; clear Z flag, l = 254
	ld	(hl),c
	ret

; Block allocation
; Input: B = number of child pages in block (0 .. 127)
; Output: DE = root page identifier, Z set on error
malloc:	ld	a,b
	or	a
	jr	nz,malloc1 ; multi-page block
msingle:call	palloc	; allocate single-page block
	ret	z	; unable to allocate single page
	ld	a,e
	bank
	ld	h,d
	ld	l,255
	ld	(hl),0
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
	dec	l
	ld	(hl),e
	pop	bc
	djnz	mallocl
	dec	l	; reset Z flag
	ret
mallocz:pop	bc
	call	mfree
	xor	a	; set Z flag
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

; Buffer resize
; Input:
; HL = block identifier
; BC = new buffer length
; Output: Z set on error
bresize:push	hl
	push	bc
	call	blen
	pop	hl
	push	hl
	ld	a,b
	sub	h
	jr	z,bres0	; maybe no resize
	jr	c,bgrow	; grow
	neg
	pop	bc
	pop	hl
	ld	b,a
bshrink:push	bc
	push	hl
	call	mshort
	pop	hl
	pop	bc
	djnz	bshrink
	push	hl
	ld	a,l
	bank
	ld	l,254
	ld	(hl),c
	inc	l
	ld	a,(hl)
	dec	a
	pop	hl
	ret	nz
	or	c
	jr	z,bsh_0	; if C=0 (256 bytes) don't shrink
	inc	c
	jr	z,bsh_0	; if C=255 (255 bytes) don't shrink
bshr_s:	push	af	; old C in A
	push	hl
	call	mshort
	pop	hl
	ld	a,l
	bank
	ld	l,254
	pop	af
	ld	(hl),a
bsh_0:	or	1	; reset Z flag
	ret
bres0:	cp	h
	jr	nz,bres_no	; no resize for sure
	ld	a,c
	cp	l
	jr	z,bsh_0		; no size change
	jr	c,bgrow0	; maybe grow single-page buffer
	inc	a
	pop	hl
	jr	z,bshr_s	; if old length 255, shrink further
	ret
bres_no:pop	de
	pop	hl
	ld	a,l
	bank
	ld	l,254
	ld	(hl),e
	inc	l
	ret
bgrow0:	inc	l
	pop	hl
	ret	nz	; if new length not 255, do not grow
	call	mappend
	ret	z	; out of memory
	dec	l
	ld	(hl),255
	ret
bgrow:	ld	b,a
	pop	de	; new length
	pop	hl
	ld	c,0
bgrowl:	push	bc
	push	hl
	push	de
	call	mappend
	pop	de
	pop	hl
	pop	bc
	inc	c
	jr	z,brefree
	djnz	bgrowl
	ld	a,l
	bank
	ld	l,254
	ld	(hl),e
	inc	l	; clear Z
	ret
brefree:ld	b,c
brefrl:	push	bc
	push	hl
	call	mshort
	pop	hl
	pop	bc
	djnz	brefrl
	xor	a	; not enough memory
	ret

; Append page to block
; Input: HL = root page
; Output: Z set on error
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
	add	a,a
	jr	z,mapp1	; convert to multi-page
	inc	(hl)
	ld	l,a
	ld	(hl),e
	inc	l
	ld	(hl),d
	ret
mapp1:	ld	a,(BANK_M)
	and	7
	ld	l,a
	call	pcopy
	exx
	ld	a,l
	bank
	ld	l,1
	ld	(hl),d
	dec	l
	ld	(hl),e
	dec	l	; also clears Z flag
	ld	(hl),1
	ret

; Buffer length
; Input:
; HL = root page
; Output:
; BC = buffer length
blen:	ld	a,l
	bank
	ld	l,255
	ld	b,(hl)
	dec	l
	ld	c,(hl)
	xor	a
	cp	b
	ret	z
blen1:	cp	c
	ret	z
	dec	b
	ret

; Seek into buffer
; Input:
; DE = root page
; BC = offset
; Output:
; HL = pointing to seeked location
; Appropriate bank paged in
; C flag set, if successful
bseek:	push	de
	push	bc
	ld	l,e
	ld	h,d
	call	blen
	ld	l,c
	ld	h,b
	and	a
	sbc	hl,bc
	pop	bc
	pop	de
	ret	nc
	; continue with mseek

; Seek into block
; NO protection against overflow!
; Input:
; DE = root page identifier
; BC = offset
; Output:
; HL = pointing to seeked location
; Appropriate bank paged in
; C flag set
mseek:	ld	(ROOT_P),de
	ld	a,e
	ld	e,c
	ld	d,b
	bank
	ld	h,(iy+ROOT_P+1-PTR_IY)
	ld	l,255
	ld	a,(hl)
	and	$7F
	jr	nz,mseek1	; more than one page in the block
	ld	l,e
	scf
	ret
mseek1:	ld	a,d
	add	a,a
	ld	(MSTR_P),a
	ld	l,a
	ld	a,(hl)
	inc	l
	ld	h,(hl)
	bank
	ld	l,e
	scf
	ret

; Restore pointer from stream
; Input:
; HL=memory pointer
; ROOT_P=root page of block being read
; MSTR_P=streamed page pointer
; Output:
; DE=root page being seeked
; BC=offset of the pointed byte
mptr:	ld	de,(ROOT_P)
	ld	a,e
	bank
	ld	c,l
	ld	h,d
	ld	l,255
	xor	a
	ld	b,a
	cp	(hl)
	ret	z	; one-page block
	ld	a,(MSTR_P)
	srl	a
	ld	b,a
	ret

; Copy block content
; Input:
; DE, BC = source pointer
; DE',BC' = destination pointer
; IX = length
mcopy:	push	bc
	push	de
	call	mseek
	pop	de
	pop	bc
	ld	a,(hl)
	inc	bc
	ex	af,af'
	exx
	push	bc
	push	de
	call	mseek
	pop	de
	pop	bc
	ex	af,af'
	ld	(hl),a
	inc	bc
	exx
	dec	ix
	defb	$DD
	ld	a,h	; ixh
	defb	$DD
	or	l	; ixl
	jr	nz,mcopy
	ret

; Step one byte further in the block
; NO protection against overflow!
; Input:
; HL = pointing to current location
; Output:
; HL = pointing to next location
mnext:	macro
	inc	l
	call	z, mnext1
	endm
mnext1:	push	af
	push	bc
	ld	hl,(ROOT_P)
	ld	a,l
	bank
	ld	l,(iy+MSTR_P-PTR_IY)
	ld	a,(hl)
	inc	l
	ld	h,(hl)
	inc	l
	ld	(iy+MSTR_P-PTR_IY),l
	bank
	ld	l,0
	pop	bc
	pop	af
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
