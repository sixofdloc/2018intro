;=============================================================================
; Set up screen and registers
;=============================================================================
setUp
    lda $02a6
    bne PAL
    jsr ntsc
PAL
    lda #$08
    sta $0286
    jsr $e544
    lda #$ff
    sta $d015 ;enable all sprites (we're only using 0-2 and 8)
    lda #$06
    sta $d027 ;scroll mask sprite colors
    sta $d028
    sta $d02e ;fader bar wiper mask color
    lda #$1f
    sta $d000
    lda #$37
    sta $d002
    lda #$58
    sta $d00e
    lda #$3a
    sta $07f8
    lda #$3b
    sta $07f9
    sta $07ff
    lda #$39
    sta $07fa
    sta $07fb
    sta $07fc
    sta $07fd
    lda #$7c
    sta $d01c
    lda #$0f
    sta $d025
    lda #$0c
    sta $d026
    lda #$01
    sta $d029

    lda #$00
    jsr $1000 ;initialize music

    ldx #$00
logoLoop
    lda LOGOSCN,x
    sta $0400,x
    lda LOGOSCN+$100,x
    sta $0500,x
    lda LOGOSCN+$12f,x
    sta $052f,x
    lda LOGOCOL,x
    sta $d800,x
    lda LOGOCOL+$100,x
    sta $d900,x
    lda LOGOCOL+$12f,x
    sta $d92f,x
    inx
    bne logoLoop

    jsr plotbar

;=============================================================================
; Set up IRQ
;=============================================================================
    sei
    lda #$35
    sta $01
    lda #$0b
    sta $d020
    sta $d021
    lda #$01
    sta $d019
    sta $d01a
    lda #$1b
    sta $d011
    lda #$7f
    sta $dc0d
    lda #$20
    sta $d012
    #SetIRQ IRQ0
    cli
    rts

;=============================================================================
;=============================================================================
mainLoop
    rts

;=============================================================================
;=============================================================================
checkSpace
	lda #%01111111 
	sta $dc00 
	lda $dc01 
	and #%00010000 
	bne noSpace
    sec
    rts
noSpace
    clc
    rts

;=============================================================================
; Clean up and shut down
;=============================================================================
tearDown
    sei
    lda #$37
    sta $01
    lda #0
    sta $d011
    sta $d020
    jmp $fce2
    rts


;=============================================================================
; Global IRQ Exit routine
;=============================================================================
IRQX
    #ACKIRQ
    #PopAll
    rti


;=============================================================================
; Top IRQ, turns on bitmap mode, does FLD for logo
;=============================================================================
IRQ0
    #PushAll
    lda #$3b
    sta $d011
    lda #$19
    sta $d018
    lda #$18
    sta $d016
    
    ldx #$00
    jsr doblingupdatesprite
;update bling sprites for fld
    lda $d005
    clc
    adc fld_1_size
    sta $d005
    
    #SetRaster IRQ1POS
    #SetIRQ IRQ1
    jmp IRQX

IRQ1
    #PushAll
    ldx fld_1_size
IRQ1_loop
   #fldmcbm
    #waitraster
    dex             
    bne IRQ1_loop   
NTSCMUSIC
    jsr $1003
    jsr activewipe
    jsr activewipe
    lda #IRQ2POS
    clc
    adc fld_1_size
    sta $d012
    #SetIRQ IRQ2
    jmp IRQX

IRQ2
    #PushAll
    ;turn off d011 mode
    lda $d011
    and #$ef
    sta $d011
    #waitraster
    ldy #$0c
    dey
    bne *-1

    ;turn off bitmap mode
    lda $d011
    and #$df
    sta $d011

    ;switch to text cset
    lda #$1f
    sta $d018

    ;do second FLD
    ldx fld_2_size
IRQ2_loop
   #fld
    #waitraster
    dex             
    bne IRQ2_loop   

    ;turn screen back on
    lda $d011
    ora #$10
    sta $d011

    lda #IRQ2aPOS
    clc
    adc fld_1_size
    adc fld_2_size
    sta $d012
    adc #$01
    sta $d00f
activewipe_msb
    lda #$82
    sta $d010
    #SetIRQ IRQ2a
    jmp IRQX
   
IRQ2a
    #PushAll 

    ldy #$07
    dey
    bne *-1
    lda #$01
    sta $d020
    sta $d021
NTSC0
    ldy #$0a
    dey
    bne *-1
    lda #$06
    sta $d020
    sta $d021
topbartextcolor
    lda #$04
    sta $d022
    #waitraster
    #waitraster
    lda #IRQ3POS
    clc
    adc fld_1_size
    adc fld_2_size
    sta $d012
    #SetIRQ IRQ3
    jmp IRQX


IRQ3
    #PushAll
    #waitraster
    #waitraster
    nop
    bit $ea

    lda #$01
    sta $d020
    sta $d021

NTSC1
    ldy #$09
    dey
    bne *-1
    nop
    lda #$0b
    sta $d020
    sta $d021
    
    #waitraster
    ldx fld_3_size
IRQ3_loop
   #fld
    #waitraster
    dex             
    bne IRQ3_loop   


    lda #IRQ4POS
    clc
    adc fld_1_size
    adc fld_2_size
    adc fld_3_size
    sta $d012
    adc #$01
    sta $d001
    sta $d003
    #SetIRQ IRQ4
    jmp IRQX


IRQ4
    #PushAll 
ScrollPos
    lda #$18
    sta $d016
    ldy #$06
    dey
    bne *-1
    lda #$01
    sta $d020
    sta $d021
    ldy #$09
    dey
    bne *-1
    lda #$06
    sta $d020
    sta $d021
    lda #$01
    sta $d022
    lda #IRQ5POS
    clc
    adc fld_1_size
    adc fld_2_size
    adc fld_3_size
    sta $d012
    #SetIRQ IRQ5
    jmp IRQX

IRQ5
    #PushAll
    ldy #$06
    dey
    bne *-1
    lda #$01
    sta $d020
    sta $d021
    ldy #$01
    dey
    bne *-1
    lda #$0b
    sta $d020
    sta $d021    
    lda #$18
    sta $d016


    jsr move_fld
    jsr move_fld
    jsr colorpulse
    jsr scroller
    jsr scroller
    ldx #$00
    jsr dobling

    lda #IRQ0POS
    sta $d012
    #SetIRQ IRQ0
    jmp IRQX

;=============================================================================
;Updates the sizes for the 3 fld effects
;=============================================================================
move_fld
    dec fldtick_1
    bne movefld1
    lda #$02
    sta fldtick_1
    ldx fldidx_1
    lda sintab,x
    sta fld_1_size
    inc fld_1_size
    ldx fldidx_2
    lda sintab,x
    sta fld_2_size
    ldx fldidx_3
    lda sintab,x
    sta fld_3_size
    inc fldidx_1
    lda fldidx_1
    cmp #$20
    bne mf_not1
    lda #$00
    sta fldidx_1
mf_not1
    inc fldidx_2
    lda fldidx_2
    cmp #$20
    bne mf_not2
    lda #$00
    sta fldidx_2
mf_not2
    inc fldidx_3
    lda fldidx_3
    cmp #$20
    bne mf_not3
    lda #$00
    sta fldidx_3
mf_not3
movefld1
        rts
;=============================================================================
;Updates the text color on the faderbar
;============================================================================
colorpulse
    dec colortick
    bne colorpulsex
    lda #$04
    sta colortick
    ldx coloridx
    lda colortable,x
    sta topbartextcolor+1
    inc coloridx
    lda coloridx
    cmp #$12
    bne colorpulsex
    lda #$00
    sta coloridx
colorpulsex
    rts

;=============================================================================
;Standard 2x2 scroller routine
;=============================================================================
scroller
    dec scrolltick
    bne colorpulsex
    lda #$01
    sta scrolltick
    dec ScrollPos+1
    lda ScrollPos+1
    cmp #$0f
    bne colorpulsex
    lda #$17
    sta ScrollPos+1
    
    ;move screen data
    ldx #$00
scrollmovloop
    lda $06f9,x
    sta $06f8,x
    lda $0721,x
    sta $0720,x
    inx
    cpx #$28
    bne scrollmovloop

scrollfetch    
    lda SCROLLTEXT
    cmp #$ff
    bne scrollnoreset

    ;reset scrolltext pointer
    lda #<SCROLLTEXT
    sta scrollfetch+1
    lda #>SCROLLTEXT
    sta scrollfetch+2
    jmp scrollfetch
scrollnoreset
    pha
    lda scrollflip
    beq firstcol
    pla
    clc
    adc #$40
    pha
firstcol
    pla
    sta $071f
    clc
    adc #$80
    sta $0747    
scrollerend
    ;toggle scrollflip, increment scrolltext pointer if it was 1
    lda scrollflip
    bne scrollinc
    lda #$01
    sta scrollflip
    jmp scrollerx
scrollinc
    lda #$00
    sta scrollflip
    inc scrollfetch+1
    bne scrollerx
    inc scrollfetch+2

scrollerx
    rts

;=============================================================================
;Bling animation overall controller
;=============================================================================
dobling ;expects which bling in x
    dec blinganimtick,x
    bne doblingx
    lda #$03
    sta blinganimtick,x
    ;increment our frame
    inc blinganimframe,x
blinggetframe
    lda blinganimframe,x
    ;are we at teh end of this bling?
    cmp #$09
    bne doblingx

    ;move to next bling

    ;set sprite frame for safety
    lda #$39
    sta $07fa,x

    ;set anim table position
    lda #$00
    sta blinganimframe,x

    ;set our delay before we start the anim
    lda blingposidx,x ;which bling we're on
    tay
    lda blingdelay,y
    sta blinganimtick,x

    ;set our sprite's shadow position registers
    lda blingposx,y
    sta shadow_x,x
    lda blingposy,y
    sta shadow_y,x
    lda blingmsbx,y
    sta shadow_msb,x

    ;set new bling table position
    inc blingposidx,x
    lda blingposidx,x
    tay
    lda blingmsbx,y
    cmp #$ff ;ff in this table indicates the end of all our blings
    bne doblingx
    lda #$00
    sta blingposidx,x
    jmp blinggetframe
doblingx
    rts

;=============================================================================
;Updates the bling sprites
;=============================================================================
doblingupdatesprite  ;expects sprite in x

    ;get our current frame
    lda blinganimframe,x
    ;update sprite register for frame
    tay
    lda blinganimframes,y
    sta $07fa,x

    ;set sprite position from shadow regs
    lda shadow_x,x
    sta $d004,x
    lda shadow_y,x
    sta $d005,x

    
    ;figure out new msb
    lda shadow_msb,x
    bne setmsb
    ;clear msb
clrmsb
    lda clrmsbtab,x
    and $d010
    jmp msbdone
setmsb
    lda setmsbtab,x
    ora $d010
msbdone
    sta $d010

doblingspritex    
    rts

;=============================================================================
;Plots a single character column on the faderbar
;=============================================================================
plotfontcolumn ;expects char in a, offset from $0680 in x (0 to 39, this routine figures out which column of the font to plot
    pha
    txa
    and #$01
    cmp #$01
    bne plotfirstcolumn
    pla
    clc
    adc #$40
    jmp plotbytes
plotfirstcolumn
    pla
plotbytes
    sta $0680,x
    clc
    adc #$80
    sta $06a8,x
    rts

;=============================================================================
;Plots a row of text on the faderbar
;=============================================================================
plotbar
    lda fader_ptr
    sta plotbarloop+1
    sta pbl1+1
    lda fader_ptr+1
    sta plotbarloop+2
    sta pbl1+2
    ldx #$00
    ldy #$00
plotbarloop
    lda FADERBAR,y
    jsr plotfontcolumn
    inx
pbl1
    lda FADERBAR,y
    jsr plotfontcolumn
    inx
    iny
    cpy #$14
    bne plotbarloop
    rts
clearcolumn ;expects column index in x
    lda #$20
    sta $0680,x
    sta $06a8,x
    rts
;=============================================================================
; Utility routines - I had to move these around because of the fixed locations
; of the graphic data
;=============================================================================

    *=$0da0
;=============================================================================
;Updates teh position of the wiper sprite and clears text data from the screen
;=============================================================================
activewipe
    dec activewipe_tick
    bne activewipe_nochar
    lda #$01
    sta activewipe_tick
    jsr activewipe_movesprite
    inc activewipe_charstep
    lda activewipe_charstep
    cmp #$08
    bne activewipe_nochar
    lda #$00
    sta activewipe_charstep
    ldx activewipe_clridx
    jsr clearcolumn
    dec activewipe_clridx
    lda activewipe_clridx
    cmp #$ff
    beq activewipe_done
activewipe_nochar
    rts    

;=============================================================================
;resets the fader bar back to the starting state
;=============================================================================
activewipe_done
    lda #$ff
    sta activewipe_tick
    lda #$fd
    sta activewipe_charstep
    lda #$27
    sta activewipe_clridx
    lda #$58
    sta $d00e
    lda activewipe_msb+1
    ora #$80
    sta activewipe_msb+1
    jsr updatebarptr
    jsr plotbar
    rts

   
    *=$3780
;=============================================================================
;Updates the faderbar's text pointer to display the next row of text
;=============================================================================
updatebarptr
    lda fader_ptr
    clc
    adc #20
    sta fader_ptr
    bcc updatebarptr1
    inc fader_ptr+1
updatebarptr1
    lda fader_ptr
    sta updatebarptr2+1
    lda fader_ptr+1
    sta updatebarptr2+2
updatebarptr2
    lda $ffff
    cmp #$ff
    bne updatebarptrx
    lda #<FADERBAR
    sta fader_ptr
    lda #>FADERBAR
    sta fader_ptr+1
updatebarptrx
    rts
   
;=============================================================================
;Updates the sprite position for the faderbar
;=============================================================================
activewipe_movesprite
    dec $d00e
    lda $d00e
    cmp #$ff
    bne activewipe_nomsb
    lda activewipe_msb+1
    and #$7f
    sta activewipe_msb+1
activewipe_nomsb    
    rts

;=============================================================================
;NTSC-fixing routine and NTSC music player
;=============================================================================
ntsc
    lda #$0b
    sta NTSC0+1
    lda #$0a
    sta NTSC1+1
    lda #<ntscmusic
    sta NTSCMUSIC+1
    lda #>ntscmusic
    sta NTSCMUSIC+2
    rts
ntscmusic
    dec musictick
    bne ntscmusicx
    lda #$06
    sta musictick
    rts
ntscmusicx
    jsr $1003
    rts

