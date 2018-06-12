; Virtual memory objects
;
; Glossary:
; string buffer: a buffer containing strings or program code
; value buffer: a buffer containing an array of values
;
; value: 7 bytes, primitive value or reference
;
; Value structure
; byte 0: type
;	0 	nil
;	1 	boolean
;	2 	number
;	3 	string
;	4 	function
;	5 	userdata
;	6 	thread
;	7 	table
;
; string value structure
; byte 1-2:	buffer identifier
; byte 3-4:	offset into the buffer
; byte 5-6;	string length
;
; String buffer structure
; byte 0-1:	reference counter
; byte 2-:	payload
;
; Value buffer structure
; byte 0-1:	next item in linked list of value buffers
; byte 2-3:	previous item in linked list of value buffers
; byte 4-10:	first value
; byte 11-:	subsequent values

; Multiplication by 7
; Input:
; BC = coefficient between 0 and 8191
; Output:
; HL = BC * 7
mul7:	ld	l,c
	ld	h,b
	add	hl,hl
	add	hl,hl
	add	hl,hl
	sbc	hl,bc
	ret

; Division by 7
; Input:
; HL = nominator between 7 and 32767
; Output:
; HL = HL / 7
div7:	ld	e,l
	ld	d,h
	ld	b,4
div7l:	srl	d
	rr	e
	srl	d
	rr	e
	srl	d
	rr	e
	add	hl,de
	djnz	div7l
	srl	h
	rr	l
	srl	h
	rr	l
	srl	h
	rr	l
	inc	hl
	ret
