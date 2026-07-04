(* test_parse.sml -- BDF parsing: glyph counts, dimensions, metrics. *)

structure ParseTests =
struct
  open Support
  structure H = Harness

  fun run () =
    let
      val () = H.section "BDF parse / metadata"

      val () = H.checkInt "font defines 91 glyphs" (91, F.numGlyphs font)
      val () = H.checkInt "font height is 7" (7, F.height font)
      val () = H.checkInt "advance of 'A' is 6" (6, F.advance font #"A")
      val () = H.checkInt "advance of ' ' is 6" (6, F.advance font #" ")

      val gA = F.glyph font #"A"
      val () = H.checkInt "glyph 'A' width is 5" (5, #w gA)
      val () = H.checkInt "glyph 'A' height is 7" (7, #h gA)
      val () = H.checkInt "glyph 'A' bits length is 35" (35, Array.length (#bits gA))

      (* Missing glyph (DEL, 0x7f) falls back to DEFAULT_CHAR '?'. *)
      val gDel = F.glyph font (Char.chr 127)
      val gQ = F.glyph font #"?"
      val () = H.checkStringList "missing glyph falls back to '?'"
                 (bitsToRows gQ, bitsToRows gDel)

      val () = H.checkRaises "parseBdf rejects junk"
                 (fn () => F.parseBdf "not a bdf file at all")

      val () = H.section "oversized integer fields (cross-compiler bounded parse)"
      (* A BDF integer field past the fixed 32-bit range must raise `Font` (the
         documented failure), never a raw `Overflow`. MLton's default `int` is
         32-bit and `Int.fromString` raises `Overflow` past 2^31, while
         Poly/ML's 63-bit `int` silently accepts it -- so an unbounded parse
         both crashes MLton and diverges across compilers. `toInt` must reject
         out-of-range digits as `Font`. Real BDF metrics are all small. *)
      (* Minimal valid single-glyph BDF with the encoding / bounding-box fields
         substituted, so one field at a time can be pushed out of range. *)
      fun bdf (encoding, fbbx) =
        "STARTFONT 2.1\n\
        \FONTBOUNDINGBOX " ^ fbbx ^ "\n\
        \FONT_ASCENT 7\nFONT_DESCENT 0\nDEFAULT_CHAR 63\n\
        \STARTCHAR A\n\
        \ENCODING " ^ encoding ^ "\n\
        \DWIDTH 6 0\nBBX 5 7 0 0\n\
        \BITMAP\n00\n00\n00\n00\n00\n00\n00\nENDCHAR\nENDFONT\n"
      fun fontErr src =
        (ignore (F.parseBdf src); "no-exn")
        handle F.Font _ => "font"
             | Overflow  => "overflow"
             | _         => "other"
      (* sanity: the template with all-in-range fields parses cleanly *)
      val () = H.checkString "in-range template parses"
                 ("no-exn", fontErr (bdf ("65", "5 7 0 0")))
      val () = H.checkString "ENCODING 2147483648 -> Font, not Overflow"
                 ("font", fontErr (bdf ("2147483648", "5 7 0 0")))
      val () = H.checkString "ENCODING 999999999999 -> Font, not Overflow"
                 ("font", fontErr (bdf ("999999999999", "5 7 0 0")))
      val () = H.checkString "FONTBOUNDINGBOX 999999999999 -> Font, not Overflow"
                 ("font", fontErr (bdf ("65", "999999999999 7 0 0")))
      val () = H.checkString "ENCODING -2147483649 -> Font, not Overflow"
                 ("font", fontErr (bdf ("-2147483649", "5 7 0 0")))
    in
      ()
    end
end
