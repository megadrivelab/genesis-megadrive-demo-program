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
  
;DELAY #ms (max ~10 000 000ms) (d0)
DELAY MACRO                     ;Delay for milliseconds
    MOVE.L \1*425, d0           ;Load loop counter (425 cycles ~ 1ms)
.delayLoop\@
    SUBQ.L #1, d0               ;Decrement counter
    BNE .delayLoop\@            ;Branch if not zero
    ENDM


;VDP_INIT (d0,d1,d2)(a0)
;Initialize VDP and load initial data into VRAM    
VDP_INIT MACRO
 ;(Set VDP reg -> VDP_CONTROL_PORT)
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
    MOVE.W #VDPREG_PLANEA|(PLANEA_ADDR>>10), (a6)         ;Plane A VRAM base address 
    MOVE.W #VDPREG_PLANEB|(PLANEB_ADDR>>13), (a6)         ;Plane B VRAM base address 
    MOVE.W #VDPREG_WINDOW|(WINDOW_ADDR>>10), (a6)         ;Window Plane VRAM base address
    MOVE.W #VDPREG_SPRITE|(SPRITE_TABLE_ADDR>>9), (a6)    ;Sprite VRAM base address
    MOVE.W #VDPREG_HSCROLL|(HSCROLL_TABLE_ADDR>>10), (a6) ;Horizontal scroll table VRAM base address

                            ;Clear VDP memory
                            
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

                            ;Writing data
                            
 ;Writing data to ÑRAM
    SET_CRAM_WR_ADDR #$00                  ;Write to CRAM
    LEA PALETTEDATA, a0                    ;Load data address into a0
    MOVE.W #(PALETTEDATA_SIZE / 2)-1, d1   ;d1 = loop counter
.CramWriteLoop
    MOVE.W (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .CramWriteLoop                 ;Repeat until d1 = -1


 ;Writing tile data to VRAM
    SET_VRAM_WR_ADDR #$0000                ;VRAM write command
    LEA TILEDATA, a0                       ;Load data address into a0
    MOVE.W #(TILEDATA_SIZE / 4)-1, d1      ;d1 = loop counter
.TiledataWriteLoop                         ;VRAM write loop
    MOVE.L (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .TiledataWriteLoop             ;Repeat until d1 = -1

 ;Writing tilemaps to VRAM
    SET_VRAM_WR_ADDR #PLANEB_ADDR          ;VRAM write command for Plane B name table
    LEA MAPDATA, a0                        ;Load data address into a0
    MOVE.W #(PLANE_B_TABLE_SIZE / 4)-1, d1 ;d1 = loop counter
.PlaneBWriteLoop                           ;VRAM write loop
    MOVE.L (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .PlaneBWriteLoop               ;Repeat until d1 = -1
 
    SET_VRAM_WR_ADDR #PLANEA_ADDR          ;VRAM write command for Plane A name table    
    MOVE.W #(PLANE_A_TABLE_SIZE / 4)-1, d1 ;d1 = loop counter
.PlaneAWriteLoop                           ;VRAM write loop
    MOVE.L (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .PlaneAWriteLoop               ;Repeat until d1 = -1 

    SET_VRAM_WR_ADDR #WINDOW_ADDR          ;VRAM write command  for Window name table  
    MOVE.W #(WINDOW_TABLE_SIZE / 4)-1, d1  ;d1 = loop counter
.WindowPlaneWriteLoop                      ;VRAM write loop
    MOVE.L (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .WindowPlaneWriteLoop          ;Repeat until d1 = -1 

 
    ENDM 
    














    
    