(* System-F2 with Algebraic Data Types *)


(********************************************************************)
(* Shared with SystemF2 *)

(* Kinds and kind environemnts. *)
Require Export Iron.Language.SystemF2.Ki.

(* Types, well formed and closed, lifting and substitution lemmas. *)
Require Export Iron.Language.SystemF2.Ty.

(* Kinds of types, weakening the kind environment. *)
Require Export Iron.Language.SystemF2.KiJudge.

(* Type environments, lifting and substitution lemmas. *)
Require Export Iron.Language.SystemF2.TyEnv.

(* Substitution of types in types preserves kinding. *)
Require Export Iron.Language.SystemF2.SubstTypeType.


(********************************************************************)
Require Export Iron.Language.SystemF2Store.Def.

(* Expressions and induction principle *)
Require Export Iron.Language.SystemF2Store.ExpBase.

(* Utils for working with case alternative *)
Require Export Iron.Language.SystemF2Store.ExpAlt.

(* Lifting and lifting lemmas for expressions *)
Require Export Iron.Language.SystemF2Store.ExpLift.

(* Substitution for expressions *)
Require Export Iron.Language.SystemF2Store.ExpSubst.

(* Expressions, normal forms, lifting and substitution. *)
Require Export Iron.Language.SystemF2Store.Exp.

(* Type Judgement. *)
Require Export Iron.Language.SystemF2Store.TyJudge.

(* Substitution of types in expressions preserves typing. *)
Require Export Iron.Language.SystemF2Store.SubstTypeExp.

(* Substitution of expressions in expressions preserves typing. *)
Require Export Iron.Language.SystemF2Store.SubstExpExp.

(* Small step evaluation contexts *)
Require Export Iron.Language.SystemF2Store.StepContext.

(* Stores. *)
Require Export Iron.Language.SystemF2Store.StoreValue.
Require Export Iron.Language.SystemF2Store.StoreBind.
Require Export Iron.Language.SystemF2Store.Store.

(* Small step evaluation. *)
Require Export Iron.Language.SystemF2Store.Step.

(* A well typed expression is either a value, or can take a step. *)
Require Export Iron.Language.SystemF2Store.Progress.

(* When an expression takes a step the results has the same type. *)
Require Export Iron.Language.SystemF2Store.Preservation.
