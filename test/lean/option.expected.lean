import Out.Sail.Sail

open Sail

abbrev SailM := StateM Unit

def match_option (x : (Option (BitVec 1))) : (BitVec 1) :=
  match x with
  | some x => x
  | none => 0#1

def option_match (x : (Option Unit)) (y : (BitVec 1)) : (Option (BitVec 1)) :=
  match x with
  | some () => (some y)
  | none => none

def initialize_registers (lit : Unit) : Unit :=
  ()

