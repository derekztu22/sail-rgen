(****************************************************************************)
(*     Sail                                                                 *)
(*                                                                          *)
(*  Sail and the Sail architecture models here, comprising all files and    *)
(*  directories except the ASL-derived Sail code in the aarch64 directory,  *)
(*  are subject to the BSD two-clause licence below.                        *)
(*                                                                          *)
(*  The ASL derived parts of the ARMv8.3 specification in                   *)
(*  aarch64/no_vector and aarch64/full are copyright ARM Ltd.               *)
(*                                                                          *)
(*  Copyright (c) 2013-2021                                                 *)
(*    Kathyrn Gray                                                          *)
(*    Shaked Flur                                                           *)
(*    Stephen Kell                                                          *)
(*    Gabriel Kerneis                                                       *)
(*    Robert Norton-Wright                                                  *)
(*    Christopher Pulte                                                     *)
(*    Peter Sewell                                                          *)
(*    Alasdair Armstrong                                                    *)
(*    Brian Campbell                                                        *)
(*    Thomas Bauereiss                                                      *)
(*    Anthony Fox                                                           *)
(*    Jon French                                                            *)
(*    Dominic Mulligan                                                      *)
(*    Stephen Kell                                                          *)
(*    Mark Wassell                                                          *)
(*    Alastair Reid (Arm Ltd)                                               *)
(*                                                                          *)
(*  All rights reserved.                                                    *)
(*                                                                          *)
(*  This work was partially supported by EPSRC grant EP/K008528/1 <a        *)
(*  href="http://www.cl.cam.ac.uk/users/pes20/rems">REMS: Rigorous          *)
(*  Engineering for Mainstream Systems</a>, an ARM iCASE award, EPSRC IAA   *)
(*  KTF funding, and donations from Arm.  This project has received         *)
(*  funding from the European Research Council (ERC) under the European     *)
(*  Union’s Horizon 2020 research and innovation programme (grant           *)
(*  agreement No 789108, ELVER).                                            *)
(*                                                                          *)
(*  This software was developed by SRI International and the University of  *)
(*  Cambridge Computer Laboratory (Department of Computer Science and       *)
(*  Technology) under DARPA/AFRL contracts FA8650-18-C-7809 ("CIFV")        *)
(*  and FA8750-10-C-0237 ("CTSRD").                                         *)
(*                                                                          *)
(*  SPDX-License-Identifier: BSD-2-Clause                                   *)
(****************************************************************************)

open Ast
open Ast_defs
open Ast_util

let funcl_id (FCL_aux (FCL_funcl (id, _), _)) = id

let rec last_scattered_funcl id = function
  | DEF_aux (DEF_scattered (SD_aux (SD_funcl funcl, _)), _) :: _ when Id.compare (funcl_id funcl) id = 0 -> false
  | _ :: defs -> last_scattered_funcl id defs
  | [] -> true

let rec last_scattered_mapcl id = function
  | DEF_aux (DEF_scattered (SD_aux (SD_mapcl (mid, _), _)), _) :: _ when Id.compare mid id = 0 -> false
  | _ :: defs -> last_scattered_mapcl id defs
  | [] -> true

(* Nothing cares about these and the AST should be changed *)
let fake_rec_opt l = Rec_aux (Rec_nonrec, gen_loc l)

let no_tannot_opt l = Typ_annot_opt_aux (Typ_annot_opt_none, gen_loc l)

let rec get_union_records id acc = function
  | DEF_aux (DEF_scattered (SD_aux (SD_internal_unioncl_record (uid, record_id, typq, fields), annot)), def_annot)
    :: defs
    when Id.compare uid id = 0 ->
      let def = DEF_aux (DEF_type (TD_aux (TD_record (record_id, typq, fields, false), annot)), def_annot) in
      get_union_records id (def :: acc) defs
  | def :: defs -> get_union_records id acc defs
  | [] -> acc

let rec filter_union_clauses id = function
  | DEF_aux (DEF_scattered (SD_aux (SD_unioncl (uid, _), _)), _) :: defs when Id.compare id uid = 0 ->
      filter_union_clauses id defs
  | DEF_aux (DEF_scattered (SD_aux (SD_internal_unioncl_record (uid, _, _, _), _)), _) :: defs
    when Id.compare id uid = 0 ->
      filter_union_clauses id defs
  | def :: defs -> def :: filter_union_clauses id defs
  | [] -> []

let rec filter_enum_clauses id = function
  | DEF_aux (DEF_scattered (SD_aux (SD_enumcl (uid, _), _)), _) :: defs when Id.compare id uid = 0 ->
      filter_enum_clauses id defs
  | def :: defs -> def :: filter_enum_clauses id defs
  | [] -> []

let patch_funcl_loc def_annot (FCL_aux (aux, (_, tannot))) =
  FCL_aux (aux, (Type_check.strip_def_annot def_annot, tannot))

let patch_mapcl_annot def_annot (MCL_aux (aux, (_, tannot))) =
  MCL_aux (aux, (Type_check.strip_def_annot def_annot, tannot))

