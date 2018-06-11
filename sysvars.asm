; =========================
; Extended System Variables
; =========================
BANK_M:	equ $5B5C	; Shadowing banking and screen switching port $7FFD
FREE_L:	equ $5B83	; First block in the linked list of free blocks

; =========================
; Standard System Variables
; =========================
; These occupy addresses $5C00-$5CB5.
KSTATE:	equ $5C00	; IY-$3A   Used in reading the keyboard.
LASTK:	equ $5C08	; IY-$32   Stores newly pressed key.
REPDEL:	equ $5C09	; IY-$31   Time (in 50ths of a second) that a key must be held down before it repeats. This starts off at 35.
REPPER:	equ $5C0A	; IY-$30   Delay (in 50ths of a second) between successive repeats of a key held down - initially 5.
DEFADD:	equ $5C0B	; IY-$2F   Address of arguments of user defined function (if one is being evaluated), otherwise 0.
K_DATA:	equ $5C0D	; IY-$2D   Stores second byte of colour controls entered from keyboard.
TVDATA:	equ $5C0E	; IY-$2C   Stores bytes of colour, AT and TAB controls going to TV.
STRMS:	equ $5C10	; IY-$2A   Addresses of channels attached to streams.
CHARS:	equ $5C36	; IY-$04   256 less than address of character set, which starts with ' ' and carries on to '(c)'.
RASP:	equ $5C38	; IY-$02   Length of warning buzz.
PIP:	equ $5C39	; IY-$01   Length of keyboard click.
ERR_NR:	equ $5C3A	; IY+$00   1 less than the report code. Starts off at 255 (for -1) so 'PEEK 23610' gives 255.
FLAGS:	equ $5C3B	; IY+$01   Various flags to control the BASIC system:
			;             Bit 0: 1=Suppress leading space.
			;             Bit 1: 1=Using printer, 0=Using screen.
			;             Bit 2: 1=Print in L-Mode, 0=Print in K-Mode.
			;             Bit 3: 1=L-Mode, 0=K-Mode.
			;             Bit 4: 1=128K Mode, 0=48K Mode. [Always 0 on 48K Spectrum]
			;             Bit 5: 1=New key press code available in LAST_K.
			;             Bit 6: 1=Numeric variable, 0=String variable.
			;             Bit 7: 1=Line execution, 0=Syntax checking.
TVFLAG:	equ $5C3C	; IY+$02   Flags associated with the TV:
			;             Bit 0  : 1=Using lower editing area, 0=Using main screen.
			;             Bit 1-2: Not used (always 0).
			;             Bit 3  : 1=Mode might have changed.
			;             Bit 4  : 1=Automatic listing in main screen, 0=Ordinary listing in main screen.
			;             Bit 5  : 1=Lower screen requires clearing after a key press.
			;             Bit 6  : 1=Tape Loader option selected (set but never tested). [Always 0 on 48K Spectrum]
			;             Bit 7  : Not used (always 0).
ERR_SP:	equ $5C3D	; IY+$03   Address of item on machine stack to be used as error return.
LISTSP:	equ $5C3F	; IY+$05   Address of return address from automatic listing.
MODE:	equ $5C41	; IY+$07   Specifies cursor type:
			;             $00='L' or 'C'.
			;             $01='E'.
			;             $02='G'.
			;             $04='K'.
NEWPPC:	equ $5C42	; IY+$08   Line to be jumped to.
NSPPC:	equ $5C44	; IY+$0A   Statement number in line to be jumped to.
PPC:	equ $5C45	; IY+$0B   Line number of statement currently being executed.
SUBPPC:	equ $5C47	; IY+$0D   Number within line of statement currently being executed.
BORDCR:	equ $5C48	; IY+$0E   Border colour multiplied by 8; also contains the attributes normally used for the lower half
			;           of the screen.
E_PPC:	equ $5C49	; IY+$0F   Number of current line (with program cursor).
VARS:	equ $5C4B	; IY+$11   Address of variables.
DEST:	equ $5C4D	; IY+$13   Address of variable in assignment.
CHANS:	equ $5C4F	; IY+$15   Address of channel data.
CURCHL:	equ $5C51	; IY+$17   Address of information currently being used for input and output.
PROG:	equ $5C53	; IY+$19   Address of BASIC program.
NXTLIN:	equ $5C55	; IY+$1B   Address of next line in program.
DATADD:	equ $5C57	; IY+$1D   Address of terminator of last DATA item.
E_LINE:	equ $5C59	; IY+$1F   Address of command being typed in.
K_CUR:	equ $5C5B	; IY+$21   Address of cursor.
CH_ADD:	equ $5C5D	; IY+$23   Address of the next character to be interpreted - the character after the argument of PEEK,
			;           or the NEWLINE at the end of a POKE statement.
