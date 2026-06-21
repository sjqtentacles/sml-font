(* test_measure.sml -- text extent measurement. *)

structure MeasureTests =
struct
  open Support
  structure H = Harness

  fun pairEq name (e, a) =
    H.checkIntList name ([#1 e, #2 e], [#1 a, #2 a])

  fun run () =
    let
      val () = H.section "measure"

      val () = pairEq "measure \"\" is (0,0)" ((0, 0), F.measure font "")
      val () = pairEq "measure \"A\" is (6,7)" ((6, 7), F.measure font "A")
      val () = pairEq "measure \"AB\" is (12,7)" ((12, 7), F.measure font "AB")
      val () = pairEq "measure \"Hello\" is (30,7)" ((30, 7), F.measure font "Hello")
      val () = pairEq "measure two lines takes max width and stacks height"
                 ((12, 14), F.measure font "A\nBC")
    in
      ()
    end
end