let rec descatter' annots accumulator funcls mapcls = function
  (* For scattered functions we collect all the seperate function
     clauses until we find the last one, then we turn that function
     clause into a DEF_fundef containing all the clauses. *)
  | DEF_aux (DEF_scattered (SD_aux (SD_function (id, _), _)), def_annot) :: defs ->
      descatter' (Bindings.add id def_annot annots) accumulator funcls mapcls defs
  | DEF_aux (DEF_scattered (SD_aux (SD_funcl funcl, (l, tannot))), def_annot) :: defs
    when last_scattered_funcl (funcl_id funcl) defs ->
      let funcl = patch_funcl_loc def_annot funcl in
      let clauses =
        match Bindings.find_opt (funcl_id funcl) funcls with
        | Some clauses -> List.rev (funcl :: clauses)
        | None -> [funcl]
      in
      let clauses, update_attr =
        Type_check.(check_funcls_complete l (env_of_tannot tannot) clauses (typ_of_tannot tannot))
      in
      let def_annot =
        Option.value ~default:(mk_def_annot (gen_loc l) def_annot.env) (Bindings.find_opt (funcl_id funcl) annots)
      in
      let accumulator =
        DEF_aux
          ( DEF_fundef (FD_aux (FD_function (fake_rec_opt l, no_tannot_opt l, clauses), (gen_loc l, tannot))),
            update_attr def_annot
          )
        :: accumulator
      in
      descatter' annots accumulator funcls mapcls defs
  | DEF_aux (DEF_scattered (SD_aux (SD_funcl funcl, _)), def_annot) :: defs ->
      let id = funcl_id funcl in
      let funcl = patch_funcl_loc def_annot funcl in
      begin
        match Bindings.find_opt id funcls with
        | Some clauses -> descatter' annots accumulator (Bindings.add id (funcl :: clauses) funcls) mapcls defs
        | None -> descatter' annots accumulator (Bindings.add id [funcl] funcls) mapcls defs
      end
  (* Scattered mappings are handled the same way as scattered functions *)
  | DEF_aux (DEF_scattered (SD_aux (SD_mapping (id, _), _)), def_annot) :: defs ->
      descatter' (Bindings.add id def_annot annots) accumulator funcls mapcls defs
  | DEF_aux (DEF_scattered (SD_aux (SD_mapcl (id, mapcl), (l, tannot))), def_annot) :: defs
    when last_scattered_mapcl id defs ->
      let mapcl = patch_mapcl_annot def_annot mapcl in
      let clauses =
        match Bindings.find_opt id mapcls with Some clauses -> List.rev (mapcl :: clauses) | None -> [mapcl]
      in
      let def_annot = Option.value ~default:(mk_def_annot (gen_loc l) def_annot.env) (Bindings.find_opt id annots) in
      let accumulator =
        DEF_aux (DEF_mapdef (MD_aux (MD_mapping (id, no_tannot_opt l, clauses), (gen_loc l, tannot))), def_annot)
        :: accumulator
      in
      descatter' annots accumulator funcls mapcls defs
  | DEF_aux (DEF_scattered (SD_aux (SD_mapcl (id, mapcl), _)), def_annot) :: defs ->
      let mapcl = patch_mapcl_annot def_annot mapcl in
      begin
        match Bindings.find_opt id mapcls with
        | Some clauses -> descatter' annots accumulator funcls (Bindings.add id (mapcl :: clauses) mapcls) defs
        | None -> descatter' annots accumulator funcls (Bindings.add id [mapcl] mapcls) defs
      end
  (* For scattered unions, when we find a union declaration we
     immediately grab all the future clauses and turn it into a
     regular union declaration. *)
  | DEF_aux (DEF_scattered (SD_aux (SD_variant (id, typq), (l, _))), def_annot) :: defs ->
      let tus = get_scattered_union_clauses id defs in
      let records = get_union_records id [] defs in
      begin
        match tus with
        | [] -> raise (Reporting.err_general l "No clauses found for scattered union type")
        | _ ->
            let accumulator =
              DEF_aux
                (DEF_type (TD_aux (TD_variant (id, typq, tus, false), (gen_loc l, Type_check.empty_tannot))), def_annot)
              :: records
              @ accumulator
            in
            descatter' annots accumulator funcls mapcls (filter_union_clauses id defs)
      end
  (* Therefore we should never see SD_unioncl... *)
  | DEF_aux (DEF_scattered (SD_aux (SD_unioncl _, (l, _))), _) :: _ ->
      raise (Reporting.err_unreachable l __POS__ "Found union clause during de-scattering")
  | DEF_aux (DEF_scattered (SD_aux (SD_enum id, (l, _))), def_annot) :: defs ->
      let members = get_scattered_enum_clauses id defs in
      begin
        match members with
        | [] -> raise (Reporting.err_general l "No clauses found for scattered enum type")
        | _ ->
            let def_annot =
              def_annot
              |> add_def_attribute (gen_loc l) "no_enum_number_conversions" None
              |> add_def_attribute (gen_loc l) "undefined_gen" (Some (AD_aux (AD_string "forbid", gen_loc l)))
            in
            let accumulator =
              DEF_aux (DEF_type (TD_aux (TD_enum (id, members, false), (gen_loc l, Type_check.empty_tannot))), def_annot)
              :: accumulator
            in
            descatter' annots accumulator funcls mapcls (filter_enum_clauses id defs)
      end
  | def :: defs -> descatter' annots (def :: accumulator) funcls mapcls defs
  | [] -> List.rev accumulator

let descatter ast = { ast with defs = descatter' Bindings.empty [] Bindings.empty Bindings.empty ast.defs }
