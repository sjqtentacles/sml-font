(* support.sml -- shared helpers and the vendored BDF font for the suite. *)

structure Support =
struct
  structure F = Font
  structure I = Image

  (* Read an entire file as a string (binary-safe). *)
  fun readFile path =
    let
      val ins = TextIO.openIn path
      val s = TextIO.inputAll ins
    in
      TextIO.closeIn ins; s
    end

  (* The font5x7 BDF vendored under data/ (relative to the repo root, which is
     the working directory for both `make test` and `make test-poly`). *)
  val bdfText = readFile "data/font5x7.bdf"
  val font = F.parseBdf bdfText

  val white : I.rgba8 = { r = 0w255, g = 0w255, b = 0w255, a = 0w255 }
  val black : I.rgba8 = { r = 0w0, g = 0w0, b = 0w0, a = 0w255 }

  fun isWhite ({ r, g, b, ... } : I.rgba8) =
    r = 0w255 andalso g = 0w255 andalso b = 0w255
  fun isBlack ({ r, g, b, ... } : I.rgba8) =
    r = 0w0 andalso g = 0w0 andalso b = 0w0

  (* Render `bits` of a glyph as a list of '#'/'.' rows for readable asserts. *)
  fun bitsToRows ({ w, h, bits } : { w : int, h : int, bits : bool array }) =
    List.tabulate (h, fn r =>
      String.implode (List.tabulate (w, fn c =>
        if Array.sub (bits, r * w + c) then #"#" else #".")))
end
