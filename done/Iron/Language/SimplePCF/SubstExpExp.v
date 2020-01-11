
Require Import Iron.Language.SimplePCF.Ty.
Require Export Iron.Language.SimplePCF.Exp.


(* Substitution of expressions in expressions preserves typing.
   Inductively, we must reason about performing substitutions at any
   depth, hence we must prove a property about (subst' d x2 x1) instead
   of the weaker (subst x2 x1) which assumes the substitution is taking
   place at top level. *)
Theorem subst_exp_exp_ix
 :  forall ix te x1 x2 t1 t2
 ,  get  ix te = Some t2
 -> TYPE te           x1 t1
 -> TYPE (delete ix te) x2 t2
 -> TYPE (delete ix te) (substX ix x2 x1) t1.
Proof.
 intros. gen ix te x2 t1.
 induction x1; rip; simpl; inverts H0; eauto.

 Case "XVar".
  fbreak_nat_compare; burn.
  SCase "n > ix".
   eapply TyVar.
   destruct n; burn.
    norm. nnat. down. apply get_delete_below. omega.

 Case "XLam".
  apply TyLam.
  rewrite delete_rewind.
  apply IHx1; burn using type_tyenv_weaken.

 Case "XFix".
  apply TyFix.
  rewrite delete_rewind.
  apply IHx1; burn using type_tyenv_weaken.
Qed.


Theorem subst_exp_exp
 :  forall te x1 x2 t1 t2
 ,  TYPE (te :> t2) x1 t1
 -> TYPE te         x2 t2
 -> TYPE te (substX 0 x2 x1) t1.
Proof.
  intros te x1 x2 t1 t2 Ht1 Ht2.
  lets H: subst_exp_exp_ix 0 (te :> t2).
  burn.
Qed.
