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
    in
      ()
    end
end
