(* generated by Ott 0.25 from: l2.ott *)


type text = string

type l = Parse_ast.l

type 'a annot = l * 'a


type x = text (* identifier *)
type ix = text (* infix identifier *)

type 
base_kind_aux =  (* base kind *)
   BK_type (* kind of types *)
 | BK_nat (* kind of natural number size expressions *)
 | BK_order (* kind of vector order specifications *)
 | BK_effect (* kind of effect sets *)


type 
base_kind = 
   BK_aux of base_kind_aux * l


type 
id_aux =  (* Identifier *)
   Id of x
 | DeIid of x (* remove infix status *)


type 
kid_aux =  (* variables with kind, ticked to differntiate from program variables *)
   Var of x


type 
kind_aux =  (* kinds *)
   K_kind of (base_kind) list


type 
id = 
   Id_aux of id_aux * l


type 
kid = 
   Kid_aux of kid_aux * l


type 
kind = 
   K_aux of kind_aux * l


type 
nexp_aux =  (* expression of kind Nat, for vector sizes and origins *)
   Nexp_id of id (* identifier, bound by def Nat x = nexp *)
 | Nexp_var of kid (* variable *)
 | Nexp_constant of int (* constant *)
 | Nexp_times of nexp * nexp (* product *)
 | Nexp_sum of nexp * nexp (* sum *)
 | Nexp_minus of nexp * nexp (* subtraction *)
 | Nexp_exp of nexp (* exponential *)
 | Nexp_neg of nexp (* For internal use *)

and nexp = 
   Nexp_aux of nexp_aux * l


type 
base_effect_aux =  (* effect *)
   BE_rreg (* read register *)
 | BE_wreg (* write register *)
 | BE_rmem (* read memory *)
 | BE_wmem (* write memory *)
 | BE_eamem (* signal effective address for writing memory *)
 | BE_wmv (* write memory, sending only value *)
 | BE_barr (* memory barrier *)
 | BE_depend (* dynamic footprint *)
 | BE_undef (* undefined-instruction exception *)
 | BE_unspec (* unspecified values *)
 | BE_nondet (* nondeterminism from intra-instruction parallelism *)
 | BE_escape (* Tracking of expressions and functions that might call exit *)
 | BE_lset (* Local mutation happend; not user-writable *)
 | BE_lret (* Local return happened; not user-writable *)


type 
base_effect = 
   BE_aux of base_effect_aux * l


type 
order_aux =  (* vector order specifications, of kind Order *)
   Ord_var of kid (* variable *)
 | Ord_inc (* increasing (little-endian) *)
 | Ord_dec (* decreasing (big-endian) *)


type 
effect_aux =  (* effect set, of kind Effects *)
   Effect_var of kid
 | Effect_set of (base_effect) list (* effect set *)


type 
order = 
   Ord_aux of order_aux * l


type 
effect = 
   Effect_aux of effect_aux * l


type 
kinded_id_aux =  (* optionally kind-annotated identifier *)
   KOpt_none of kid (* identifier *)
 | KOpt_kind of kind * kid (* kind-annotated variable *)


type 
n_constraint_aux =  (* constraint over kind $_$ *)
   NC_fixed of nexp * nexp
 | NC_bounded_ge of nexp * nexp
 | NC_bounded_le of nexp * nexp
 | NC_nat_set_bounded of kid * (int) list


type 
kinded_id = 
   KOpt_aux of kinded_id_aux * l


type 
n_constraint = 
   NC_aux of n_constraint_aux * l


type 
quant_item_aux =  (* Either a kinded identifier or a nexp constraint for a typquant *)
   QI_id of kinded_id (* An optionally kinded identifier *)
 | QI_const of n_constraint (* A constraint for this type *)


type 
quant_item = 
   QI_aux of quant_item_aux * l


type 
typquant_aux =  (* type quantifiers and constraints *)
   TypQ_tq of (quant_item) list
 | TypQ_no_forall (* sugar, omitting quantifier and constraints *)


type 
lit_aux =  (* Literal constant *)
   L_unit (* $() : _$ *)
 | L_zero (* $_ : _$ *)
 | L_one (* $_ : _$ *)
 | L_true (* $_ : _$ *)
 | L_false (* $_ : _$ *)
 | L_num of int (* natural number constant *)
 | L_hex of string (* bit vector constant, C-style *)
 | L_bin of string (* bit vector constant, C-style *)
 | L_undef (* constant representing undefined values *)
 | L_string of string (* string constant *)


type 
typquant = 
   TypQ_aux of typquant_aux * l


