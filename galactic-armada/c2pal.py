"""
Background #cfb27f
Hisao #629276
Hanako #897cbf
Emi #ff8d7c
Rin #b14343
Lilly #f9eaa0
Shizune #72adee
Misha #ff809f
Kenji #cc7c2a
Mutou #ffffff
Nurse #ffffff
Nomiya #e0e0e0
Yuuko #2c9e31
Sae #d4d4ff
Akira #eb243b
Hideaki #6299ff
Jigoro #99aacc
Meiko #995050
Shopkeep #7187a8
Miki #ad735e
"""

with open("cols.csv") as f:
    for line in f:
        name, color = line.strip().split(" #")
        r, g, b = color[0:2], color[2:4], color[4:6]
        rq = int(r, 16) // 8
        gq = int(g, 16) // 8
        bq = int(b, 16) // 8

        def _pc(_r, _g, _b):
            _r = min(31, int(_r))
            _g = min(31, int(_g))
            _b = min(31, int(_b))
            print(f"    dw %0{_b:05b}{_g:05b}{_r:05b}")

        print(f"; {line}")
        print(f"palette{name}::")
        _pc(rq * 1.5, gq * 1.5, bq * 1.5)
        _pc(rq, gq, bq)
        _pc(rq // 2, gq // 2, bq // 2)
        _pc(rq // 4, gq // 4, bq // 4)
        print(f"palette{name}End:\n")
