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

;SET_VRAM_WR_ADDR #$addr ($FFFF max) (d0)
;   0000_0000 0000_0000 A15A14A13A12_A11A10A9A8 A7A6A5A4_A3A2A1A0 ->
;-> 01A13A12_A11A10A9A8 A7A6A5A4_A3A2A1A0 0000_0000 0000_00A14A15       
SET_VRAM_WR_ADDR MACRO      ;VRAM write command
    MOVE.L \1, d0           ;Loading address into d0
    ROL.L #2, d0            ;Rotate left by 2 (Long)
    ADDQ.W #1, d0           ;Add 1 to d0
    ROR.W #2, d0            ;Rotate right by 2 (Word)
    SWAP d0                 ;Swap d0 words
    MOVE.L d0, (a6)         ;Write to VDP Control Port
    ENDM
    
;SET_CRAM_WR_ADDR #$addr ($7F max) (d0)
;   0000_0000 0000_0000 0000_0000 0A6A5A4_A3A1A0 ->
;-> 1100_0000 0A6A5A4_A3A2A1A0 0000_0000 0000_0000
SET_CRAM_WR_ADDR MACRO          ;CRAM write command
    MOVE.L \1, d0               ;Loading address into D0
    ORI.W #$C000, d0            ;Set bits 30,31 for CRAM write command
    SWAP d0                     ;Swap D0 words
    MOVE.L d0, (a6)             ;Write to VDP Control Port 
    ENDM    
    
;SET_VSRAM_WR_ADDR #$addr ($4F max) (d0)
;   0000_0000 0000_0000 0000_0000 0A6A5A4_A3A1A0 ->
;-> 0100_0000 0A6A5A4_A3A2A1A0 0000_0000 0001_0000
SET_VSRAM_WR_ADDR MACRO         ;VSRAM write command
    MOVE.L \1, d0               ;Loading address into D0
    SWAP d0                     ;Swap D0 words
    ORI.L #$40000010, d0        ;Set bits 30,4 for VSRAM write command
    MOVE.L d0, (a6)             ;Write to VDP Control Port 
    ENDM      



   
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
  
 ;Writing data to CRAM
    SET_CRAM_WR_ADDR #18                   ;Write to CRAM, color 9
;           0000BBB0GGG0RRR0
   MOVE.W #%0000000010001110, (a5)         ;Send data to VDP
   
   
   
MAIN_LOOP:
;------------------------MAIN loop start--------------------
 
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
  
  
        END    START        ; last line of source






*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
