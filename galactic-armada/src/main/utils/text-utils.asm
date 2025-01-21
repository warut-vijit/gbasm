INCLUDE "src/main/utils/macros/text-macros.inc"

SECTION "Text", ROM0

; 8-bit ASCII font from https://opengameart.org/content/8x8-ascii-bitmap-font-with-c-source
textFontTileData: INCBIN "src/generated/backgrounds/text-font.2bpp"
textFontTileDataEnd:
; ANCHOR: load-text-font

textBoxTileData: INCBIN "src/generated/backgrounds/text-box.2bpp"
textBoxTileDataEnd:
DEF textBoxTiles = 9

; textBoxTileMap: INCBIN "src/generated/backgrounds/text-box.tilemap"
; textBoxTileMapEnd:
textBoxTileMap:
db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $02
db $03, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1A, $05
db $03, $1B, $1C, $1D, $1E, $1F, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2A, $2B, $2C, $05
db $03, $2D, $2E, $2F, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $3E, $05
db $03, $3F, $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $05
db $06, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $08
textBoxTileMapEnd:

LoadTextFontIntoVRAM::
    ; Copy the tile data
    ld de, textFontTileData ; de contains the address where data will be copied from;
    ld hl, $8000; hl contains the address where data will be copied to;
    ld bc, textFontTileDataEnd - textFontTileData ; bc contains how many bytes we have to copy.
    jp CopyDEintoMemoryAtHL
    
; ANCHOR_END: load-text-font

; ANCHOR: draw-text-tiles-live
DrawTextBoxText::
    ; Writes 72 characters pointed to by de to the first text box line.
    ; Push number of written characters
    ld a, 0
    ; Push pointer to next tile data to the stack
    ld bc, $8000 + textBoxTiles * 16
    .CopyCharLoop
    push af
    push bc 

    ld hl, textFontTileData
    ld a, [de] ; a has the current character ascii code
    sub a, 32
    inc de
    cp 255 - 32 ; check for end-of-string token
    jr nz, DrawTextBoxText.StringNotEnded
        dec de
        ld a, 0
    .StringNotEnded
    swap a ; a has a[4:7]a[0:3]
    ld b, a ; b has a[4:7]a[0:3]
    and a, $f0 ; a has a[4:7]0000
    ld c, a
    ld a, b ; a has a[4:7]a[0:3]
    and a, $0f ; a has 0000a[0:3]
    ld b, a
    add hl, bc

    pop bc
    rept 16
        ld a, [hli]
        ld [bc], a
        inc bc 
    endr

    pop af
    inc a
    cp a, 72
    jr nz, DrawTextBoxText.CopyCharLoop

    ret
; ANCHOR_END: draw-text-tiles-live

; ANCHOR: draw-text-tiles
DrawTextTilesLoop::

    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    sub a, 32
    ld [de], a

    inc hl
    inc de

    ; move to the next character and next background tile
    jp DrawTextTilesLoop
; ANCHOR_END: draw-text-tiles

; ANCHOR: typewriter-effect
DrawText_WithTypewriterEffect::

    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; Wait a small amount of time
    ; Save our count in this variable
    ld a, 3
    ld [wVBlankCount], a

    ; Call our function that performs the code
    call WaitForVBlankFunction
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
    ; Check for the end of string character 255
    ld a, [hl]
    cp 255
    ret z

    ; Write the current character (in hl) to the address
    ; on the tilemap (in de)
    ld a, [hl]
    ld [de], a

    ; move to the next character and next background tile
    inc hl
    inc de

    jp DrawText_WithTypewriterEffect
; ANCHOR_END: typewriter-effect

; ANCHOR: draw-text-box
DrawTextBox::
    
    ; Copy the tile data
    ld de, textBoxTileData ; de contains the address where data will be copied from;
    ; Because of the text font, add an offset of 2 bytes for every font tile.
    ld hl, $8000 ; hl contains the address where data will be copied to;
    ld bc, textBoxTileDataEnd - textBoxTileData ; bc contains how many bytes we have to copy.
    call CopyDEintoMemoryAtHL

    ; Copy the tilemap
    ld de, textBoxTileMap
    ld hl, $9980
    ld bc, textBoxTileMapEnd - textBoxTileMap
    jp CopyTextBoxintoTileMap

; ANCHOR_END: draw-text-box
