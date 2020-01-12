
Require Import Iron.Language.SystemF2.SubstTypeType.
Require Import Iron.Language.SystemF2.TyJudge.


Theorem subst_type_exp_ix
 :  forall ix ke te x1 t1 t2 k2
 ,  get ix ke = Some k2
 -> TYPE ke  te x1 t1
 -> KIND (delete ix ke)  t2 k2
 -> TYPE (delete ix ke)     (substTE ix t2 te)
         (substTX ix t2 x1) (substTT ix t2 t1).
Proof.
 intros. gen ix ke te t1 t2 k2.
 induction x1; intros; simpl; inverts_type; eauto.

 Case "XVar".
  apply TYVar.
  unfold substTE. auto.
  eapply subst_type_type_ix; eauto.

 Case "XLAM".
  simpl. apply TYLAM.
  rewrite delete_rewind.
  rewrite (liftTE_substTE 0 ix).
  eauto using kind_kienv_weaken.

 Case "XAPP".
  rewrite (substTT_substTT 0 ix).
  eauto using subst_type_type_ix.
  apply TYAPP.
   simpl. eapply (IHx1 ix) in H6; eauto.
   simpl. eapply subst_type_type_ix; eauto.

 Case "XLam".
  simpl. apply TYLam.
  eapply subst_type_type_ix; eauto.
  unfold substTE. rewrite map_rewind.
  rrwrite ( map (substTT ix t2) (te :> t)
         = substTE ix t2 (te :> t)).
  burn.

 Case "XApp".
  eapply TYApp.
   eapply IHx1_1 in H6; eauto.
    simpl in H6. burn.
   eapply IHx1_2 in H8; eauto.
Qed.


Theorem subst_type_exp
 :  forall ke te x1 t1 t2 k2
 ,  TYPE (ke :> k2) te x1 t1
 -> KIND ke  t2 k2
 -> TYPE ke (substTE 0 t2 te) (substTX 0 t2 x1) (substTT 0 t2 t1).
Proof.
 intros.
 rrwrite (ke = delete 0 (ke :> k2)).
 eapply subst_type_exp_ix; burn.
Qed.
