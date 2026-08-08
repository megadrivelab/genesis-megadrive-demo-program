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

;Equates
    include "inc\equates.inc"     
    
;Macros  
    include "inc\macros.asm"
 
 
;-----------------------Vector table------------------------
    ORG    $0000    ;Origin (Memory mapping)
        
        dc.l    STACK_TOP   ;Stack pointer
        dc.l    START       ;Program start address    

    ORG    $0100
    
        dc.l    'SEGA'      ;TMSS 


;------------------------ENTRY POINT------------------------
    ORG    $0400
    
   
START:                        ; first instruction of program

;VDP unlock
    MOVE.B $00A10001, d0      ;Read hardware version
    ANDI.B #$0F, d0           ;Mask version bits (D3-D0)
    BEQ .Skip                 ;Skip if revision 0
    MOVE.L #'SEGA', $00A14000 ;Unlock VDP
.Skip 

;Hardware setup        
    LEA VDP_DATA_PORT, a5     ;VDP_DATA_PORT_ADDRESS    -> a5
    LEA VDP_CONTROL_PORT, a6  ;VDP_CONTROL_PORT_ADDRESS -> a6
    VDP_INIT                  ;Initialize VDP and load initial data into VRAM


MAIN_LOOP:
;========================MAIN loop start====================

       ;Update HScroll
    DELAY #20                              ;Wait 20ms
    SUBQ.W #1, d7                          ;Decrement scroll counter
    SET_VRAM_WR_ADDR #HSCROLL_TABLE_ADDR   ;Set VDP write to HScroll table  
    MOVE.L d7, (a5)                        ;Write scroll value to VDP data port       



;========================MAIN loop end======================
    BRA MAIN_LOOP       ;Branch Always
















;-------------------------DATA------------------------------

;Palettes
PALETTEDATA:
    include "data\palettedata.asm"
PALETTEDATA_END:
PALETTEDATA_SIZE EQU (PALETTEDATA_END-PALETTEDATA)

;Tiles
TILEDATA:
    include "data\tiledata.asm"   
TILEDATA_END:
TILEDATA_SIZE EQU (TILEDATA_END-TILEDATA)

;Tilemaps: B (128*28) -> A (128*28) -> Window (32*28)
MAPDATA:
    include "data\mapdata.asm"   
PLANE_B_TABLE_SIZE EQU (128*28*2)       ;128*28 tiles, 2 bytes each
PLANE_A_TABLE_SIZE EQU (128*28*2)       ;128*28 tiles, 2 bytes each
WINDOW_TABLE_SIZE EQU (32*28*2)         ;32*28 tiles, 2 bytes each


        END    START        ; last line of source
















*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