X_PTR:	equ $5C5F	; IY+$25   Address of the character after the '?' marker.
WORKSP:	equ $5C61	; IY+$27   Address of temporary work space.
STKBOT:	equ $5C63	; IY+$29   Address of bottom of calculator stack.
STKEND:	equ $5C65	; IY+$2B   Address of start of spare space.
BREG:	equ $5C67	; IY+$2D   Calculator's B register.
MEM:	equ $5C68	; IY+$2E   Address of area used for calculator's memory (usually MEMBOT, but not always).
FLAGS2:	equ $5C6A	; IY+$30   Flags:
			;             Bit 0  : 1=Screen requires clearing.
			;             Bit 1  : 1=Printer buffer contains data.
			;             Bit 2  : 1=In quotes.
			;             Bit 3  : 1=CAPS LOCK on.
			;             Bit 4  : 1=Using channel 'K'.
			;             Bit 5-7: Not used (always 0).
DF_SZ:	equ $5C6B	; IY+$31   The number of lines (including one blank line) in the lower part of the screen.
S_TOP:	equ $5C6C	; IY+$32   The number of the top program line in automatic listings.
OLDPPC:	equ $5C6E	; IY+$34   Line number to which CONTINUE jumps.
OSPPC:	equ $5C70	; IY+$36   Number within line of statement to which CONTINUE jumps.
FLAGX:	equ $5C71	; IY+$37   Flags:
			;             Bit 0  : 1=Simple string complete so delete old copy.
			;             Bit 1  : 1=Indicates new variable, 0=Variable exists.
			;             Bit 2-4: Not used (always 0).
			;             Bit 5  : 1=INPUT mode.
			;             Bit 6  : 1=Numeric variable, 0=String variable. Holds nature of existing variable.
			;             Bit 7  : 1=Using INPUT LINE.
STRLEN:	equ $5C72	; IY+$38   Length of string type destination in assignment.
T_ADDR:	equ $5C74	; IY+$3A   Address of next item in syntax table.
SEED:	equ $5C76	; IY+$3C   The seed for RND. Set by RANDOMIZE.
FRAMES:	equ $5C78	; IY+$3E   3 byte (least significant byte first), frame counter incremented every 20ms.
UDG:	equ $5C7B	; IY+$41   Address of first user-defined graphic. Can be changed to save space by having fewer
			;           user-defined characters.
COORDS:	equ $5C7D	; IY+$43   X-coordinate of last point plotted.
			; IY+$44   Y-coordinate of last point plotted.
P_POSN:	equ $5C7F	; IY+$45   33-column number of printer position.
PR_CC:	equ $5C80	; IY+$46   Full address of next position for LPRINT to print at (in ZX Printer buffer).
			;           Legal values $5B00 - $5B1F. [Not used in 128K mode]
ECHO_E:	equ $5C82	; IY+$48   33-column number and 24-line number (in lower half) of end of input buffer.
DF_CC:	equ $5C84	; IY+$4A   Address in display file of PRINT position.
DF_CCL:	equ $5C86	; IY+$4C   Like DF CC for lower part of screen.
S_POSN:	equ $5C88	; IY+$4E   33-column number for PRINT position.
			;  IY+$4F   24-line number for PRINT position.
SPOSNL:	equ $5C8A	; IY+$50   Like S_POSN for lower part.
SCR_CT:	equ $5C8C	; IY+$52   Counts scrolls - it is always 1 more than the number of scrolls that will be done before
			;           stopping with 'scroll?'.
ATTR_P:	equ $5C8D	; IY+$53   Permanent current colours, etc, as set up by colour statements.
MASK_P:	equ $5C8E	; IY+$54   Used for transparent colours, etc. Any bit that is 1 shows that the corresponding attribute
			;           bit is taken not from ATTR_P, but from what is already on the screen.
ATTR_T:	equ $5C8F	; IY+$55   Temporary current colours (as set up by colour items).
MASK_T:	equ $5C90	; IY+$56   Like MASK_P, but temporary.
P_FLAG:	equ $5C91	; IY+$57   Flags:
			;             Bit 0: 1=OVER 1, 0=OVER 0.
			;             Bit 1: Not used (always 0).
			;             Bit 2: 1=INVERSE 1, 0=INVERSE 0.
			;             Bit 3: Not used (always 0).
			;             Bit 4: 1=Using INK 9.
			;             Bit 5: Not used (always 0).
			;             Bit 6: 1=Using PAPER 9.
			;             Bit 7: Not used (always 0).
MEMBOT:	equ $5C92	; IY+$58   Calculator's memory area - used to store numbers that cannot conveniently be put on the
			;           calculator stack.
			; IY+$76   Not used on standard Spectrum. [Used by ZX Interface 1 Edition 2 for printer WIDTH]
RAMTOP:	equ $5CB2	; IY+$78   Address of last byte of BASIC system area.

