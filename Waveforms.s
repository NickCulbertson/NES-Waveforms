.segment "HEADER"
  .byte $4E, $45, $53, $1A
  .byte 2               ; 2x 16KB PRG code
  .byte 1               ; 1x  8KB CHR data
  .byte $01, $00        ; mapper 0, vertical mirroring

.segment "VECTORS"
  ;; When an NMI happens (once per frame if enabled) the label nmi:
  .addr nmi
  ;; When the processor first turns on or is reset, it will jump to the label reset:
  .addr reset
  ;; External interrupt IRQ (unused)
  .addr 0

; "nes" linker config requires a STARTUP section, even if it's empty
.segment "STARTUP"

; Main code segment for the program
.segment "CODE"

; Plays scale using pulse wave and triangle waves. See:
; http://wiki.nesdev.com/w/index.php/APU_basics

play_sounds:
  ldy #20
	jsr delay_y_frames
  jsr play_intro
  jsr play_pulse_scale_a
  jsr play_pulse_scale_b
  jsr play_pulse_scale_c
  jsr play_pulse_scale_d
  jsr play_tri_scale
  jsr play_noise_note
  jsr play_intro
  rts

play_pulse_scale_a:
	ldx #0
:       jsr play_pulse_note_a
	inx
	cpx #72
	bne :-
	rts
play_pulse_scale_b:
	ldx #0
:       jsr play_pulse_note_b
	inx
	cpx #72
	bne :-
	rts

play_pulse_scale_c:
	ldx #0
:       jsr play_pulse_note_c
	inx
	cpx #72
	bne :-
	rts

play_pulse_scale_d:
	ldx #0
:       jsr play_pulse_note_d
	inx
	cpx #72
	bne :-
	rts

play_tri_scale:
	ldx #0
:       jsr play_tri_note
	inx
	cpx #72
	bne :-
	rts

play_pulse_note_a:
	lda periodTableHi,x
	sta $4003
	lda periodTableLo,x
	sta $4002
	lda #%00111111
  sta $4000
	ldy #8
	jsr delay_y_frames
	lda #%00110000
  sta $4000
	ldy #4
	jsr delay_y_frames
	rts

play_pulse_note_b:
	lda periodTableHi,x
	sta $4003
	lda periodTableLo,x
	sta $4002
	lda #%01111111
  sta $4000
	ldy #8
	jsr delay_y_frames
	lda #%01110000
  sta $4000
	ldy #4
	jsr delay_y_frames
	rts

play_pulse_note_c:
	lda periodTableHi,x
	sta $4003
	lda periodTableLo,x
	sta $4002
	lda #%10111111
  sta $4000
	ldy #8
	jsr delay_y_frames
	lda #%10110000
  sta $4000
	ldy #4
	jsr delay_y_frames
	rts

play_pulse_note_d:
	lda periodTableHi,x
	sta $4003
	lda periodTableLo,x
	sta $4002
	lda #%11111111
  sta $4000
	ldy #8
	jsr delay_y_frames
	lda #%11110000
  sta $4000
	ldy #4
	jsr delay_y_frames
	rts

play_noise_note:
  lda #%00001111
  sta $400E
  lda #%00111111
  sta $400C
  jsr stop_noise
  lda #%00001010
  sta $400E
  lda #%00111111
  sta $400C
  jsr stop_noise
  lda #%00000101
  sta $400E
  lda #%00111111
  sta $400C
  jsr stop_noise
	rts

stop_noise:
	ldy #200
	jsr delay_y_frames
  lda #%00000000
  sta $400E
  lda #%00110000
  sta $400C
	ldy #8
	jsr delay_y_frames
  rts

play_tri_note:
	;triangle is octave lower +12
	lda periodTableHi,x
	sta $400B
	lda periodTableLo,x
	sta $400A
	lda #%11000000
	sta $4008
	sta $4017
	ldy #8
	jsr delay_y_frames
	lda #%10000000
	sta $4008
	sta $4017
	ldy #4
	jsr delay_y_frames
	rts

play_intro:
	ldx #20             ;set note number
	jsr intro_note      ;play note
	ldy #60             ;set delay time
	jsr delay_y_frames  ;run delay

	ldx #22
	jsr intro_note
	ldy #20
	jsr delay_y_frames

	ldx #23
	jsr intro_note
	ldy #40
	jsr delay_y_frames

	ldx #20
	jsr intro_note
	ldy #40
	jsr delay_y_frames

	ldx #26
	jsr intro_note
	ldy #80
	jsr delay_y_frames

	ldx #27
	jsr intro_note
	ldy #80
	jsr delay_y_frames

  ldx #0
	lda #%10000000
	sta $4008
	sta $4017
	ldy #20
	jsr delay_y_frames
	rts

intro_note:
  lda periodTableHi,x
	sta $400B
	lda periodTableLo,x
	sta $400A
	lda #%11000000
	sta $4008
	sta $4017
  rts

; NTSC period table generated by mktables.py. See
; http://wiki.nesdev.com/w/index.php/APU_period_table
periodTableLo:
  .byt $f1,$7f,$13,$ad,$4d,$f3,$9d,$4c,$00,$b8,$74,$34
  .byt $f8,$bf,$89,$56,$26,$f9,$ce,$a6,$80,$5c,$3a,$1a
  .byt $fb,$df,$c4,$ab,$93,$7c,$67,$52,$3f,$2d,$1c,$0c
  .byt $fd,$ef,$e1,$d5,$c9,$bd,$b3,$a9,$9f,$96,$8e,$86
  .byt $7e,$77,$70,$6a,$64,$5e,$59,$54,$4f,$4b,$46,$42
  .byt $3f,$3b,$38,$34,$31,$2f,$2c,$29,$27,$25,$23,$21
  .byt $1f,$1d,$1b,$1a,$18,$17,$15,$14

periodTableHi:
  .byt $07,$07,$07,$06,$06,$05,$05,$05,$05,$04,$04,$04
  .byt $03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02
  .byt $01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
  .byt $00,$00,$00,$00,$00,$00,$00,$00

; Initializes APU registers and silences all channels
init_apu:
	lda #$0F
	sta $4015
	
	ldy #0
:       lda @regs,y
	sta $4000,y
	iny
	cpy #$18
	bne :-
	
	rts
@regs:
	.byte $30,$7F,$00,$00
	.byte $30,$7F,$00,$00
	.byte $80,$00,$00,$00
	.byte $30,$00,$00,$00
	.byte $00,$00,$00,$00
	.byte $00,$0F,$00,$C0

; Delays Y/60 second
delay_y_frames:
:       jsr delay_frame
	dey
	bne :-
	rts

; Delays 1/60 second
delay_frame:
	lda #67
:       pha
	lda #86
	sec
:       sbc #1
	bne :-
	pla
	sbc #1
	bne :--
	rts


reset:
  jsr init_apu
  jsr play_sounds

forever:
  jmp forever

nmi:    
  jmp nmi

.segment "CHARS"
	.res $2000