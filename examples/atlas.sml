(* sml-font demo: parses the vendored data/font5x7.bdf, then uses sml-raster for
   the background/panels and Font.drawText to render a title, a few sample lines
   at different scales/colors, and a full printable-ASCII glyph atlas; writes
   assets/atlas.png. *)

fun rgba (r, g, b) : Image.rgba8 =
  { r = Word8.fromInt r, g = Word8.fromInt g, b = Word8.fromInt b, a = 0w255 }

fun readFile path =
  let val ins = TextIO.openIn path
      val s = TextIO.inputAll ins
  in TextIO.closeIn ins; s end

val font = Font.parseBdf (readFile "data/font5x7.bdf")

(* palette *)
val bg      = rgba (18, 20, 28)
val panel   = rgba (28, 32, 44)
val border  = rgba (60, 68, 92)
val fg      = rgba (232, 236, 245)
val accent  = rgba (120, 210, 235)
val warm    = rgba (240, 190, 96)
val green   = rgba (130, 220, 150)
val pink    = rgba (235, 120, 140)

val width = 640
val height = 360

(* --- background + a framed panel via sml-raster --- *)
val img0 = Raster.blank (width, height) bg
val img1 = Raster.fillRect img0 { x = 16, y = 16, w = width - 32, h = height - 32 } panel
val img2 = Raster.rect img1 { x = 16, y = 16, w = width - 32, h = height - 32 } border

fun text img (x, y) scale color s =
  Font.drawText img { x = x, y = y, scale = scale, color = color } font s

(* --- title + sample lines --- *)
val img3 = text img2 (34, 36) 5 accent "sml-font"
val img4 = text img3 (36, 86) 2 fg "Pure Standard ML bitmap font (BDF) -> sml-image"
val img5 = text img4 (36, 108) 2 warm "The quick brown fox jumps over the lazy dog"
val img6 = text img5 (36, 130) 2 green "0123456789  +-*/=  (){}[]  <>  @#&%"
val img7 = text img6 (36, 152) 2 pink "drawText / glyph / measure  ->  sml-plot ready"

(* --- glyph atlas: every printable ASCII glyph in a light grid --- *)
val gx0 = 36
val gy0 = 190
val cols = 24
val cellW = 21
val cellH = 26
val gscale = 3

fun atlasCell (img, idx) =
  let
    val code = 32 + idx
    val col = idx mod cols
    val row = idx div cols
    val cx = gx0 + col * cellW
    val cy = gy0 + row * cellH
    val img = Raster.rect img { x = cx, y = cy, w = cellW - 2, h = cellH - 2 } border
  in
    text img (cx + 3, cy + 3) gscale fg (String.str (Char.chr code))
  end

val numGlyphs = 95  (* 32..126 inclusive *)
fun atlasLoop (img, i) =
  if i >= numGlyphs then img else atlasLoop (atlasCell (img, i), i + 1)

val imgFinal = atlasLoop (img7, 0)

val () =
  let val os = BinIO.openOut "assets/atlas.png"
  in
    BinIO.output (os, Image.encodePng imgFinal);
    BinIO.closeOut os;
    print "wrote assets/atlas.png\n"
  end
