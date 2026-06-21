(* test_draw.sml -- drawText renders glyph pixels into the image. *)

structure DrawTests =
struct
  open Support
  structure H = Harness

  fun px img (x, y) = I.getPixel img (x, y)

  fun run () =
    let
      val () = H.section "drawText"

      (* 'A' at scale 1, white on black, origin (0,0). *)
      val base = I.fill (5, 7) black
      val img = F.drawText base { x = 0, y = 0, scale = 1, color = white } font "A"

      (* row 0 = ".###." *)
      val () = H.checkBool "A (0,0) off" (true, isBlack (px img (0, 0)))
      val () = H.checkBool "A (1,0) on"  (true, isWhite (px img (1, 0)))
      val () = H.checkBool "A (3,0) on"  (true, isWhite (px img (3, 0)))
      val () = H.checkBool "A (4,0) off" (true, isBlack (px img (4, 0)))
      (* row 3 = "#####" *)
      val () = H.checkBool "A (0,3) on"  (true, isWhite (px img (0, 3)))
      val () = H.checkBool "A (4,3) on"  (true, isWhite (px img (4, 3)))

      (* scale 2: each glyph pixel becomes a 2x2 block. *)
      val base2 = I.fill (12, 14) black
      val img2 = F.drawText base2 { x = 0, y = 0, scale = 2, color = white } font "A"
      (* row0 col1 -> block x in {2,3}, y in {0,1} *)
      val () = H.checkBool "A@2 (2,0) on" (true, isWhite (px img2 (2, 0)))
      val () = H.checkBool "A@2 (3,1) on" (true, isWhite (px img2 (3, 1)))
      (* row0 col0 off -> (0,0) untouched *)
      val () = H.checkBool "A@2 (0,0) off" (true, isBlack (px img2 (0, 0)))

      (* newline starts a second line one font-height down. *)
      val base3 = I.fill (12, 14) black
      val img3 = F.drawText base3 { x = 0, y = 0, scale = 1, color = white } font "A\nB"
      (* 'B' row0 = "#### " at y=7 -> (0,7) on *)
      val () = H.checkBool "newline B (0,7) on" (true, isWhite (px img3 (0, 7)))

      (* off-screen drawing is clipped, not an error. *)
      val base4 = I.fill (5, 7) black
      val img4 = F.drawText base4 { x = 100, y = 100, scale = 1, color = white } font "A"
      val () = H.checkBool "off-screen leaves image black"
                 (true, isBlack (px img4 (0, 0)))

      (* color is honoured per channel. *)
      val red : I.rgba8 = { r = 0w255, g = 0w0, b = 0w0, a = 0w255 }
      val base5 = I.fill (5, 7) black
      val img5 = F.drawText base5 { x = 0, y = 0, scale = 1, color = red } font "A"
      val p = px img5 (1, 0)
      val () = H.checkBool "A pixel is red"
                 (true, #r p = 0w255 andalso #g p = 0w0 andalso #b p = 0w0)
    in
      ()
    end
end
