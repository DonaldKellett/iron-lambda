
Require Export Iron.Language.SystemF2Store.TyJudge.
Require Export Iron.Language.SystemF2Store.Exp.
Require Export Iron.Language.SystemF2Store.StoreValue.
Require Export Iron.Language.SystemF2Store.StoreBind.


(********************************************************************)
(* Store typing models the store.
   All types in the store typing have a corresponding binding in
   the store *)
Definition STOREM (ds: defs) (st: stenv) (s: store)
 := length st = length s.
Hint Unfold STOREM.


(********************************************************************)
(* Well typed store. *)
Definition STORET (ds: defs) (st: stenv) (ss: store)
 := forall l dcObj svFields
 ,  get l ss = Some (SObj dcObj svFields)
 -> (exists tcObj tsParam tsFields
    ,  get l st  = Some (makeTApps (TCon tcObj) tsParam)
    /\ hasDef ds (DefData dcObj tsFields tcObj)
    /\ Forall2 (TYPE ds nil nil st)
               (map expOfSValue svFields)
               (map (substTTs 0 tsParam) tsFields)).
Hint Unfold STORET.


(********************************************************************)
(* Well formed store.
   Store is well formed under some data type definitions and a
   store typing. *)
Definition WfS (ds: defs) (se: stenv) (ss: store)
 := DEFSOK ds
 /\ Forall closedT se
 /\ STOREM ds se ss
 /\ STORET ds se ss.
Hint Unfold WfS.

Lemma WfS_defsok
 : forall ds se ss, WfS ds se ss -> DEFSOK ds.
Proof. intros. inverts H. tauto. Qed.
Hint Resolve WfS_defsok.

Lemma WfS_closedT
 : forall ds se ss, WfS ds se ss -> Forall closedT se.
Proof. intros. inverts H. tauto. Qed.
Hint Resolve WfS_closedT.


(********************************************************************)
(* Lemmas about object fields *)

(* For each object in the store, the number of fields
   is the same as what is predicted by the data definition *)
Lemma storet_field_lengths
 :  forall ds dc se s l svs tsFields tObj
 ,  STORET ds se s
 -> get l s   = Some (SObj dc svs)
 -> hasDef ds (DefData dc tsFields tObj)
 -> length svs = length tsFields.
