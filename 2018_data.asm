    *=$d00
;=============================================================================
;Standard sine table - I had to limit the peak of this due to screen size
;=============================================================================
sintab
        .byte $01, $01, $01, $01, $02, $02, $03, $04, $05, $05, $06, $07, $07, $08, $08, $08
        .byte $08, $08, $08, $08, $07, $07, $06, $05, $04, $04, $03, $02, $02, $01, $01, $01
;=============================================================================
;FLD Data
; fld size fields are the current height of the given FLD
; fld tick fields are standard tickers (dec to 0, do thing, reset)
; fld idx fields are the indices into the sine tab for each fld
;=============================================================================
fld_1_size      
    .byte $04
fld_2_size      
    .byte $04
fld_3_size      
    .byte $04

fldtick_1
    .byte $04
fldtick_2       
    .byte $04
fldtick_3       
    .byte $04

fldidx_1        
    .byte $00
fldidx_2        
    .byte $04
fldidx_3        
    .byte $08

;=============================================================================
;Bling sprite registers
; My stock bling engine supports 4 sprites, so there's some extra data here
; blinganimtick is the ticker for each bling sprite
; blinganimframe is a pointer to the current animation frame (in table) index
;                for each sprite
; shadow regs are used so we can add based on the FLD bounce
; posidx table is so each sprite can be in a different index into the bling data
; delay is how long after a given bling to wait to do another
;=============================================================================
blinganimtick
    .byte $04,$ff,$ff,$ff

;each sprite's own frame
blinganimframe
    .byte $00,$00,$00,$00

blinganimframes
    .byte $39,$3c,$3d,$3f,$3e,$3f,$3d,$3c,$39

;sprite shadow regs
shadow_x      .byte $00,$ff,$ff,$ff
shadow_y      .byte $00,$ff,$ff,$ff
shadow_msb    .byte $00,$ff,$ff,$ff

blingposidx ;where each sprite is in the pos table
    .byte $00,$ff,$ff,$ff

;the x/y pos of each bling animation - base is 50y,20x
blingposx
    .byte 144, 33,  60, 106, (276+20)-255, 214,  78, 186, $ff
blingmsbx
    .byte   0,            1,   0,   0,            1,   0,   0,  0, $ff
blingposy
    .byte  64,           78,  67, 140,           26,  62, 112, 132, $ff

;the delay after each bling
blingdelay
    .byte $14, $2a, $20, $19, $40,$2f,$0e, $33, $ff
;=============================================================================
;Setmsb and clrmsb tables are the msb and/or values for each sprite
;=============================================================================
setmsbtab  
    .byte $04,$08,$10,$20
clrmsbtab
    .byte $fc,$f7,$ef,$cf

;=============================================================================
;These regs control the fader/wipe bar
; ticker is a ticker
; clridx is which column on screen we're clearing
; charstep is used to step the clearing to the back of the sprite's data
; fader_ptr is used to keep track of what we're displaying after the wipe
;=============================================================================
activewipe_tick
    .byte $ff
activewipe_clridx
    .byte $27
activewipe_charstep
    .byte $fd
fader_ptr
    .byte <FADERBAR, >FADERBAR
;=============================================================================
;music ticker when in NTSC mode
;=============================================================================
musictick
    .byte $05

;=============================================================================
;Color pulse data for pulse bar
;=============================================================================
colortable
    .byte $0b,$0b,$06,$04,$0e,$03,$0d,$07,$01
    .byte $01,$01,$07,$0d,$03,$0e,$04,$06,$0b

colortick   .byte $04
coloridx    .byte $00

scrolltick  .byte $04
scrollflip  .byte $00

    *=$e40 ;blank sprite
    .repeat $40,0

    *=$e80 ;wipe/fader-bar sprite and scroller endsprites
    .binary "masksprites.bin"

    *=$f00 ;bling animation
    .binary "blingsprites.bin"

    *=$1000 ;the music
    .binary "feedsixchickens.bin"

LOGOSCN ;screen data for logo ($0400-)
    .binary "logo_scndata.bin"

LOGOCOL ;color data for logo ($d800-)
    .binary "logo_colors.bin"

    *=$2000 ;bitplane data for logo
    .binary "2018.map"
    
    *=$32c0 
SCROLLTEXT
    .screen "    well here it is 2019, and i'm just wrapping up this entry for "
    .screen "the csdb intro competition 2018...  guess this is as good a time "
    .screen "as any to get some basic information out of the way.  dloc has "
    .screen "become somewhat of a one-man show over the past few years, time "
    .screen "has a way of moving on and people get into new things. "
    .screen "fortunately, there are great tools "
    .screen "available to lighten the workload.  the logo above, for instance, was "
    .screen "created with multipaint 2018.  the music "
    .screen "you're hearing is a cover of hellrazor's 'feed your chicken'"
    .screen ", produced with goattracker.  the 2x2 font "
    .screen "was created with cuneiform, which fortunately runs under wine on linux.    "
    .screen "if you're interested in the history of the ntsc side of the scene and would "
    .screen "like to watch some video caps of demos from there, check out "
    .screen "http://commodoresixtyfour.com.   to contact dloc, email me at sixofdloc@gmail.com "
    .screen "    greets to "
    .screen "all of our friends in the pal and ntsc scenes.  thank you all for 33 years of "
    .screen "good times and friendship, it's been a blast!  "
    .screen "                six/dloc out                                                  "  
    .byte $ff

    *=$3800 ; the 2x2 font for the scroller and faderbar
    .binary "2x2font.bin"

    *=$1e31
FADERBAR    ;01234567890123456789
    .screen "dark lords of chaos "
    .screen " presents our entry "
    .screen "    for the 2018    "
    .screen "  csdb intro compo  "
    .screen "code/music/graphics "
    .screen "    by six/dloc     "
    .screen "                    "
    .screen "     greets to:     "
    .screen "macbeth, dw, dokken "
    .screen "  burning horizon   "
    .screen "  the diskmaster    "
    .screen "  magervalp, k3ys   "
    .screen "  elwix, wrong way  "
    .screen "the phantom, jbevren"
    .screen "moloch, mermaid, jp "
    .screen "pro-hack, hellraiser"
    .screen " the ranger, freeze "
    .screen "merlyn, dragos, v12 "
    .screen "  hellion, demonger "
    .screen "nafcom and swo crew "
    .screen "                    "
    .byte $ff,$ff,$ff,$ff

