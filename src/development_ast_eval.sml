structure DevelopmentAstEval :
sig
  val eval : Development.world -> DevelopmentAst.t list -> Development.world
end =
struct
  open DevelopmentAst
  fun eval_decl (D, pending) ast =
    case ast of
        THEOREM (lbl, term, tac) =>
        let
          val vars = Syntax.freeVariables term
          val () =
              case vars of
                  [] => ()
                | _ => raise Context.Open term
          val (f, D') =
              Development.prove D (lbl,
                                   Sequent.>> (Sequent.Context.empty, term),
                                   TacticEval.eval D tac)
        in
            (D', f :: pending)
        end
      | OPERATOR (lbl, arity) =>
        (Development.declareOperator D (lbl, arity), pending)
      | TACTIC (lbl, tac) =>
        (Development.defineTactic D (lbl, TacticEval.eval D tac), pending)
      | DEFINITION (pat, term) =>
        (Development.defineOperator D {definiendum = pat, definiens = term},
         pending)

  fun eval D decls =
    let
      val (D', runProofs) =
          List.foldl (fn (decl, info) => eval_decl info decl) (D, []) decls
      val () = List.app (fn f => f ()) runProofs
    in
      D'
    end
end
