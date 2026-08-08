
*-----------------------------------------------------------
* Title      :
* Written by : Mega Drive Lab
* Date       :
* Description:
*-----------------------------------------------------------
*--------------------Register Usage-------------------------
 ;A0 FREE             |      D0 FREE
 ;A1 FREE             |      D1 FREE
 ;A2 FREE             |      D2 FREE
 ;A3 FREE             |      D3 FREE
 ;A4 FREE             |      D4 FREE
 ;A5 VDP_DATA_PORT    |      D5 FREE 
 ;A6 VDP_CONTROL_PORT |      D6 FREE 
 ;A7 SP               |      D7 FREE



;-----------------------Equates-----------------------------
    include "inc\equates.inc"     
    
;------------------------Macros-----------------------------    
    include "inc\macros.asm"
 




 
;-----------------------Vector table------------------------
    ORG    $0000    ;Origin (Memory mapping)
        
        dc.l    STACK_TOP   ;Stack pointer
        dc.l    START       ;Program start address    
    
 
 
 
;------------------------ENTRY POINT------------------------
    ORG    $0400
    
  ;SUBROUTINES
   
 
START:                       ; first instruction of program

    LEA VDP_DATA_PORT, a5       ;VDP_DATA_PORT_ADDRESS    -> a5
    LEA VDP_CONTROL_PORT, a6    ;VDP_CONTROL_PORT_ADDRESS -> a6

     
 ;INIT VDP (Set VDP reg -> VDP_CONTROL_PORT)

    MOVE.W #VDPREG_MODE1|%00000100, (a6)                  ;(b2 - (1) normal operation)
    MOVE.W #VDPREG_MODE2|%01000100, (a6)                  ;(b6 - (1) Enable display), (b2 - (1) Mega Drive (mode 5) display)
    MOVE.W #VDPREG_MODE3|%00000000, (a6)                  ;V/H scroll full screen
    MOVE.W #VDPREG_MODE4|%00000000, (a6)                  ;256 pixel (32 cell) wide mode (H32 mode)
    MOVE.W #VDPREG_BGCOL|%00000000, (a6)                  ;Background Colour: Palette 0, Colour 0
    MOVE.W #VDPREG_HRATE|%00000000, (a6)                  ;Number of scanlines between horizontal interrupts, Not used 
    MOVE.W #VDPREG_SIZE|%00000011, (a6)                   ;Plane A,B size H128*V32 cells
    MOVE.W #VDPREG_INCR|%00000010, (a6)                   ;Auto-Increment Value 2
    MOVE.W #VDPREG_WINX|%00000000, (a6)                   ;Window Plane Horizontal Position, Not used 
    MOVE.W #VDPREG_WINY|%10010000, (a6)                   ;Window Plane Vertical Position, (b7 - (1) Draw from VP to bottom edge of screen), (VP=16) in units of 8 pixels
    MOVE.W #VDPREG_PLANEA|(PLAINA_ADDR>>10), (a6)         ;Plain A VRAM base address 
    MOVE.W #VDPREG_PLANEB|(PLANEB_ADDR>>13), (a6)         ;Plain B VRAM base address 
    MOVE.W #VDPREG_WINDOW|(WINDOW_ADDR>>10), (a6)         ;Window Plane VRAM base address
    MOVE.W #VDPREG_SPRITE|(SPRITE_TABLE_ADDR>>9), (a6)    ;Sprite VRAM base address
    MOVE.W #VDPREG_HSCROLL|(HSCROLL_TABLE_ADDR>>10), (a6) ;Horizontal scroll table VRAM base address

 ;Clear VRAM
    SET_VRAM_WR_ADDR #$0000                ;VRAM write command
    MOVEQ #0, d1                           ;Clear d1
    MOVE.W #(VRAM_SIZE/4)-1, d2            ;Loop counter = number of long words - 1
.ClearVram                                 ;VRAM clear loop
    MOVE.L d1, (a5)                        ;Write 0 to VDP data port
    DBF d2, .ClearVram                     ;Repeat until d2 = -1

 ;Clear CRAM
    SET_CRAM_WR_ADDR #$00                  ;CRAM write command
    MOVE.W #(CRAM_SIZE/4)-1, d2            ;d2 = loop counter
.ClearCram                                 ;CRAM clear loop
    MOVE.L d1, (a5)                        ;Write 0 to VDP data port
    DBF d2, .ClearCram                     ;Repeat until d2 = -1

 ;Clear VSRAM
    SET_VSRAM_WR_ADDR #$00                 ;VSRAM write command
    MOVE.W #(VSRAM_SIZE/4)-1, d2           ;d2 = loop counter
.ClearVSram                                ;VSRAM clear loop
    MOVE.L d1, (a5)                        ;Write 0 to VDP data port
    DBF d2, .ClearVSram                    ;Repeat until d2 = -1

 ;Writing data to VRAM
    SET_VRAM_WR_ADDR #$0000                ;VRAM write command
    LEA EMOJI_TILE, a0                     ;Load data address into a0
    MOVE.W #(EMOJI_TILE_SIZE / 4)-1, d1    ;d1 = loop counter
