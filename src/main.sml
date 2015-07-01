structure Main =
struct
  datatype mode =
      CHECK_DEVELOPMENT
    | PRINT_DEVELOPMENT
    | LIST_OPERATORS
    | LIST_TACTICS

  val listOfTactics =
    ["intro [TERM]? #NUM? <NAME*>?",
     "elim #NUM [TERM]? <NAME*>?",
     "eq-cd [TERM*]? <NAME*>? @LEVEL?",
     "ext <NAME>? @LEVEL?",
     "symmetry",
     "creflexivty",
     "csymmetry",
     "step",
     "cstruct",
     "assumption",
     "assert [TERM] <NAME>?",
     "mem-cd",
     "auto NUM?",
     "reduce NUM?",
     "lemma <NAME>",
     "cut-lemma <NAME>",
     "unfold <(NAME @NUM)+>",
     "refine <NAME>",
     "witness [TERM]",
     "hypothesis #NUM",
     "hyp-subst (←|→) #NUM [TERM] @NUM?",
     "id",
     "fail",
     "trace \"MESSAGE\"",
     "cum @NUM?",
     "focus NUM #{TACTIC}"]

  local
    fun go [] = PRINT_DEVELOPMENT
      | go ("--check" :: _) = CHECK_DEVELOPMENT
      | go ("--list-operators" :: _) = LIST_OPERATORS
      | go ("--list-tactics" :: _) = LIST_TACTICS
      | go (_ :: xs) = go xs
  in
    fun getMode args = go args
  end

  fun main (_, args) =
    let
      val (opts, files) = List.partition (String.isPrefix "--") args
      val mode = getMode opts

      fun loadFile (f, (dev, pending)) =
        case CttFrontend.loadFile (dev, f) of
            (dev', f) => (dev', f :: pending)
      fun runAllProofs pending =
        (List.app (fn f => f ()) (List.rev pending); 0)
          handle _ => 1

      val oworld =
          SOME (foldl loadFile (Development.empty, []) files) handle _ => NONE
    in
      case oworld of
           NONE => 1
         | SOME (world, pending) =>
             (case mode of
                   CHECK_DEVELOPMENT => runAllProofs pending
                 | PRINT_DEVELOPMENT =>
                   (CttFrontend.printDevelopment world; runAllProofs pending)
                 | LIST_OPERATORS =>
                   (CttFrontend.printOperators world; runAllProofs pending)
                 | LIST_TACTICS =>
                     (app (fn tac => print (tac ^ "\n")) listOfTactics; runAllProofs pending))
    end
end
