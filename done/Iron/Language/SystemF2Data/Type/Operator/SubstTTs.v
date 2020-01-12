
Require Export Iron.Language.SystemF2Data.Base.
Require Export Iron.Language.SystemF2Data.Type.Operator.LiftTT.
Require Export Iron.Language.SystemF2Data.Type.Operator.SubstTT.


(********************************************************************)
Definition substTTs' (ix: nat) (d: nat) (us: list ty) (tt: ty)
 := match get (ix - d) us with
    | Some u => u
    | None   => TVar (ix - length us)
   end.


Fixpoint substTTs (d: nat) (us: list ty) (tt: ty)
 := match tt with
   |  TVar ix
   => match nat_compare ix d with
      | Lt => TVar ix
      | _  => substTTs' ix d us tt
      end

   |  TCon _
   => tt

   |  TForall t
   => TForall (substTTs (S d) (map (liftTT 1 0) us) t)

   |  TApp t1 t2
   => TApp (substTTs d us t1) (substTTs d us t2)
   end.


(********************************************************************)
Lemma substTTs_nil
 :  forall n t
 ,  substTTs n nil t = t.
Proof.
 intros. gen n.
 induction t; intros;
  try (solve [snorm; f_equal; try burn]).

 - Case "TVar".
   subst.
   snorm; lift_cases; auto; unfold substTTs'; snorm; lift_cases; burn.
Qed.
Hint Rewrite substTTs_nil : global.


Lemma substTTs_makeTApps
 :  forall d us t1 ts
 ,  substTTs d us (makeTApps t1 ts)
 =  makeTApps (substTTs d us t1) (map (substTTs d us) ts).
Proof.
 intros. gen d us t1.
 induction ts; f_equal; try burn.
 - snorm. rewritess. snorm.
Qed.
Hint Rewrite substTTs_makeTApps : global.


