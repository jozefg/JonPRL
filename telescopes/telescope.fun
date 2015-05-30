functor Telescope (L : LABEL) :> TELESCOPE where type label = L.t =
struct
  type label = L.t

  structure Dict = SplayDict(structure Key = L)

  type 'a telescope =
    {first : L.t,
     last : L.t,
     preds : L.t Dict.dict,
     nexts : L.t Dict.dict,
     vals : 'a Dict.dict} option

  exception LabelExists

  fun merge_dict (d1, d2) =
    Dict.foldl (fn (a, b, d3) =>
      case Dict.find d3 a of
           NONE => Dict.insert d3 a b
         | SOME _ => raise LabelExists) d2 d1

  fun interpose_after (SOME {first,last,preds,nexts,vals}) (lbl, SOME tele) = SOME
    {first = first,
     last = case SOME (Dict.lookup nexts lbl) handle _ => NONE of
                 NONE => #last tele
               | SOME lbl' => last,
     preds =
       let
         val preds' = Dict.insert preds (#first tele) lbl
         val preds'' =
           case SOME (Dict.lookup nexts lbl) handle _ => NONE of
                NONE => preds'
              | SOME lblpst => Dict.insert preds' lblpst (#last tele)
       in
         merge_dict (#preds tele, preds'')
       end,
     nexts =
       let
         val nexts' = Dict.insert nexts lbl (#first tele)
         val nexts'' =
           case SOME (Dict.lookup nexts lbl) handle _ => NONE of
                NONE => nexts'
              | SOME lblpst => Dict.insert nexts' (#last tele) lblpst
       in
         merge_dict (#nexts tele, nexts'')
       end,
     vals = merge_dict (vals, #vals tele)}
    | interpose_after tele (lbl, NONE) = tele
    | interpose_after NONE (lbl, tele) = tele

  fun modify (SOME {first,last,preds,nexts,vals}) (lbl, f) =
    let
      val a = Dict.lookup vals lbl
      val vals' = Dict.insert vals lbl (f a)
    in
      SOME ({first = first, last = last, preds = preds, nexts = nexts, vals = vals'})
    end
    | modify NONE _ = NONE

  fun lookup (SOME {vals,...} : 'a telescope) lbl = Dict.lookup vals lbl
    | lookup NONE lbl = raise Fail "Lookup empty"

  fun find (SOME {vals,...} : 'a telescope) lbl = Dict.find vals lbl
    | find _ _ = NONE

  fun fresh (SOME tele : 'a telescope, lbl) =
    if Dict.member (#vals tele) lbl then
      fresh (SOME tele, L.prime lbl)
    else
      lbl
    | fresh (NONE, lbl) = lbl

  val empty = NONE

  fun singleton (lbl, a) =
    SOME
    {first = lbl,
     last = lbl,
     nexts = Dict.empty,
     preds = Dict.empty,
     vals = Dict.insert Dict.empty lbl a}

  fun cons (lbl, a) tele = interpose_after (singleton (lbl, a)) (lbl, tele)

  fun snoc (SOME tele) (lbl, a) = interpose_after (SOME tele) (#last tele, singleton (lbl, a))
    | snoc NONE (lbl, a) = singleton (lbl, a)

  fun map NONE f = NONE
    | map (SOME {first,last,preds,nexts,vals}) f =
        SOME {first = first, last = last, preds = preds, nexts = nexts, vals = Dict.map f vals}

  structure SnocView =
  struct
    type 'a telescope = 'a telescope
    type label = label

    datatype ('a, 'r) view =
        Empty
      | Snoc of 'r * label * 'a

    fun out NONE = Empty
      | out (SOME {first,last,preds,nexts,vals}) =
          let
            val tail =
              case SOME (Dict.lookup preds last) handle _ => NONE of
                   NONE => NONE
                 | SOME pred => SOME {first = first, last = pred, preds = preds, nexts = nexts, vals = vals}
          in
            Snoc (tail, last, Dict.lookup vals last)
          end

    fun into Empty = empty
      | into (Snoc (tel, lbl, a)) = snoc tel (lbl, a)
  end

  structure ConsView =
  struct
    type 'a telescope = 'a telescope
    type label = label

    datatype ('a, 'r) view =
        Empty
      | Cons of label * 'a * 'r

    fun out NONE = Empty
      | out (SOME {first,last,preds,nexts,vals}) =
          let
            val tail =
              case SOME (Dict.lookup nexts first) handle _ => NONE of
                   NONE => NONE
                 | SOME next => SOME {first = next, last = last, preds = preds, nexts = nexts, vals = vals}
          in
            Cons (first, Dict.lookup vals first, tail)
          end

    fun out_after NONE lbl = Empty
      | out_after (SOME {first,last,preds,nexts,vals}) lbl =
         out (SOME {first = lbl, last = last, preds = preds, nexts = nexts, vals = vals})

    fun into Empty = empty
      | into (Cons (tel, lbl, a)) = raise Fail "hole"
  end

  local
    open ConsView
  in
    fun map_after NONE (lbl, f) = NONE
      | map_after (SOME tele) (lbl, f) =
          let
            val {first,last,preds,nexts,vals} = tele
            fun go Empty D = D
              | go (Cons (lbl, a, tele)) D =
                  go (out tele) (Dict.insert D lbl (f (Dict.lookup D lbl)))
          in
            SOME {first = first, last = last, preds = preds, nexts = nexts, vals = go (out (SOME tele)) vals}
          end
  end

  local
    open SnocView
    exception Hole
  in
    fun search (tele : 'a telescope) phi =
      let
        fun go Empty = NONE
          | go (Snoc (tele', lbl, a)) =
              if phi a then
                SOME (lbl, a)
              else
                go (out tele')
      in
        go (out tele)
      end

    fun subtelescope test (t1, t2) =
      let
        fun go Empty = true
          | go (Snoc (t1', lbl, a)) =
              case find t2 lbl of
                   NONE => false
                 | SOME a' => test (a, a') andalso go (out t1')
      in
        go (out t1)
      end

    fun eq test (t1, t2) =
      subtelescope test (t1, t2)
        andalso subtelescope test (t2, t1)

    fun to_string pretty tele =
      let
        fun go Empty r = r
          | go (Snoc (tele', lbl, a)) r =
              go (out tele') (r ^ ", " ^ L.to_string lbl ^ " : " ^ pretty a)
      in
        go (out tele) "·"
      end
  end
end

functor TelescopeNotation (T : TELESCOPE) : TELESCOPE_NOTATION =
struct
  open T

  fun >: (tele, p) = snoc tele p
end