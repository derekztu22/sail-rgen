
val "eq_anything" : forall ('a : Type). ('a, 'a) -> bool
val eq_atom = {ocaml: "eq_int", lem: "eq", c: "eq_int", coq: "Z.eqb"} : forall 'n 'm. (atom('n), atom('m)) -> bool

overload operator == = {eq_atom, eq_anything}

$[sv_module { stdout = true }]
val "print_endline" : string -> unit

enum test = A | B

function main (() : unit) -> unit = {
  let x = A;
  match x {
    B => print_endline("B"),
    A => print_endline("A")
  }
}
