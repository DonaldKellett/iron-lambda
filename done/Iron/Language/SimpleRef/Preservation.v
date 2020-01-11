
Require Import Iron.Language.SimpleRef.Step.
Require Import Iron.Language.SimpleRef.SubstExpExp.
Require Import Iron.Language.SimpleRef.Ty.


(* If a closed, well typed expression takes an evaluation step
   then the result has the same type as before. *)
Theorem preservation
 :  forall se h x h' x' t
 ,  TYPEH se h
 -> TYPE  nil se x  t
 -> STEP  h x h' x'
 -> (exists se', extends se' se
              /\ TYPEH se' h'
              /\ TYPE  nil se' x' t).
Proof.
 intros se h x h' x' t HTH HT HS. gen t.
 induction HS; intros.

 Case "EsContext".
  specializes IHHS HTH.
  destruct H; try
   (inverts HT;
    edestruct IHHS as [se2]; eauto;
    exists se2;
    splits; burn).

 Case "EsLamApp".
  inverts_type.
  exists se. splits; auto.
  eapply subst_exp_exp; eauto.

 Case "EsLamNewRef".
  inverts_type.
  exists (tData <: se). splits.
   eauto.
   eapply Forall2_snoc.
    eapply type_stenv_snoc. auto.
    eapply Forall2_impl.
    eapply type_stenv_snoc. auto.
   eapply TyLoc.
    assert (length h = length se) as HL.
     eapply Forall2_length; eauto.
     rewrite HL. auto.

 Case "EsReadRef".
  inverts_type.
  exists se. splits; auto.
  eapply Forall2_get_get_same; eauto.

 Case "EsWriteRef".
  inverts_type.
  exists se. splits; eauto.
  eapply Forall2_update_right; eauto.
  unfold xUnit.
  unfold tUnit. eauto.
Qed.


(* If a closed, well typed expression takes several evaluation steps
   then the result has the same type as before.
   Usses the left linearised version of steps judement. *)
Lemma preservation_stepsl
 :  forall se h x t h' x'
 ,  TYPEH se h
 -> TYPE  nil se x t
 -> STEPSL h x h' x'
 -> (exists se', extends se' se
              /\ TYPEH se' h'
              /\ TYPE  nil se' x' t).
Proof.
 intros se h x t h' x' HTH HT HS. gen se.
 induction HS; intros.
  Case "EslNone".
   eauto.
  Case "EslCons".
   lets D: preservation HTH HT H.
    destruct D as [se2].
    inverts H0. inverts H2.
   spec IHHS H0 H3.
    destruct IHHS as [se3].
    inverts H2. inverts H5.
    exists se3. splits; auto.
    eapply extends_trans; eauto.
Qed.


(* If a closed, well typed expression takes several evaluation steps
   then the result has the same type as before. *)
Lemma preservation_steps
 :  forall se h x t h' x'
 ,  TYPEH se h
 -> TYPE  nil se x t
 -> STEPS h x h' x'
 -> (exists se', extends se' se
              /\ TYPEH se' h'
              /\ TYPE  nil se' x' t).
Proof.
 intros se h x t h' x' HTH HT HS.
 eapply stepsl_of_steps in HS.
 eapply preservation_stepsl; eauto.
Qed.
