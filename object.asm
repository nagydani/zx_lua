; Virtual memory objects
;
; Glossary:
; string buffer: a buffer containing strings or program code
; value buffer: a buffer containing an array of values
;
; value: 8 bytes, primitive value or reference
;
; Value structure
; byte 0-1: type * 0x2000 | hash ^ 0x1FFF
;   0	0 	nil
;  32	1 	boolean
;  64	2 	number
;  96	3 	string
; 128	4 	function
; 160	5 	userdata
; 192	6 	thread
; 224	7 	table
;
; string value structure
; byte 2-3:	buffer identifier
; byte 4-5:	offset into the buffer
; byte 6-7;	string length
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