.VramWriteLoop                             ;VRAM write loop
    MOVE.L (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .VramWriteLoop                 ;Repeat until d1 = -1
  

MAIN_LOOP:
;------------------------MAIN loop start--------------------


 ;Writing data to ÑRAM
    LEA PALETTE_GRADIENT, a0                    ;Load data address into a0
    MOVE.W #(PALETTE_GRADIENT_SIZE / 2)-1, d1   ;d1 = loop counter
.loop
    SET_CRAM_WR_ADDR #18                        ;Write to CRAM, color 9
    MOVE.W (a0)+, (a5)                          ;Send data to VDP
    DELAY #20
    DBF d1, .loop                               ;Repeat until d1 = -1


    
   



  ;CODE

;------------------------MAIN loop end----------------------
    BRA MAIN_LOOP       ;Branch Always

  ;SUBROUTINES



;------------------------Tiles------------------------------

EMOJI_TILE:
    dc.l    $00999900
    dc.l    $09999990
    dc.l    $99299299
    dc.l    $99999999
    dc.l    $92999929
    dc.l    $99222299
    dc.l    $09999990
    dc.l    $00999900
EMOJI_TILE_END:
EMOJI_TILE_SIZE EQU (EMOJI_TILE_END-EMOJI_TILE)

PALETTE_GRADIENT:
    dc.w %0000000000001110
    dc.w %0000000000001110
    dc.w %0000000000101110
    dc.w %0000000000101110
    dc.w %0000000000101110
    dc.w %0000000001001110
    dc.w %0000000001001110
    dc.w %0000000001001110
    dc.w %0000000001101110
    dc.w %0000000001101110
    dc.w %0000000001101110
    dc.w %0000000010001110
    dc.w %0000000010001110
    dc.w %0000000010001110
    dc.w %0000000010101110
    dc.w %0000000010101110
    dc.w %0000000010101110
    dc.w %0000000011001110
    dc.w %0000000011001110
    dc.w %0000000011001110
    dc.w %0000000011101110
    dc.w %0000000011101110
    dc.w %0000000011101110
    dc.w %0000000011101100
    dc.w %0000000011101100
    dc.w %0000000011101100
    dc.w %0000000011101010
    dc.w %0000000011101010
    dc.w %0000000011101010
    dc.w %0000000011101000
    dc.w %0000000011101000
    dc.w %0000000011101000
    dc.w %0000000011101000
    dc.w %0000000011100110
    dc.w %0000000011100110
    dc.w %0000000011100110
    dc.w %0000000011100100
    dc.w %0000000011100100
    dc.w %0000000011100100
    dc.w %0000000011100010
    dc.w %0000000011100010
    dc.w %0000000011100010
    dc.w %0000000011100000
    dc.w %0000000011100000
    dc.w %0000000011100000
    dc.w %0000001011100000
    dc.w %0000001011100000
    dc.w %0000001011100000
    dc.w %0000010011100000
    dc.w %0000010011100000
    dc.w %0000010011100000
    dc.w %0000011011100000
    dc.w %0000011011100000
    dc.w %0000011011100000
    dc.w %0000100011100000
    dc.w %0000100011100000
    dc.w %0000100011100000
    dc.w %0000101011100000
    dc.w %0000101011100000
    dc.w %0000101011100000
    dc.w %0000110011100000
    dc.w %0000110011100000
    dc.w %0000110011100000
    dc.w %0000111011100000
    dc.w %0000111011100000
    dc.w %0000111011100000
    dc.w %0000111011000000
    dc.w %0000111011000000
    dc.w %0000111011000000
    dc.w %0000111010100000
    dc.w %0000111010100000
    dc.w %0000111010100000
    dc.w %0000111010000000
    dc.w %0000111010000000
    dc.w %0000111010000000
    dc.w %0000111001100000
    dc.w %0000111001100000
    dc.w %0000111001100000
    dc.w %0000111001000000
    dc.w %0000111001000000
    dc.w %0000111001000000
    dc.w %0000111000100000
    dc.w %0000111000100000
    dc.w %0000111000100000
    dc.w %0000111000000000
    dc.w %0000111000000000
    dc.w %0000111000000000
    dc.w %0000111000000010
    dc.w %0000111000000010
    dc.w %0000111000000010
    dc.w %0000111000000100
    dc.w %0000111000000100
    dc.w %0000111000000100
    dc.w %0000111000000110
    dc.w %0000111000000110
    dc.w %0000111000000110
    dc.w %0000111000000110
    dc.w %0000111000001000
    dc.w %0000111000001000
    dc.w %0000111000001000
    dc.w %0000111000001010
    dc.w %0000111000001010
    dc.w %0000111000001010
    dc.w %0000111000001100
    dc.w %0000111000001100
    dc.w %0000111000001100
    dc.w %0000111000001110
    dc.w %0000111000001110
    dc.w %0000111000001110
    dc.w %0000110000001110
    dc.w %0000110000001110
    dc.w %0000110000001110
    dc.w %0000101000001110
    dc.w %0000101000001110
    dc.w %0000101000001110
    dc.w %0000100000001110
    dc.w %0000100000001110
    dc.w %0000100000001110
    dc.w %0000011000001110
    dc.w %0000011000001110
    dc.w %0000011000001110
    dc.w %0000010000001110
    dc.w %0000010000001110
    dc.w %0000010000001110
    dc.w %0000001000001110
    dc.w %0000001000001110
    dc.w %0000001000001110
    dc.w %0000000000001110
PALETTE_GRADIENT_END:
PALETTE_GRADIENT_SIZE EQU (PALETTE_GRADIENT_END-PALETTE_GRADIENT)
  
  
        END    START        ; last line of source








*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
