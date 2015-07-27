structure Derivation =
struct
  type world = ParserContext.world

  datatype t =
      UNIV_EQ of Level.t | CUM
    | EQ_EQ
    | VOID_EQ | VOID_ELIM
    | UNIT_EQ | UNIT_INTRO | UNIT_ELIM | AX_EQ
    | PROD_EQ | PROD_INTRO | IND_PROD_INTRO | PROD_ELIM | PAIR_EQ | SPREAD_EQ
    | FUN_EQ | FUN_INTRO | FUN_ELIM | LAM_EQ | AP_EQ | FUN_EXT
    | ISECT_EQ | ISECT_INTRO | ISECT_ELIM | ISECT_MEMBER_EQ | ISECT_MEMBER_CASE_EQ
    | WITNESS | HYP_EQ | EQ_SUBST | EQ_SYM
    | SUBSET_EQ | SUBSET_INTRO | IND_SUBSET_INTRO | SUBSET_ELIM | SUBSET_MEMBER_EQ
    | PLUS_EQ | PLUS_INTROL | PLUS_INTROR | PLUS_ELIM | INL_EQ | INR_EQ | DECIDE_EQ

    | NAT_EQ | NAT_ELIM | ZERO_EQ | SUCC_EQ | NATREC_EQ

    | ADMIT
    | CEQUAL_EQ | CEQUAL_SYM | CEQUAL_STEP
    | CEQUAL_SUBST | CEQUAL_STRUCT of Arity.t
    | CEQUAL_APPROX
    | APPROX_EQ | APPROX_EXT_EQ | APPROX_REFL
    | BOTTOM_DIVERGES
    | BASE_EQ | BASE_INTRO | BASE_ELIM_EQ | BASE_MEMBER_EQ

    | IMAGE_EQ | IMAGE_MEM_EQ | IMAGE_ELIM | IMAGE_EQ_IND
    | LEMMA of {label : Label.t}

  val eq : t * t -> bool = op=

  fun arity theta =
    case theta of
         UNIV_EQ _ => #[]
       | CUM => #[0]
       | EQ_EQ => #[0,0,0]
       | CEQUAL_EQ => #[0, 0]
       | CEQUAL_SYM => #[0]
       | CEQUAL_STEP => #[0]
       | CEQUAL_SUBST => #[0, 0]
       | CEQUAL_STRUCT arity => arity
       | CEQUAL_APPROX => #[0, 0]
       | APPROX_EQ => #[0,0]
       | APPROX_EXT_EQ => #[0]
       | APPROX_REFL => #[]
       | BOTTOM_DIVERGES => #[]
       | VOID_EQ => #[]
       | VOID_ELIM => #[0]

       | BASE_EQ => #[]
       | BASE_INTRO => #[]
       | BASE_ELIM_EQ => #[1]
       | BASE_MEMBER_EQ => #[0]

       | IMAGE_EQ => #[0,0]
       | IMAGE_MEM_EQ => #[0,0]
       | IMAGE_ELIM => #[1]
       | IMAGE_EQ_IND => #[0,0,0,4]

       | UNIT_EQ => #[]
       | UNIT_INTRO => #[]
       | UNIT_ELIM => #[0,0]
       | AX_EQ => #[]

       | PROD_EQ => #[0,1]
       | PROD_INTRO => #[0,0,0,1]
       | IND_PROD_INTRO => #[0,0]
       | PROD_ELIM => #[0,2]
       | PAIR_EQ => #[0,0,1]
       | SPREAD_EQ => #[0,3]

       | PLUS_EQ => #[0, 0]
       | PLUS_INTROL => #[0, 0] (* The extra arg is that the other *)
       | PLUS_INTROR => #[0, 0] (* branch has a type. Just a wf-ness goal *)
       | PLUS_ELIM => #[0, 1, 1]
       | INL_EQ => #[0, 0]
       | INR_EQ => #[0, 0]
       | DECIDE_EQ => #[0, 2, 2]

       | NAT_EQ => #[]
       | NAT_ELIM => #[0,0,2]
       | ZERO_EQ => #[]
       | SUCC_EQ => #[0]
       | NATREC_EQ => #[0,0,2]

       | FUN_EQ => #[0,1]
       | FUN_INTRO => #[1,0]
       | FUN_ELIM => #[0,0,0,2]
       | LAM_EQ => #[1,0]
       | AP_EQ => #[0,0]
       | FUN_EXT => #[1,0,0,0]

       | ISECT_EQ => #[0,1]
       | ISECT_INTRO => #[1,0]
       | ISECT_ELIM => #[0,0,0,2]
       | ISECT_MEMBER_EQ => #[1,0]
       | ISECT_MEMBER_CASE_EQ => #[0,0]

       | WITNESS => #[0,0]
       | HYP_EQ => #[0]
       | EQ_SUBST => #[0,0,1]
       | EQ_SYM => #[0]

       | SUBSET_EQ => #[0,1]
       | SUBSET_INTRO => #[0,0,0,1]
       | IND_SUBSET_INTRO => #[0,0]
       | SUBSET_ELIM => #[0,2]
       | SUBSET_MEMBER_EQ => #[0,0,1]

       | ADMIT => #[]
       | LEMMA _ => #[]

  fun toString theta =
    case theta of
         UNIV_EQ i => "U-eq{" ^ Level.toString i ^ "}"
       | CUM => "cum"
       | VOID_EQ => "void-eq"
       | VOID_ELIM => "void-elim"

       | EQ_EQ => "eq⁼"
       | CEQUAL_EQ => "~⁼"
       | CEQUAL_SYM => "~-sym"
       | CEQUAL_STEP => "~-step"
       | CEQUAL_SUBST => "~-subst"
       | CEQUAL_STRUCT _ => "~-struct"
       | CEQUAL_APPROX => "~-~<="
       | APPROX_EQ => "~<=-eq"
       | APPROX_EXT_EQ => "~<=-ext-eq"
       | APPROX_REFL => "~<=-refl"
       | BOTTOM_DIVERGES => "bottom-div"
       | UNIT_EQ => "unit⁼"
       | UNIT_INTRO => "unit-intro"
       | UNIT_ELIM => "unit-elim"
       | AX_EQ => "<>-eq"

       | BASE_EQ => "base-eq"
       | BASE_INTRO => "base-intro"
       | BASE_ELIM_EQ => "base-elim-eq"
       | BASE_MEMBER_EQ => "base-member-eq"

       | IMAGE_EQ => "image-eq"
       | IMAGE_MEM_EQ => "image-mem-eq"
       | IMAGE_ELIM => "image-elim"
       | IMAGE_EQ_IND => "image-eq-ind"

       | PROD_EQ => "prod-eq"
       | PROD_INTRO => "prod-intro"
       | IND_PROD_INTRO => "independent-prod-intro"
       | PROD_ELIM => "prod-elim"
       | PAIR_EQ => "pair-eq"
       | SPREAD_EQ => "spread-eq"

       | FUN_EQ => "fun-eq"
       | FUN_INTRO => "fun-intro"
       | FUN_ELIM => "fun-elim"
       | LAM_EQ => "lam-eq"
       | AP_EQ => "ap-eq"
       | FUN_EXT => "funext"

       | PLUS_INTROL => "plus-introl"
       | PLUS_INTROR => "plus-intror"
       | PLUS_ELIM => "plus-elim"
       | PLUS_EQ => "plus-eq"
       | INL_EQ => "inl-eq"
       | INR_EQ => "inr-eq"
       | DECIDE_EQ => "decide-eq"

       | NAT_EQ => "nat-eq"
       | NAT_ELIM => "nat-elim"
       | ZERO_EQ => "zero-eq"
       | SUCC_EQ => "succ-eq"
       | NATREC_EQ => "natrec-eq"

       | ISECT_EQ => "isect-eq"
       | ISECT_INTRO => "isect-intro"
       | ISECT_ELIM => "isect-elim"
       | ISECT_MEMBER_EQ => "isect-mem-eq"
       | ISECT_MEMBER_CASE_EQ => "isect-mem-case⁼"

       | WITNESS => "witness"
       | HYP_EQ => "hyp-eq"
       | EQ_SUBST => "subst"
       | EQ_SYM => "sym"
       | ADMIT => "<<<<<ADMIT>>>>>"

       | SUBSET_EQ => "subset-eq"
       | SUBSET_INTRO => "subset-intro"
       | IND_SUBSET_INTRO => "independent-subset-intro"
       | SUBSET_ELIM => "subset-elim"
       | SUBSET_MEMBER_EQ => "subset-member-eq"
       | LEMMA {label} => Label.toString label

  fun parseOperator _ =
    ParserCombinators.fail "derivations not parsed"
end

structure DerivationInj = OperatorInjection
  (structure Operator = Derivation
   structure Universe = UniversalOperator.Universe)
