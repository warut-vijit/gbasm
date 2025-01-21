; ANCHOR: memory-utils
SECTION "MemoryUtilsSection", ROM0

CopyDEintoMemoryAtHL::
    ld a, [de]
    ld [hli], a
    inc de
    dec bc
    ld a, b
    or c
    jp nz, CopyDEintoMemoryAtHL ; Jump to CopyTiles if the last operation had a non zero result.
    ret

CopyConstDintoScreen::
    ld a, d
    ld [hli], a
    ; if a row has been completed (hl ends in 14), move to column 0 of next row
    ld a, l
    and a, $1F
    xor a, $14
    ; flip the 32 bit, 16 bit, and 4 bit
    jr nz, CopyConstDintoScreen.EndLineWrap
    ld a, l
    add a, $000C
    ld l, a
    ; carry the bit into h
    jp nc, CopyConstDintoScreen.EndLineWrap
    inc h
.EndLineWrap
    dec bc
    ld a, b
    or a, c
    jp nz, CopyConstDintoScreen
    ret

CopyDEintoScreen::
; Copy one screen of tiles into first twenty tiles of each row.
    ld a, [de]
    ld [hli], a
    ; if a row has been completed (hl ends in 14), move to column 0 of next row
    ld a, l
    and a, $1F
    xor a, $14
    ; flip the 32 bit, 16 bit, and 4 bit
    jr nz, CopyDEintoScreen.EndLineWrap
    ld a, l
    add a, $000C
    ld l, a
    ; carry the bit into h
    jp nc, CopyDEintoScreen.EndLineWrap
    inc h
.EndLineWrap
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyDEintoScreen
    ret
; ANCHOR_END: memory-utils

CopyTextBoxintoTileMap::
; Copy one screen of tiles into first twenty tiles of each row.
    ld a, [de]
    ld [hli], a
    ; if a row has been completed (hl ends in 14), move to column 0 of next row
    ld a, l
    and a, $1F
    xor a, $14
    ; flip the 32 bit, 16 bit, and 4 bit
    jr nz, CopyTextBoxintoTileMap.EndLineWrap
    ld a, l
    add a, $000C
    ld l, a
    ; carry the bit into h
    jp nc, CopyTextBoxintoTileMap.EndLineWrap
    inc h
.EndLineWrap
    inc de
    dec bc
    ld a, b
    or a, c
    jp nz, CopyTextBoxintoTileMap
    ret
; ANCHOR_END: memory-utils

