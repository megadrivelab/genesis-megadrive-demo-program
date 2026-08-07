;-----------------------Equates-----------------------------
RAM_SIZE            EQU     $00010000               ;64KB RAM size
RAM_BASE            EQU     $00FF0000               ;RAM base address
STACK_TOP           EQU     RAM_SIZE+RAM_BASE       ;Stack top address (end of RAM)
VDP_DATA_PORT       EQU     $C00000                 ;VDP data port address
VDP_CONTROL_PORT    EQU     $C00004                 ;VDP control port address

;VDP
VDPREG_MODE1        EQU     $8000                   ;Mode register 1
VDPREG_MODE2        EQU     $8100                   ; Mode register #2
VDPREG_MODE3        EQU     $8B00                   ; Mode register #3
VDPREG_MODE4        EQU     $8C00                   ; Mode register #4

VDPREG_PLANEA       EQU     $8200                   ; Plane A table address
VDPREG_PLANEB       EQU     $8400                   ; Plane B table address
VDPREG_SPRITE       EQU     $8500                   ; Sprite table address
VDPREG_WINDOW       EQU     $8300                   ; Window table address
VDPREG_HSCROLL      EQU     $8D00                   ; HScroll table address

VDPREG_SIZE         EQU     $9000                   ; Plane A and B size
VDPREG_WINX         EQU     $9100                   ; Window X split position
VDPREG_WINY         EQU     $9200                   ; Window Y split position
VDPREG_INCR         EQU     $8F00                   ; Autoincrement
VDPREG_BGCOL        EQU     $8700                   ; Background color
VDPREG_HRATE        EQU     $8A00                   ; HBlank interrupt rate

PLAINA_ADDR         EQU     $A000                   ;Plane A VRAM base address
PLANEB_ADDR         EQU     $C000                   ;Plane B VRAM base address
WINDOW_ADDR         EQU     $E000                   ;Window plain VRAM base address
SPRITE_TABLE_ADDR   EQU     $E800                   ;Sprite table VRAM base address
HSCROLL_TABLE_ADDR  EQU     $F000                   ;Hscroll table VRAM base address
    
VRAM_SIZE           EQU     65536                   ;VRAM size
CRAM_SIZE           EQU     128                     ;CRAM size
VSRAM_SIZE          EQU     80                      ;VSRAM size