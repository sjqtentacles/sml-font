(* test_glyph.sml -- exact glyph bitmaps for known characters. *)

structure GlyphTests =
struct
  open Support
  structure H = Harness

  fun run () =
    let
      val () = H.section "glyph bitmaps"

      val () = H.checkStringList "glyph 'A' bitmap"
                 ([ ".###." , "#...#" , "#...#" , "#####"
                  , "#...#" , "#...#" , "#...#" ],
                  bitsToRows (F.glyph font #"A"))

      val () = H.checkStringList "glyph 'H' bitmap"
                 ([ "#...#" , "#...#" , "#...#" , "#####"
                  , "#...#" , "#...#" , "#...#" ],
                  bitsToRows (F.glyph font #"H"))

      val () = H.checkStringList "glyph '0' bitmap"
                 ([ ".###." , "#...#" , "#..##" , ".#.#."
                  , "##..#" , "#...#" , ".###." ],
                  bitsToRows (F.glyph font #"0"))

      val () = H.checkStringList "glyph ' ' bitmap is blank"
                 ([ "....." , "....." , "....." , "....."
                  , "....." , "....." , "....." ],
                  bitsToRows (F.glyph font #" "))

      val () = H.checkStringList "glyph '!' bitmap"
                 ([ "..#.." , "..#.." , "..#.." , "..#.."
                  , "..#.." , "....." , "..#.." ],
                  bitsToRows (F.glyph font #"!"))
    in
      ()
    end
end