Proof.
 intros.
 unfold STORET in *.
 spec H l dc svs. rip.
  destruct H as [tcObj].
  destruct H as [tsParam].
  destruct H as [tsFields'].
  rip.
  defs_merge.
  have  ( length (map expOfSValue svs)
        = length (map (substTTs 0 tsParam) tsFields)).
  rewrite map_length in H.
  rewrite map_length in H.
 auto.
Qed.
Hint Resolve storet_field_lengths.


(* If we can get an object from the store,
   then we can also get any of the fields specified by its data def *)
Lemma storet_field_has
 :  forall ds s se svs tcObj tsFields i l dc
 ,  STORET ds se s
 -> get l s   = Some (SObj dc svs)
 -> hasDef ds (DefData dc tsFields tcObj)
 -> i < length tsFields
 -> exists svField vField
        ,  get i svs = Some svField
        /\ svalueOf vField svField.
Proof.
 intros.
 have (length svs = length tsFields).
 have (exists svField, get i svs = Some svField)
  by  (eapply get_length_less_exists; rs).
 shift svField.
 have (exists v, svalueOf v svField). eauto.
Qed.


(******************************************************************************)

(* If we can get an objects field,
   then that field has the type determined by the data def and
   store environment *)
Lemma storet_field_type
 :  forall ds se s l i svs vField svField tsParam tcObj tField tsFields dc
 ,  STORET ds se s
 -> get l s          = Some (SObj dc svs)
 -> get l se         = Some (makeTApps (TCon tcObj) tsParam)
 -> get i svs        = Some svField
 -> svalueOf vField svField
 -> hasDef ds (DefData dc tsFields tcObj)
 -> get i tsFields   = Some tField
 -> TYPE ds nil nil se vField (substTTs 0 tsParam tField).
Proof.
 intros.
 have (STORET ds se s).
 unfold STORET in H.
  spec H l dc svs. rip.
  destruct H as [tcObj'].
  destruct H as [tsParam'].
  destruct H as [tsFields'].
  rip. defs_merge.

 have (exists vsFields, Forall2 svalueOf vsFields svs) as HFs.
 destruct HFs as [vsFields].

 have (get i (map expOfSValue svs) = Some vField)
  by  (rw (vField = expOfSValue svField); eauto).

 have (get i (map (substTTs 0 tsParam) tsFields)
       = Some (substTTs 0 tsParam tField)).

 eapply Forall2_get_get_same; eauto.
Qed.


(* If we replace a field in a well typed store with one of the same
   type then the store is still well typed *)
Lemma storet_replace_field
 :  forall ds se s tField tField' vField1 svField1 vField2 svField2 svs i l dc tcObj
           tsFields tsParam
 ,  STORET ds se s
 -> get l s          = Some (SObj dc svs)
 -> get l se         = Some (makeTApps (TCon tcObj) tsParam)
 -> hasDef ds (DefData dc tsFields tcObj)
 -> get i tsFields   = Some tField'
 -> tField           = substTTs 0 tsParam tField'
 -> TYPE ds nil nil se vField1 tField -> svalueOf vField1 svField1
 -> TYPE ds nil nil se vField2 tField -> svalueOf vField2 svField2
 -> get i svs        = Some svField1
 -> STORET ds se (replace l (SObj dc (replace i svField2 svs)) s).
Proof.
 intros.
 unfold STORET in *. rip.

 have (l0 = l \/ l0 <> l) as HL.
 destruct HL.

 Case "l0 = l".
  subst.
  assert (dcObj = dc).
   erewrite replace_get_eq in H10.
   inverts H10. auto. eauto.

  subst.
  spec H H0.
  destruct H as [tcObj'].
  destruct H as [tsParam'].
  destruct H as [tsFields'].
  rip.
  exists tcObj.
  exists tsParam.
  exists tsFields.
  rip. defs_merge.

  have (svFields = replace i svField2 svs)
   by  (erewrite replace_get_eq in H10; eauto;
        inverts H10; auto; subst).

  eapply Forall2_map.
  eapply Forall2_map' in H12.

  have (vField1 = expOfSValue svField1). subst.
  have (vField2 = expOfSValue svField2). subst.

  have (tsFields = replace i tField' tsFields) as HR
   by  (symmetry; eauto). rewrite HR. clear HR.

  eapply Forall2_replace; eauto.

 Case "l0 <> l".
  rewrite replace_get_neq in H10; auto.
Qed.


(********************************************************************)
(* When we extend the store and store typing with a new binding,
   then the resulting store is still well formed. *)
Lemma store_extended_wellformed
 :  forall ds se ss bo to dc svs tc tsParam
 ,  WfS ds se ss
 -> bo = SObj dc svs
 -> to = makeTApps (TCon tc) tsParam
 -> TYPEB ds se bo to
 -> WfS ds (to <: se) (bo <: ss).
Proof.
 intros ds se ss bo to dc svs tc tsParam HW HBO HTO HT.
 subst.

 inverts HT.
 assert (tc0 = tc /\ tsParam0 = tsParam).
  eapply makeTApps_eq_params. eauto. rip. clear H1.

 (* Extended store typing is still closed *)
 assert (Forall closedT (makeTApps (TCon tc) tsParam <: se)).
  assert (Forall closedT tsParam).
   unfold closedT.
   rrwrite (0 = length (@nil ki)).
   eapply kind_wfT_Forall2.
   eauto.
  have (closedT (makeTApps (TCon tc) tsParam))
   by  (eapply makeTApps_wfT; eauto).
  eauto.

 (* Extended store typing models extended store *)
 assert (STOREM ds (makeTApps (TCon tc) tsParam <: se) (SObj dc svs <: ss)).
  unfold STOREM.

  have (length ss = length se)
   by  (unfold WfS in *; burn).

  repeat (rewrite length_simpl_snoc).
  eauto.

 (* Extended store is well typed under extended store typing *)
 assert (STORET ds (makeTApps (TCon tc) tsParam <: se) (SObj dc svs <: ss)).
   inverts HW. rip.
   unfold STORET in *.
   intros.

   assert (l <= length ss) as HL.
    assert (l < length (SObj dc svs <: ss)).
     eauto. rr. omega.

   inverts HL.

   SCase "l = length ss".
    assert (dcObj = dc /\ svFields = svs).
     rr. split; congruence. rip.

    exists tc tsParam tsFields. rip.
    have (length ss = length se) as HL.
     rewrite HL. rr. auto.
    have (xs = map expOfSValue svs) as HV.
    rewrite <- HV.
    eapply (Forall2_impl (TYPE ds nil nil se)); eauto.

   SCase "l < length s".
    assert (get l ss = Some (SObj dcObj svFields)) as HG.
     have (l < length ss).
     rewrite get_length_less_snoc in H9; auto.

    lets D: H10 l dcObj svFields HG. clear H10.
     destruct D as [tcObj].       exists tcObj.
     destruct H10 as [tsParam'].  exists tsParam'.
     destruct H10 as [tsFields']. exists tsFields'.
     rip.

    eapply (Forall2_impl (TYPE ds nil nil se)); eauto.

 (* Build WfS out of previous assertions *)
 inverts HW.
 auto.
Qed.
Hint Resolve store_extended_wellformed.


(********************************************************************)
(* Lemmas about existence of store components from WfS *)

Lemma store_has_sbind_for_stenv
 :  forall ds se ss l tObj
 ,  WfS ds se ss
 -> get l se = Some tObj
 -> (exists dc svs, get l ss = Some (SObj dc svs)).
Proof.
 intros.
 inverts H. rip.
 have (length se = length ss).
 have (exists sb, get l ss = Some sb).
 dest sb. destruct sb. eauto.
Qed.
Hint Resolve store_has_sbind_for_stenv.


Lemma store_has_sbind_for_XLoc
 :  forall ds ke te se ss l tObj
 ,  WfS ds se ss
 -> TYPE ds ke te se (XLoc l) tObj
 -> (exists dc svs, get l ss = Some (SObj dc svs)).
Proof.
 intros.
 inverts keep H. rip.
 inverts_type.
 eauto.
Qed.
Hint Resolve store_has_sbind_for_XLoc.


(* If we have a well typed case match on a store location containing
   some data object, then there is a case alternative corresponding to
   that object's data constructor. *)
Lemma store_has_sbind_for_XLoc_and_alt
 :  forall ds se ss l alts t
 ,  WfS ds se ss
 -> TYPE ds nil nil se (XCase (XLoc l) alts) t
 -> (exists dc, (exists svs, get    l  ss   = Some (SObj dc svs))
            /\  (exists x,   getAlt dc alts = Some (AAlt dc x))).
Proof.
 intros.
 inverts H0.

 have (exists dc svs, get l ss = Some (SObj dc svs)).
  shift dc. split.
  shift svs. auto.
  dest svs.

 eapply getAlt_exists.
 inverts_type.
 nforall.
 inverts H. rip.
 unfold STORET in *.
  spec H12 l dc svs. rip.
  destruct H12 as [tcObj'].
  dest tsParam.
  dest tsFields.
  rip.
  rewrite H7 in H12. inverts H12.
  erewrite getCtorOfType_makeTApps with (tc := tcObj') in H5; eauto.
    inverts H5.
  erewrite getCtorOfType_makeTApps with (tc := tcObj) in H9; eauto.
Qed.
Hint Resolve store_has_sbind_for_XLoc_and_alt.