type 
typ_aux =  (* Type expressions, of kind $_$ *)
   Typ_wild (* Unspecified type *)
 | Typ_id of id (* Defined type *)
 | Typ_var of kid (* Type variable *)
 | Typ_fn of typ * typ * effect (* Function type (first-order only in user code) *)
 | Typ_tup of (typ) list (* Tuple type *)
 | Typ_app of id * (typ_arg) list (* type constructor application *)

and typ = 
   Typ_aux of typ_aux * l

and typ_arg_aux =  (* Type constructor arguments of all kinds *)
   Typ_arg_nexp of nexp
 | Typ_arg_typ of typ
 | Typ_arg_order of order
 | Typ_arg_effect of effect

and typ_arg = 
   Typ_arg_aux of typ_arg_aux * l


type 
lit = 
   L_aux of lit_aux * l


type 
typschm_aux =  (* type scheme *)
   TypSchm_ts of typquant * typ


type 
'a pat_aux =  (* Pattern *)
   P_lit of lit (* literal constant pattern *)
 | P_wild (* wildcard *)
 | P_as of 'a pat * id (* named pattern *)
 | P_typ of typ * 'a pat (* typed pattern *)
 | P_id of id (* identifier *)
 | P_app of id * ('a pat) list (* union constructor pattern *)
 | P_record of ('a fpat) list * bool (* struct pattern *)
 | P_vector of ('a pat) list (* vector pattern *)
 | P_vector_indexed of ((int * 'a pat)) list (* vector pattern (with explicit indices) *)
 | P_vector_concat of ('a pat) list (* concatenated vector pattern *)
 | P_tup of ('a pat) list (* tuple pattern *)
 | P_list of ('a pat) list (* list pattern *)

and 'a pat = 
   P_aux of 'a pat_aux * 'a annot

and 'a fpat_aux =  (* Field pattern *)
   FP_Fpat of id * 'a pat

and 'a fpat = 
   FP_aux of 'a fpat_aux * 'a annot


type 
typschm = 
   TypSchm_aux of typschm_aux * l


type 
'a reg_id_aux = 
   RI_id of id


type 
'a exp_aux =  (* Expression *)
   E_block of ('a exp) list (* block *)
 | E_nondet of ('a exp) list (* nondeterminisitic block, expressions evaluate in an unspecified order, or concurrently *)
 | E_id of id (* identifier *)
 | E_lit of lit (* literal constant *)
 | E_cast of typ * 'a exp (* cast *)
 | E_app of id * ('a exp) list (* function application *)
 | E_app_infix of 'a exp * id * 'a exp (* infix function application *)
 | E_tuple of ('a exp) list (* tuple *)
 | E_if of 'a exp * 'a exp * 'a exp (* conditional *)
 | E_for of id * 'a exp * 'a exp * 'a exp * order * 'a exp (* loop *)
 | E_vector of ('a exp) list (* vector (indexed from 0) *)
 | E_vector_indexed of ((int * 'a exp)) list * 'a opt_default (* vector (indexed consecutively) *)
 | E_vector_access of 'a exp * 'a exp (* vector access *)
 | E_vector_subrange of 'a exp * 'a exp * 'a exp (* subvector extraction *)
 | E_vector_update of 'a exp * 'a exp * 'a exp (* vector functional update *)
 | E_vector_update_subrange of 'a exp * 'a exp * 'a exp * 'a exp (* vector subrange update (with vector) *)
 | E_vector_append of 'a exp * 'a exp (* vector concatenation *)
 | E_list of ('a exp) list (* list *)
 | E_cons of 'a exp * 'a exp (* cons *)
 | E_record of 'a fexps (* struct *)
 | E_record_update of 'a exp * 'a fexps (* functional update of struct *)
 | E_field of 'a exp * id (* field projection from struct *)
 | E_case of 'a exp * ('a pexp) list (* pattern matching *)
 | E_let of 'a letbind * 'a exp (* let expression *)
 | E_assign of 'a lexp * 'a exp (* imperative assignment *)
 | E_sizeof of nexp (* Expression to return the value of the nexp variable or expression at run time *)
 | E_exit of 'a exp (* expression to halt all current execution, potentially calling a system, trap, or interrupt handler with exp *)
 | E_return of 'a exp (* expression to end current function execution and return the value of exp from the function; this can be used to break out of for loops *)
 | E_assert of 'a exp * 'a exp (* expression to halt with error, when the first expression is false, reporting the optional string as an error *)
 | E_internal_cast of 'a annot * 'a exp (* This is an internal cast, generated during type checking that will resolve into a syntactic cast after *)
 | E_internal_exp of 'a annot (* This is an internal use for passing nexp information  to library functions, postponed for constraint solving *)
 | E_sizeof_internal of 'a annot (* For sizeof during type checking, to replace nexp with internal n *)
 | E_internal_exp_user of 'a annot * 'a annot (* This is like the above but the user has specified an implicit parameter for the current function *)
 | E_comment of string (* For generated unstructured comments *)
 | E_comment_struc of 'a exp (* For generated structured comments *)
 | E_internal_let of 'a lexp * 'a exp * 'a exp (* This is an internal node for compilation that demonstrates the scope of a local mutable variable *)
 | E_internal_plet of 'a pat * 'a exp * 'a exp (* This is an internal node, used to distinguised some introduced lets during processing from original ones *)
 | E_internal_return of 'a exp (* For internal use to embed into monad definition *)

and 'a exp = 
   E_aux of 'a exp_aux * 'a annot

and 'a lexp_aux =  (* lvalue expression *)
   LEXP_id of id (* identifier *)
 | LEXP_memory of id * ('a exp) list (* memory write via function call *)
 | LEXP_cast of typ * id
 | LEXP_tup of ('a lexp) list (* set multiple at a time, a check will ensure it's not memory *)
 | LEXP_vector of 'a lexp * 'a exp (* vector element *)
 | LEXP_vector_range of 'a lexp * 'a exp * 'a exp (* subvector *)
 | LEXP_field of 'a lexp * id (* struct field *)

and 'a lexp = 
   LEXP_aux of 'a lexp_aux * 'a annot

and 'a fexp_aux =  (* Field-expression *)
   FE_Fexp of id * 'a exp

and 'a fexp = 
   FE_aux of 'a fexp_aux * 'a annot

and 'a fexps_aux =  (* Field-expression list *)
   FES_Fexps of ('a fexp) list * bool

and 'a fexps = 
   FES_aux of 'a fexps_aux * 'a annot

and 'a opt_default_aux =  (* Optional default value for indexed vectors, to define a defualt value for any unspecified positions in a sparse map *)
   Def_val_empty
 | Def_val_dec of 'a exp

and 'a opt_default = 
   Def_val_aux of 'a opt_default_aux * 'a annot

and 'a pexp_aux =  (* Pattern match *)
   Pat_exp of 'a pat * 'a exp

and 'a pexp = 
   Pat_aux of 'a pexp_aux * 'a annot

and 'a letbind_aux =  (* Let binding *)
   LB_val_explicit of typschm * 'a pat * 'a exp (* value binding, explicit type ('a pat must be total) *)
 | LB_val_implicit of 'a pat * 'a exp (* value binding, implicit type ('a pat must be total) *)

and 'a letbind = 
   LB_aux of 'a letbind_aux * 'a annot


type 
'a reg_id = 
   RI_aux of 'a reg_id_aux * 'a annot


type 
type_union_aux =  (* Type union constructors *)
   Tu_id of id
 | Tu_ty_id of typ * id


type 
name_scm_opt_aux =  (* Optional variable-naming-scheme specification for variables of defined type *)
   Name_sect_none
 | Name_sect_some of string


type 
effect_opt_aux =  (* Optional effect annotation for functions *)
   Effect_opt_pure (* sugar for empty effect set *)
 | Effect_opt_effect of effect


type 
'a funcl_aux =  (* Function clause *)
   FCL_Funcl of id * 'a pat * 'a exp


type 
rec_opt_aux =  (* Optional recursive annotation for functions *)
   Rec_nonrec (* non-recursive *)
 | Rec_rec (* recursive *)


type 
tannot_opt_aux =  (* Optional type annotation for functions *)
   Typ_annot_opt_some of typquant * typ


type 
'a alias_spec_aux =  (* Register alias expression forms. Other than where noted, each id must refer to an unaliased register of type vector *)
   AL_subreg of 'a reg_id * id
 | AL_bit of 'a reg_id * 'a exp
 | AL_slice of 'a reg_id * 'a exp * 'a exp
 | AL_concat of 'a reg_id * 'a reg_id


type 
type_union = 
   Tu_aux of type_union_aux * l


type 
index_range_aux =  (* index specification, for bitfields in register types *)
   BF_single of int (* single index *)
 | BF_range of int * int (* index range *)
 | BF_concat of index_range * index_range (* concatenation of index ranges *)

and index_range = 
   BF_aux of index_range_aux * l


type 
name_scm_opt = 
   Name_sect_aux of name_scm_opt_aux * l


type 
effect_opt = 
   Effect_opt_aux of effect_opt_aux * l


type 
'a funcl = 
   FCL_aux of 'a funcl_aux * 'a annot


type 
rec_opt = 
   Rec_aux of rec_opt_aux * l


type 
tannot_opt = 
   Typ_annot_opt_aux of tannot_opt_aux * l


type 
'a alias_spec = 
   AL_aux of 'a alias_spec_aux * 'a annot


type 
'a default_spec_aux =  (* Default kinding or typing assumption *)
   DT_kind of base_kind * kid
 | DT_order of order
 | DT_typ of typschm * id


type 
'a type_def_aux =  (* Type definition body *)
   TD_abbrev of id * name_scm_opt * typschm (* type abbreviation *)
 | TD_record of id * name_scm_opt * typquant * ((typ * id)) list * bool (* struct type definition *)
 | TD_variant of id * name_scm_opt * typquant * (type_union) list * bool (* union type definition *)
 | TD_enum of id * name_scm_opt * (id) list * bool (* enumeration type definition *)
 | TD_register of id * nexp * nexp * ((index_range * id)) list (* register mutable bitfield type definition *)


type 
'a val_spec_aux =  (* Value type specification *)
   VS_val_spec of typschm * id
 | VS_extern_no_rename of typschm * id
 | VS_extern_spec of typschm * id * string (* Specify the type and id of a function from Lem, where the string must provide an explicit path to the required function but will not be checked *)


type 
'a kind_def_aux =  (* Definition body for elements of kind; many are shorthands for type\_defs *)
   KD_nabbrev of kind * id * name_scm_opt * nexp (* nexp abbreviation *)
 | KD_abbrev of kind * id * name_scm_opt * typschm (* type abbreviation *)
 | KD_record of kind * id * name_scm_opt * typquant * ((typ * id)) list * bool (* struct type definition *)
 | KD_variant of kind * id * name_scm_opt * typquant * (type_union) list * bool (* union type definition *)
 | KD_enum of kind * id * name_scm_opt * (id) list * bool (* enumeration type definition *)
 | KD_register of kind * id * nexp * nexp * ((index_range * id)) list (* register mutable bitfield type definition *)


type 
'a scattered_def_aux =  (* Function and type union definitions that can be spread across
         a file. Each one must end in $_$ *)
   SD_scattered_function of rec_opt * tannot_opt * effect_opt * id (* scattered function definition header *)
 | SD_scattered_funcl of 'a funcl (* scattered function definition clause *)
 | SD_scattered_variant of id * name_scm_opt * typquant (* scattered union definition header *)
 | SD_scattered_unioncl of id * type_union (* scattered union definition member *)
 | SD_scattered_end of id (* scattered definition end *)


type 
'a fundef_aux =  (* Function definition *)
   FD_function of rec_opt * tannot_opt * effect_opt * ('a funcl) list


type 
'a dec_spec_aux =  (* Register declarations *)
   DEC_reg of typ * id
 | DEC_alias of id * 'a alias_spec
 | DEC_typ_alias of typ * id * 'a alias_spec


type 
'a default_spec = 
   DT_aux of 'a default_spec_aux * l


type 
'a type_def = 
   TD_aux of 'a type_def_aux * 'a annot


type 
'a val_spec = 
   VS_aux of 'a val_spec_aux * 'a annot


type 
'a kind_def = 
   KD_aux of 'a kind_def_aux * 'a annot


type 
'a scattered_def = 
   SD_aux of 'a scattered_def_aux * 'a annot


type 
'a fundef = 
   FD_aux of 'a fundef_aux * 'a annot


type 
'a dec_spec = 
   DEC_aux of 'a dec_spec_aux * 'a annot


type 
'a dec_comm =  (* Top-level generated comments *)
   DC_comm of string (* generated unstructured comment *)
 | DC_comm_struct of 'a def (* generated structured comment *)

and 'a def =  (* Top-level definition *)
   DEF_kind of 'a kind_def (* definition of named kind identifiers *)
 | DEF_type of 'a type_def (* type definition *)
 | DEF_fundef of 'a fundef (* function definition *)
 | DEF_val of 'a letbind (* value definition *)
 | DEF_spec of 'a val_spec (* top-level type constraint *)
 | DEF_default of 'a default_spec (* default kind and type assumptions *)
 | DEF_scattered of 'a scattered_def (* scattered function and type definition *)
 | DEF_reg_dec of 'a dec_spec (* register declaration *)
 | DEF_comm of 'a dec_comm (* generated comments *)


type 
'a defs =  (* Definition sequence *)
   Defs of ('a def) list



