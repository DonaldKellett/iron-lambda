(* System-F2.
   Like System-F, but with type-type application. *)

(* Kinds and kind environemnts. *)
Require Export Iron.Language.SystemF2.Ki.

(* Type expressions, and functions that operate on them *)
Require Export Iron.Language.SystemF2.TyBase.

(* Lifting of indices in type expressions *)
Require Export Iron.Language.SystemF2.TyLift.

(* Substitution of types in types, and lemmas about it *)
Require Export Iron.Language.SystemF2.TySubst.

(* Simultaneous substitution of types in types, and lemmas about it *)
Require Export Iron.Language.SystemF2.TySubsts.

(* Types, well formed and closed, lifting and substitution lemmas. *)
Require Export Iron.Language.SystemF2.Ty.

(* Type environments, lifting and substitution lemmas. *)
Require Export Iron.Language.SystemF2.TyEnv.

(* Expressions, normal forms, lifting and substitution. *)
Require Export Iron.Language.SystemF2.Exp.

(* Kinds of types, weakening the kind environment. *)
Require Export Iron.Language.SystemF2.KiJudge.

(* Substitution of types in types preserves kinding. *)
Require Export Iron.Language.SystemF2.SubstTypeType.

(* Type Judgement. *)
Require Export Iron.Language.SystemF2.TyJudge.

(* Substitution of types in expressions preserves typing. *)
Require Export Iron.Language.SystemF2.SubstTypeExp.

(* Substitution of expressions in expressions preserves typing. *)
Require Export Iron.Language.SystemF2.SubstExpExp.

(* Small step evaluation. *)
Require Export Iron.Language.SystemF2.Step.

(* A well typed expression is either a value, or can take a step. *)
Require Export Iron.Language.SystemF2.Progress.

(* When an expression takes a step the results has the same type. *)
Require Export Iron.Language.SystemF2.Preservation.

(* Big step evaluation, and conversion to small steps. *)
Require Export Iron.Language.SystemF2.Eval.
