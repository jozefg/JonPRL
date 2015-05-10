structure Test =
struct
  val print_mode = PrintMode.User

  structure Var = Variable ()
  structure Syn =
    AbtUtil (Abt (structure Operator = Operator and Variable = Var))

 structure Sequent =
   Sequent
     (structure Context = Context(Syn.Variable)
      structure Syntax = Syn)

  structure Refiner =
    Refiner
      (structure Syn = Syn
       structure Sequent = Sequent
       val print_mode = print_mode)

  structure Extract = Extract(Syn)

  open Operator Syn Refiner
  open CoreTactics DerivedTactics InferenceRules Sequent

  infix 2 >>
  infix 7 $$
  infix \\ THEN THENL ORELSE

  val void = VOID $$ #[]
  val unit = UNIT $$ #[]
  val ax = AX $$ #[]

  fun & (a, b) = PROD $$ #[a, Variable.named "x" \\ b]
  infix 6 &

  fun pair m n = PAIR $$ #[m,n]
  fun lam e =
    let
      val x = Var.named "x"
    in
      LAM $$ #[x \\ e x]
    end

  fun pi a b =
    let
      val x = Var.named "x"
    in
      FUN $$ #[a, x \\ b x]
    end

  fun ~> (a, b) = FUN $$ #[a,Variable.named "x" \\ b]
  infixr 5 ~>

  fun mem (m, a) = MEM $$ #[m,a]
  infix 5 mem

  val Emp = Context.empty

  val test1 =
    Library.save "test1" (Emp >> unit & (unit & unit))
      (ProdIntro ax THEN (TRY (ProdIntro ax)) THEN Auto)

  val test1' =
    Library.save "test1'" (Emp >> unit & (unit & unit))
      (Lemma test1)

  val z = Variable.named "z"

  val test2 =
    Library.save "test2" (Emp >> unit ~> (unit & unit))
      (FunIntro z THENL [ProdIntro ax THEN Auto, Auto])

  val test3 =
    Library.save "test3" (Emp >> lam (fn x => `` x) mem (unit ~> unit))
      Auto

  val test4 =
    Library.save "test4" (Emp >> lam (fn x => pair ax ax) mem (void ~> void))
      (MemUnfold THEN ReduceGoal THEN LamEq z THENL [VoidElim THEN Auto, Auto])

  val test5 =
    Library.save "test5" (Emp >> void ~> (unit & unit))
      (FunIntro z THENL [VoidElim THEN Auto, Auto])

  val test6 =
    Library.save "test6" (Emp >> unit ~> (unit & unit))
      (Witness (lam (fn x => pair (`` x) (`` x))) THEN Auto)

 local
   val x = Variable.named "x"
   val y = Variable.named "y"
  in
    val test7 =
      Library.save "test7" (Emp >> (void & unit) ~> void)
        (FunIntro z THENL
          [ ProdElim z (x, y) THEN Assumption
          , Auto
          ])
  end

  fun print_lemma lemma =
    let
      open Library
      val gl = goal lemma
      val evidence = validate lemma
    in
      print ("\n" ^ name lemma ^ "\n");
      print "----------------------------------------\n";
      print ("Goal: " ^ Sequent.to_string print_mode gl ^ "\n");
      print ("Evidence: " ^ Syn.to_string print_mode evidence ^ "\n");
      print ("Extract: " ^ Syn.to_string print_mode (Extract.extract evidence) ^ "\n\n")
    end

  val _ =
    List.map print_lemma (Library.all ())
end

