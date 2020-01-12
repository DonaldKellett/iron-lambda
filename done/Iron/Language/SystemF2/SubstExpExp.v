
Require Import Iron.Language.SystemF2.SubstTypeType.
Require Import Iron.Language.SystemF2.SubstTypeExp.
Require Import Iron.Language.SystemF2.TyJudge.


(* Substitution of exps in exps preserves typing *)
Theorem subst_exp_exp_ix
 :  forall ix ke te x1 t1 x2 t2
 ,  get  ix te = Some t2
 -> TYPE ke te           x1 t1
 -> TYPE ke (delete ix te) x2 t2
 -> TYPE ke (delete ix te) (substXX ix x2 x1) t1.
Proof.
 intros. gen ix ke te t1 x2 t2.
 induction x1; intros; inverts_type; simpl; eauto.

 Case "XVar".
  fbreak_nat_compare.
  SCase "n = ix".
   rewrite H in H3. inverts H3. auto.

  SCase "n < ix".
   apply TYVar; auto.

  SCase "n > ix".
   apply TYVar; auto.
   rewrite <- H3.
   destruct n.
    burn.
    simpl. nnat. apply get_delete_below; burn.

 Case "XLAM".
  eapply (IHx1 ix) in H5.
  apply TYLAM.
   unfold liftTE. rewrite map_delete. eauto.
   eapply get_map. eauto.
   unfold liftTE. rewrite <- map_delete.
    apply type_kienv_weaken. auto.

 Case "XLam".
  apply TYLam; auto.
   rewrite delete_rewind.
   eauto using type_tyenv_weaken.
Qed.


Theorem subst_exp_exp
 :  forall ke te x1 t1 x2 t2
 ,  TYPE ke (te :> t2) x1 t1
 -> TYPE ke te x2 t2
 -> TYPE ke te (substXX 0 x2 x1) t1.
Proof.
 intros.
 rrwrite (te = delete 0 (te :> t2)).
 eapply subst_exp_exp_ix; burn.
Qed.
