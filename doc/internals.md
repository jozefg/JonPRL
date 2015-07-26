# The Compiler Internals

If you're considering contributing to JonPRL's implementation, this
brief overview of how the compiler works may be helpful.

## Build System Logistics

JonPRL is compiled with SML/NJ's Compilation Manager. Luckily, this is
a very simple system to use. In every folder under `src/` there's a
file called `sources.cm`. It lists every file that needs to be
compiled and links to the `.cm` files of other things that it depends
on. That's all the configuration CM needs, from there you just write
code as if all the things you specified in that file are loaded.

To actually build stuff you can either

 1. Start up the SML/NJ REPL and type `CM.make "path/to/sources.cm";`
 2. Run `sml -m path/to/sources.cm`.

Either of these commands will spin up the compilation manager which
will check to see which work out all the inter-file dependencies and
compile everything as needed. So an example workflow while working on
JonPRL would be

 1. Modify a file
 2. Run `CM.make ...` (this will only recompile the files you've
    changed so it's quick)
 3. Occasionally run `make && make test` in the top level to run the
    modified compiler on example files

Note that `CM.make` and `sml -m` do **not** cause a new executable to
be generated in `bin/`. For that we have a make file in the top level
directory. In particular, be sure to run `make` before `make test`
otherwise you'll end up trying to figured out why the binary doesn't
have your new changes.

If you have any other CM issues, [the manual][manual] is very short
and very easy to read.

## The Compiler
### Syntax

*I use AST to mean the union of AST and ABT in this section*

The first place to start understanding the compiler is in the folder
`src/syntax`. This defines all the ASTs that are used throughout the
compiler. There are 3 basic ASTs

 1. The AST of terms and validations - `operator.sml`
 2. The AST of tactics - `tactic.sml`
 3. The AST of developments (a JonPRL file) - `development.sml`

JonPRL uses an [ABT library][abt] to handle binding, substitution,
alpha-equivalence, that sort of thing. This means that the
`operator.sml` seems to lack what you'd expect; there's no tree to
represent a program, instead it's just a bunch of "operators" like
`LAM` and `PAIR`. The way that this works is that we define a bunch of
operators to represent leafs in our AST. We have to provide this
additional information

 1. An equality function on operators
 2. A pretty printing function for them
 3. A parsing function for them (`string -> t option`)
 4. An arity function

The `arity` function takes an operator and tells us how many subterms
we should give it and how many variables each of those subterms must
bind. So for example, we have an operator to represent a function:
`LAM`. The arity of `LAM` is `#[1]` (that's sugar for an SML vector
there) since it has one subterm (the body) which binds one variable
(the argument) in the resulting AST. As another example, if we had an
`if` expression its arity would be `#[0, 0, 0]`; it has 3 subterms and
none of them may bind anything.

With this information, we can apply the `Abt` functor which gives us
back a representation of our AST. It's normally abstract but we can
use `out` to get a view of it. The view is defined as

``` sml
    datatype view =
        ` of Variable.t
      | $ of Operator.t * t Vector.vector
      | \ of Variable.t * t
```

A view of a term (or any AST created in this way) is either one of
three cases,

 1. A variable
 2. The application of an operator to a vector of subterms (this is
    a node in a traditional AST)
 3. A binding site `\`. This says that we've bound some variable in
    this term.

The variable given with `\` is guaranteed to be globally unique so we
don't have to deal with scoping issues. However, the internal
representation avoids using *all* globally unique identifiers so
it's not super inefficient.

We further use an utility module to get `subst`, `freeVariables`, and
several other convenient operators across terms for free. You should
read the signatures in sml-abt for a full listing.

Aside from these three main data types, there are a few more
structures in `syntax/` to be aware of.

 - `level.sml`

    This is how JonPRL works with levels for
    universes. It provides all the basic operations you would expect
    (`succ`/`pred`/...) as well as some equation solving features. The
    docs in `level.sig` should be helpful for understanding that.

 - `pattern.fun`

    Similarly to how we have `operator.sml`, we have something similar
    for handling operator definitions in JonPRL. This is really just a
    simple ABT with one operator (representing the only form operator
    definitions can have)

That about wraps up the context of the syntax folder. You should worry
about touching this folder if you ever modify anything directly user
facing, for example:

 - Adding new primitive tactics
 - A new term
 - Fix parsing for terms

### Parser

TODO

### Refiner

TODO

### Gluing it all together

JonPRL has relatively few "glue" modules built on top of
everything. There are only 4. Two of them are "eval" modules. They
take the ASTs for tactics and developments and translate them into the
appropriate notions for use in the `refiner` section. For example, in
`development_ast_eval.sml` there is one exported function

``` sml
    val eval : Development.world -> DevelopmentAst.t list -> Development.world
```

So we take the current world of the development and a list of ASTs,
one for each top level declaration. If we encounter a `THEOREM` in
that list we do something like the following

``` sml
    (* D is the current world *)
    THEOREM (lbl, term, tac) =>
    let
      val vars = Syntax.freeVariables term
      val () =
          case vars of
              [] => ()
            | _ => raise Context.Open term
    in
      Development.prove D (lbl,
                           Sequent.>> (Sequent.Context.empty, term),
                           TacticEval.eval D tac)
    end
```

So in this case we check that the `term` (represents what we're trying
to prove) has no free variables and then call
`Development.prove`. Since we need to supply a "real tactic" (not an
AST representing one) we need to convert `tac : Tactic.t` into a
tactic as described by `CTT.tactic`. To do this we use
`tactic_eval.sml` which behaves similarly to the code we're looking
at. It's just a matter of mapping an AST into the appropriate function
defined in `refiner/refiner.fun`.

In both of these evaluation files almost no computation occurs but
they will always need to be modified if you change something in their
respective ASTs, for example

 - Adding a new tactic
 - Renaming components of the development AST

The other two files are `frontend.sml` and `main.sml`. These are
really the top level files of JonPRL and are specifically the bits
that deal with reading the command line arguments, reading the
appropriate files, and kicking off the whole process. `main.sml` is
exclusively focused on parsing the command line arguments, you should
only ever touch this file if you're modifying how the `jonprl`
executable behaves.

[manual]: http://www.smlnj.org/doc/CM/new.pdf
[abt]: http://www.github.com/jonsterling/sml-abt