(********************************************************************)
(* Lifting after substitution *)
Lemma liftTT_substTTs_1
 :  forall n n' t1 us
 ,  liftTT 1 n (substTTs (n + n') us t1)
 =  substTTs (1 + n + n') (map (liftTT 1 n) us) (liftTT 1 n t1).
Proof.
 intros. gen n n' us.
 induction t1; intros; try burn.

 - Case "TVar".
   snorm; induction us; snorm;
    try omega;
    try solve [unfold substTTs'; snorm; omega].

    unfold substTTs'; snorm; lists; auto; try omega.

   + f_equal. rewrite HeqH4. omega.
   + f_equal. omega.

 - Case "TForall".
   simpl. f_equal.
   induction us.
   + simpl.
     rrwrite (S (n + n') = (S n) + n').
     burn.
   + simpl.
     rewrite (liftTT_liftTT_11 0 n). simpl.
     rewrite (IHt1 (S n) n').
     f_equal. simpl. f_equal.
      lists. f_equal. extensionality x.
      symmetry.
      rrwrite (n = n + 0).
      eapply liftTT_liftTT.

 - Case "TApp".
   simpl.
   rewrite IHt1_1.
   rewrite IHt1_2. eauto.
Qed.


Lemma liftTT_substTTs
 :  forall m n n' t1 us
 ,  liftTT m n (substTTs (n + n') us t1)
 =  substTTs (m + n + n') (map (liftTT m n) us) (liftTT m n t1).
Proof.
 intros. gen n n'.
 induction m; intros.
  simpl. rr.
   f_equal.
   rewrite (@map_impl ty ty (liftTT 0 n) id).
    induction us; try burn.
    simpl. rewrite <- IHus. auto.
    burn.

  simpl.
  rrwrite (S m = 1 + m).
  rewrite <- liftTT_plus.
  rewrite IHm.
  simpl.
  rrwrite (m + n + n' = n + (m + n')) by omega.
  rewrite liftTT_substTTs_1.
  f_equal.
   lists. f_equal.
    extensionality x; burn.
    burn.
Qed.
Hint Rewrite <- liftTT_substTTs : global.


(********************************************************************)
(* Lifting after substitution,
   with the lifting at a higher index *)
Lemma liftTT_substTTs_nonempty_env
 :  forall n n' t1 us
 ,  length us > 0
 -> liftTT 1 (n' + n) (substTTs n us t1)
 =  substTTs n (map (liftTT 1 (n' + n)) us)
               (liftTT 1 (length us + n' + n) t1).
Proof.
 intros. gen n n' us.
 induction t1; intros; try burn.

 - Case "TVar".
   repeat (simpl; unfold substTTs'; lift_cases);
     try auto;
     try (false; omega);
     try (lists; auto);
     try (lists; omega);
     (f_equal; omega).

 - Case "TForall".
   simpl. f_equal.
   rrwrite (S (n' + n) = n' + S n).
   erewrite IHt1.
   + f_equal.
     * lists. f_equal. extensionality x.
       rrwrite (n' + S n = 1 + (n' + n) + 0).
       rewrite <- liftTT_liftTT. snorm.
     * lists; burn.
   + lists; burn.

 - Case "TApp".
   snorm. rewritess; auto.
Qed.



Lemma liftTT_substTTs'
 :  forall n n' t1 us
 ,  liftTT 1 (n' + n) (substTTs n us t1)
 =  substTTs n (map (liftTT 1 (n' + n)) us)
               (liftTT 1 (length us + n' + n) t1).
Proof.
 intros.
 destruct us.
 - burn.
 - simpl. apply liftTT_substTTs_nonempty_env; burn.
Qed.
Hint Rewrite <- liftTT_substTTs' : global.


Lemma liftTT_map_substTT
 :  forall m n n' ts t2
 ,  map (liftTT m n) (map (substTT (n + n') t2) ts)
 =  map (substTT (m + n + n') (liftTT m n t2)) (map (liftTT m n) ts).
Proof.
 induction ts; snorm; rewritess; burn.
Qed.
Hint Rewrite <- liftTT_map_substTT : global.


(* Substitution for an index that is not referenced by the type is identity *)
Lemma substTT_unbound
 :  forall t1 t2 ix tn m
 ,  wfT tn t1
 -> ix >= tn
 -> substTT ix (liftTT 1 m t2) t1 = t1.
Proof.
 intros. gen t2 ix tn m.
 induction t1; intros; simpl; inverts H; auto.

 - Case "TVar".
   lift_cases; try omega; burn.

 - Case "TForall".
   erewrite IHt1; burn.

 - Case "TApp".
   f_equal; eauto.
Qed.


(* Substitution into a closed type is identity *)
Lemma substTT_closed
 :  forall ix t1 t2
 ,  closedT t1
 -> substTT ix t2 t1 = t1.
Proof.
 intros.
 have (exists n, wfT n t2). dest n.

 assert (exists n, liftTT 1 n t2 = t2).
  exists n. eauto.
  rrwrite (n = n + 0).
  apply liftTT_wfT_1. snorm. auto.
  destruct H1 as [n'].

 rewrite <- H1.
 eapply substTT_unbound; burn.
Qed.


Lemma substTTs_closing'
 :  forall ts t1 tn n
 ,  Forall (wfT (tn + n)) ts
 -> wfT (length ts + n) t1
 -> wfT (tn + n) (substTTs n ts t1).
Proof.
 intros. gen n tn ts.
 induction t1; intros; inverts H0; unfold closedT; try burn.

 - Case "TVar".
   simpl; lift_cases; eauto.
   + unfold substTTs'.
     lift_cases.
     * lists.
     * eapply WfT_TVar. lists. omega.
   + unfold substTTs'.
     lift_cases.
     * lists.
     * eapply WfT_TVar. lists. omega.

 - Case "TForall".
   eapply WfT_TForall.
   rrwrite (S (tn + n) = tn + (S n)).
   eapply IHt1.
   + eapply Forall_map.
     repeat nforall.
     intros.
     have (wfT (tn + n) x).
     rrwrite (tn + S n = S (tn + n)).
     auto.
   + lists.
     rrwrite (S (length ts + n) = length ts + (S n)) in H2.
     burn.

 - Case "TApp".
   eapply WfT_TApp; snorm.
Qed.
Hint Resolve substTTs_closing'.


Lemma substTTs_closing
 :  forall tn ts t1
 ,  Forall (wfT tn) ts
 -> wfT (length ts) t1
 -> wfT tn (substTTs 0 ts t1).
Proof.
 intros.
 rrwrite (tn = tn + 0).
 eapply substTTs_closing'; snorm.
Qed.
Hint Resolve substTTs_closing.


Lemma substTTs_liftTT
 :   forall ts t1 n n' m
 ,   wfT (length ts + n) t1
 ->  substTTs n (map (liftTT m (n + n')) ts) t1
 =   liftTT m (n + n') (substTTs n ts t1).
Proof.
 intros. gen ts n n' m.
 induction t1; intros; inverts H; try burn.

 - Case "TVar".
   repeat (simpl; unfold substTTs'; lift_cases);
    try auto;
    try (false; omega);
    try (lists; burn);
    try (f_equal; omega).

 - Case "TForall".
   simpl. f_equal.
   rrwrite (n + n' = (n + n') + 0).
   rewrite liftTT_map_liftTT.
   norm.
   rrwrite (1 + (n + n') = S n + n').
   rewrite IHt1. eauto.
   lists.
   rrwrite (length ts + S n = S (length ts + n)).
   eauto.

 - Case "TApp".
   simpl. f_equal; auto.
Qed.


Lemma substTTs_substTT
 :   forall ts t1 t2 n n'
 ,   wfT (length ts + n) t1
 ->  substTTs n (map (substTT (n + n') t2) ts) t1
 =   substTT (n + n') t2 (substTTs n ts t1).
Proof.
 intros. gen ts n n' t2.
 induction t1; intros; inverts H; try burn.

 - Case "TVar".
   repeat (simpl; unfold substTTs'; lift_cases);
    try auto;
    try (false; omega);
    try (lists; burn);
    try (lists; omega).

 - Case "TForall".
   simpl. f_equal.
   rrwrite (n + n' = 0 + (n + n')).
   rewrite liftTT_map_substTT.
   nnat.
   rrwrite (1 + (n + n') = S n + n').
   rrwrite (S (0 + (n + n')) = 1 + n + n').
   rewrite IHt1. burn.
   lists.
   rrwrite (length ts + S n = S (length ts + n)). auto.

 - Case "TApp".
   snorm. f_equal; eauto.
Qed.


Lemma substTTs_substTT_map
 :  forall n n' ts1 t2 ts3
 ,  Forall (wfT (length ts1 + n)) ts3
 -> map (substTTs n (map (substTT (n + n') t2) ts1)) ts3
 =  map (substTT (n + n') t2) (map (substTTs n ts1) ts3).
Proof.
 intros.
 induction ts3.
 - auto.
 - inverts H.
   simpl. rewrite IHts3; eauto. f_equal.
   eapply substTTs_substTT; eauto.
Qed.
