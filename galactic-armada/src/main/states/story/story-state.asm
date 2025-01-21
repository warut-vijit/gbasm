; ANCHOR: init-story-state
INCLUDE "src/main/utils/hardware.inc"
INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "StoryStateASM", ROM0

bgScreenTileData: INCBIN "src/generated/backgrounds/school_library_1_hanako.2bpp"
bgScreenTileDataEnd:

bgScreenTileMap: INCBIN "src/generated/backgrounds/school_library_1_hanako.tilemap"
bgScreenTileMapEnd:

HanakoTalking::  db "\"Hanako now talks translucently  in her text box color.\"", 255

InitStoryState::
    ld de, paletteHanako
    ld b, 0
    call CopyDEintoPaletteB

    ld de, paletteBackground
    ld b, 1
    call CopyDEintoPaletteB

    call DrawBgScreen

    call DrawTextBox

    ld de, HanakoTalking
    call DrawTextBoxText

    ; Turn the LCD on
    ld a, LCDCF_ON|LCDCF_BGON|LCDCF_OBJON|LCDCF_OBJ16|LCDCF_BG8000
    ld [rLCDC], a

    ret
; ANCHOR_END: init-story-state

; ANCHOR: draw-bg-screen
DrawBgScreen::
    
    ld a, $01
    ld [rVBK], a
    ; Copy the tile data
    ld de, bgScreenTileData ; de contains the address where data will be copied from;
    ld hl, $8000
    ld bc, bgScreenTileDataEnd - bgScreenTileData ; bc contains how many bytes we have to copy.
    call CopyDEintoMemoryAtHL

    ; BG Map Attributes contains
    ; 7        6      5      4 3    2 1 0
    ; priority Y-flip X-flip   bank palette
    ; Set BG map attributes to bank 1, palette 1
    ; NOTE: VRAM writing to bank 1
    ld d, %00001001
    ld hl, $9800
    ld bc, bgScreenTileMapEnd - bgScreenTileMap
    call CopyConstDintoScreen
    ld a, $00
    ld [rVBK], a

    ; Copy the tilemap
    ld de, bgScreenTileMap
    ld hl, $9800
    ld bc, bgScreenTileMapEnd - bgScreenTileMap
    jp CopyDEintoScreen

; ANCHOR_END: draw-bg-screen

; ANCHOR: story-screen-data
Story: 
    .Line1 db "the galatic empire", 255
    .Line2 db "rules the galaxy", 255
    .Line3 db "with an iron", 255
    .Line4 db "fist.", 255
    .Line5 db "the rebel force", 255
    .Line6 db "remain hopeful of", 255
    .Line7 db "freedoms light", 255
    
; ANCHOR_END: story-screen-data
; ANCHOR: story-screen-page1
UpdateStoryState::
    jr UpdateStoryState

    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9821
    ld hl, Story.Line1
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9841
    ld hl, Story.Line2
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9861
    ld hl, Story.Line3
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9881
    ld hl, Story.Line4
    call DrawText_WithTypewriterEffect

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Wait for A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the passed value into the variable: mWaitKey
    ; The WaitForKeyFunction always checks against this vriable
    ld a, PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; ANCHOR_END: story-screen-page1


    call ClearBackground


; ANCHOR: story-screen-page2
    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9821
    ld hl, Story.Line5
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $9861
    ld hl, Story.Line6
    call DrawText_WithTypewriterEffect


    ; Call Our function that typewrites text onto background/window tiles
    ld de, $98A1
    ld hl, Story.Line7
    call DrawText_WithTypewriterEffect


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Wait for A
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ; Save the passed value into the variable: mWaitKey
    ; The WaitForKeyFunction always checks against this vriable
    ld a, PADF_A
    ld [mWaitKey], a

    call WaitForKeyFunction
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
; ANCHOR_END: story-screen-page2

; ANCHOR: story-screen-end
    ld a, 2
    ld [wGameState],a
    jp NextGameState
; ANCHOR_END: story-screen-end
