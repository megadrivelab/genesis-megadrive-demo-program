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

    ORG    $0070            ;Level 4 Interrupt Autovector (H-INT)

        dc.l    HBlankHandler

    ORG    $0100
    
        dc.l    'SEGA'      ;TMSS 


;------------------------ENTRY POINT------------------------
    ORG    $0400
    
   
START:                        ; first instruction of program

    TMSS_UNLOCK               ;Unlock VDP if needed

;Hardware setup        
    LEA VDP_DATA_PORT, a5     ;VDP_DATA_PORT_ADDRESS    -> a5
    LEA VDP_CONTROL_PORT, a6  ;VDP_CONTROL_PORT_ADDRESS -> a6
    VDP_INIT                  ;Initialize VDP and load initial data into VRAM
    MOVE.W #$2300, sr         ;Vblank, Hblank interrupt enable (interrupt priority = 3)

MAIN_LOOP:
;========================MAIN loop start====================

 

;========================MAIN loop end======================
    BRA MAIN_LOOP       ;Branch Always



;------------------Horizontal Interrupt Handler-------------
HBlankHandler:

    ;Writing data to CRAM
    SET_CRAM_WR_ADDR #$00                  ;Write to CRAM
    LEA PALETTEDATA, a0                    ;Load data address into a0
    MOVE.W #(PALETTEDATA_SIZE / 2)-1, d1   ;d1 = loop counter
.CramWriteLoop
    MOVE.W (a0)+, (a5)                     ;Send data to VDP
    DBF d1, .CramWriteLoop                 ;Repeat until d1 = -1
    RTE








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
