
Require Import Iron.Language.SystemF2.SubstTypeType.
Require Import Iron.Language.SystemF2Store.SubstTypeExp.
Require Import Iron.Language.SystemF2Store.TyJudge.


(* Substitution of exps in exps preserves typing *)
Theorem subst_exp_exp_ix
 :  forall ix ds ke te se x1 t1 x2 t2
 ,  get  ix te = Some t2
 -> TYPE ds ke te             se x1 t1
 -> TYPE ds ke (delete ix te) se x2 t2
 -> TYPE ds ke (delete ix te) se (substXX ix x2 x1) t1.
Proof.
 intros. gen ix ds ke te se t1 x2 t2.
 induction x1 using exp_mutind with
  (PA := fun a1 => forall ix ds ke te se x2 t11 t12 t2
      ,  get ix te = Some t2
      -> TYPEA ds ke te             se a1 t11 t12
      -> TYPE  ds ke (delete ix te) se x2 t2
      -> TYPEA ds ke (delete ix te) se (substXA ix x2 a1) t11 t12)
  ; intros; simpl; inverts_type; eauto.

 Case "XVar".
  fbreak_nat_compare.
  SCase "n = ix".
   have (t2 = t1) by congruence. subst.
   auto.

  SCase "n < ix".
   apply TyVar; auto.

  SCase "n > ix".
   apply TyVar; auto.
   rewrite <- H4.
   destruct n.
    burn.
    simpl. nnat. apply get_delete_below; burn.

 Case "XLAM".
  simpl.
  eapply (IHx1 ix) in H3.
  apply TyLAM.
   unfold liftTE. rewrite map_delete. eauto.
   eapply get_map. eauto.
   unfold liftTE. rewrite <- map_delete.
    rrwrite (map (liftTT 1 0) (delete ix te) = liftTE 0 (delete ix te)).
    apply type_kienv_weaken1. auto.

 Case "XLam".
  simpl.
  apply TyLam; auto.
   rewrite delete_rewind.
   eauto using type_tyenv_weaken1.

 Case "XCon".
  eapply TyCon; eauto.
   nforall.
   apply (Forall2_map_left (TYPE ds ke (delete ix te) se)).
   apply (Forall2_impl_in  (TYPE ds ke te se)); eauto.

 Case "XCase".
  eapply TyCase; eauto.
   clear IHx1.
   (* Alts have correct type *)
    eapply Forall_map.
    repeat nforall. eauto.

   (* Required datacon is in alts list *)
   repeat nforall. intros.
   rename x into d. lists.
   apply in_map_iff.
   have (exists a, dcOfAlt a = d /\ In a aa).
    shift a. rip.
   rewrite dcOfAlt_substXA; auto.

 Case "AAlt".
  have (DEFOK ds (DefData dc tsFields tc)).
  destruct dc. inverts H0.

  eapply TyAlt; eauto.
  rewrite delete_app.
  lists.
  assert ( length tsFields
         = length (map (substTTs 0 tsParam) tsFields)) as HL
   by (lists; auto).
  eapply IHx1 with (t2 := t2); eauto.
  rewrite HL. eauto. rs.
  rewrite <- delete_app.
  eauto using type_tyenv_weaken_append.
Qed.


Theorem subst_exp_exp
 :  forall ds ke te se x1 t1 x2 t2
 ,  TYPE ds ke (te :> t2) se x1 t1
 -> TYPE ds ke te se x2 t2
 -> TYPE ds ke te se (substXX 0 x2 x1) t1.
Proof.
 intros.
 rrwrite (te = delete 0 (te :> t2)).
 eapply subst_exp_exp_ix; burn.
Qed.


(* Substitution of several expressions at once. *)
Theorem subst_exp_exp_list
 :  forall ds ks te se x1 xs t1 ts
 ,  Forall2 (TYPE ds ks te se) xs ts
 -> TYPE ds ks (te >< ts) se x1 t1
 -> TYPE ds ks te         se (substXXs 0 xs x1) t1.
Proof.
 intros ds ks te se x1 xs t1 ts HF HT.
 gen ts ks x1.
 induction xs; intros; inverts_type.

 Case "base case".
  destruct ts.
   simpl. auto.
   nope.

 Case "step case".
  simpl.
   destruct ts.
    nope.
    inverts HF.
     eapply IHxs. eauto.
     simpl in HT.
     eapply subst_exp_exp. eauto.
     rw (length xs = length ts).
     eapply type_tyenv_weaken_append. auto.
Qed.
