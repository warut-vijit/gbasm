INCLUDE "src/main/utils/hardware.inc"

SECTION "Palette", ROM0

; 5 bits of red, 5 bits of green, 5 bits of blue, empty
;   xbbbbbgggggrrrrr
; Each color is two bytes, each character's palette is 8 bytes

; Background #cfb27f

paletteBackground::
    dw %0101101111111111
    dw %0011111011011001
    dw %0001110101101100
    dw %0000110010100110
paletteBackgroundEnd:

; Hisao #629276

paletteHisao::
    dw %0101011101110010
    dw %0011101001001100
    dw %0001110100100110
    dw %0000110010000011
paletteHisaoEnd:

; Hanako #897cbf

paletteHanako::
    dw %0111111011011001
    dw %0101110111110001
    dw %0010110011101000
    dw %0001010001100100
paletteHanakoEnd:

; Emi #ff8d7c

paletteEmi::
    dw %0101101100111111
    dw %0011111000111111
    dw %0001110100001111
    dw %0000110010000111
paletteEmiEnd:

; Rin #b14343

paletteRin::
    dw %0011000110011111
    dw %0010000100010110
    dw %0001000010001011
    dw %0000100001000101
paletteRinEnd:

; Lilly #f9eaa0

paletteLilly::
    dw %0111101111111111
    dw %0101001110111111
    dw %0010100111001111
    dw %0001010011100111
paletteLillyEnd:

; Shizune #72adee

paletteShizune::
    dw %0111111111110101
    dw %0111011010101110
    dw %0011100101000111
    dw %0001110010100011
paletteShizuneEnd:

; Misha #ff809f

paletteMisha::
    dw %0111001100011111
    dw %0100111000011111
    dw %0010010100001111
    dw %0001000010000111
paletteMishaEnd:

; Kenji #cc7c2a

paletteKenji::
    dw %0001111011011111
    dw %0001010111111001
    dw %0000100011101100
    dw %0000010001100110
paletteKenjiEnd:

; Mutou #ffffff

paletteMutou::
    dw %0111111111111111
    dw %0111111111111111
    dw %0011110111101111
    dw %0001110011100111
paletteMutouEnd:

; Nurse #ffffff

paletteNurse::
    dw %0111111111111111
    dw %0111111111111111
    dw %0011110111101111
    dw %0001110011100111
paletteNurseEnd:

; Nomiya #e0e0e0

paletteNomiya::
    dw %0111111111111111
    dw %0111001110011100
    dw %0011100111001110
    dw %0001110011100111
paletteNomiyaEnd:

; Yuuko #2c9e31

paletteYuuko::
    dw %0010011110000111
    dw %0001101001100101
    dw %0000110100100010
    dw %0000010010000001
paletteYuukoEnd:

; Sae #d4d4ff

paletteSae::
    dw %0111111111111111
    dw %0111111101011010
    dw %0011110110101101
    dw %0001110011000110
paletteSaeEnd:

; Akira #eb243b

paletteAkira::
    dw %0010100011011111
    dw %0001110010011101
    dw %0000110001001110
    dw %0000010000100111
paletteAkiraEnd:

; Hideaki #6299ff

paletteHideaki::
    dw %0111111110010010
    dw %0111111001101100
    dw %0011110100100110
    dw %0001110010000011
paletteHideakiEnd:

; Jigoro #99aacc

paletteJigoro::
    dw %0111111111111100
    dw %0110011010110011
    dw %0011000101001001
    dw %0001100010100100
paletteJigoroEnd:

; Meiko #995050

paletteMeiko::
    dw %0011110111111100
    dw %0010100101010011
    dw %0001010010101001
    dw %0000100001000100
paletteMeikoEnd:

; Shopkeep #7187a8

paletteShopkeep::
    dw %0111111100010101
    dw %0101011000001110
    dw %0010100100000111
    dw %0001010010000011
paletteShopkeepEnd:

; Miki #ad735e

paletteMiki::
    dw %0100001010111111
    dw %0010110111010101
    dw %0001010011101010
    dw %0000100001100101
paletteMikiEnd:

CopyDEintoPaletteB::
    ; Register B contains palette index, between 0-7
    ld a, b
    and a, $7
    rlc a
    rlc a
    rlc a
    ; Copy 8 bytes
    ld b, 8
    ; Bit 7 == 1 means autoincrement background palette memory pointer
    or a, $80
    ld [rBCPS], a
    .PaletteCopyLoop
    ld a, [de]
    ld [rBCPD], a
    inc de
    dec b
    jr nz, .PaletteCopyLoop
    ret
