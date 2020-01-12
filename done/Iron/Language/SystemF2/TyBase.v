
Require Export Iron.Language.SystemF2.Ki.


(********************************************************************)
(* Type Constructors. *)
Inductive tycon : Type :=
 | TyConFun  : tycon
 | TyConData : nat   -> ki -> tycon.
Hint Constructors tycon.


Fixpoint tycon_beq t1 t2 :=
 match t1, t2 with
 | TyConFun,       TyConFun       => true
 | TyConData n1 _, TyConData n2 _ => beq_nat n1 n2
 | _,              _              => false
 end.


Definition isTyConFun  (tc: tycon) : Prop :=
 match tc with
 | TyConFun      => True
 | TyConData _ _ => False
 end.
Hint Unfold isTyConFun.


Definition isTyConData (tc: tycon) : Prop :=
 match tc with
 | TyConFun      => False
 | TyConData _ _ => True
 end.
Hint Unfold isTyConData.


(********************************************************************)
(* Type Expressions. *)
Inductive ty  : Type :=
 | TCon      : tycon -> ty
 | TVar      : nat   -> ty
 | TForall   : ty    -> ty
 | TApp      : ty    -> ty -> ty.
Hint Constructors ty.


(********************************************************************)
(* Type Utils *)

(* Get the type constructor of a type, if any *)
Fixpoint getCtorOfType (tt: ty) : option tycon :=
 match tt with
 | TCon tc   => Some tc
 | TApp t1 _ => getCtorOfType t1
 | _         => None
 end.


(* Construct a type application from a constructor type
   and a list of argument types. *)
Fixpoint makeTApps (t1: ty) (tt: list ty) : ty :=
 match tt with
 | nil     => t1
 | t :: ts => makeTApps (TApp t1 t) ts
 end.


Fixpoint takeTCon (tt: ty) : ty :=
 match tt with
 | TApp t1 t2 => takeTCon t1
 | _          => tt
 end.

Fixpoint takeTArgs (tt: ty) : list ty :=
 match tt with
 | TApp t1 t2 => snoc t2 (takeTArgs t1)
 | _          => cons tt nil
 end.


(* Break apart a type application into the constructor type
   and a list of argument types. *)
Definition takeTApps (tt: ty) : (ty * list ty)
 := (takeTCon tt, takeTArgs tt).



Lemma makeTApps_snoc
 : forall t1 t2 t3 ts
 , makeTApps (TApp t1 t2) (snoc t3 ts)
 = TApp (makeTApps t1 (cons t2 ts)) t3.
Proof.
 intros. gen t1 t2.
 induction ts; simpl; burn.
Qed.


Lemma makeTApps_snoc'
 :  forall t1 t2 ts
 ,  makeTApps t1 (snoc t2 ts)
 =  TApp (makeTApps t1 ts) t2.
Proof.
 intros. gen t1 t2.
 induction ts; intros.
  auto.
  simpl. auto.
Qed.


Lemma takeTCon_makeTApps
 :  forall t1 ts
 ,  takeTCon (makeTApps t1 ts) = takeTCon t1.
Proof.
 intros. gen t1.
 induction ts; intros; simpl; auto.
  rewrite IHts. burn.
Qed.
Hint Resolve takeTCon_makeTApps.


Lemma makeTApps_takeTCon
 :  forall t1 t2 ts
 ,  makeTApps t1 ts = t2
 -> takeTCon t1     = takeTCon t2.
Proof.
 intros. gen t1 t2.
 induction ts; intros.
  simpl in H. subst. auto.
  eapply IHts in H. simpl in H. auto.
Qed.
Hint Resolve makeTApps_takeTCon.


Lemma getCtorOfType_makeTApps
 :  forall tc t1 ts
 ,  getCtorOfType t1 = Some tc
 -> getCtorOfType (makeTApps t1 ts) = Some tc.
Proof.
 intros. gen t1.
 induction ts; intros.
  auto. rs.
Qed.
Hint Resolve getCtorOfType_makeTApps.


Lemma makeTApps_rewind
 :  forall t1 t2 ts
 ,  makeTApps (TApp t1 t2) ts = makeTApps t1 (t2 :: ts).
Proof. intros. auto. Qed.


Lemma makeTApps_tycon_eq
 :  forall tc1 tc2 ts1 ts2
 ,  makeTApps (TCon tc1) ts1 = makeTApps (TCon tc2) ts2
 -> tc1 = tc2.
Proof.
 intros.
 assert ( takeTCon (makeTApps (TCon tc1) ts1)
        = takeTCon (makeTApps (TCon tc2) ts2)) as HT by rs.
 repeat (rewrite takeTCon_makeTApps in HT).
 simpl in HT. inverts HT. auto.
Qed.


Lemma makeTApps_args_eq
 :  forall tc ts1 ts2
 ,  makeTApps (TCon tc) ts1  = makeTApps (TCon tc) ts2
 -> ts1 = ts2.
Proof.
 intros. gen ts2.
 induction ts1 using rev_ind; intros.
  Case "ts1 = nil".
   simpl in H.
   destruct ts2.
    SCase "ts2 ~ nil".
     auto.

    SCase "ts2 ~ cons".
    simpl in H.
    lets D: @snocable ty ts2. inverts D.
     simpl in H. nope.
     destruct H0 as [t2].
     destruct H0 as [ts2'].
     subst.
     rewrite makeTApps_snoc in H. nope.

  Case "ts1 ~ snoc".
   lets D: @snocable ty ts2. inverts D.
   SCase "ts2 ~ nil".
    simpl in H.
    rewrite app_snoc in H.
    rewrite app_nil_right in H.
    rewrite makeTApps_snoc' in H.
    nope.

   SCase "ts2 ~ snoc" .
    dest t. dest ts'. subst.
    rewrite app_snoc in H.
    rewrite app_snoc. rr.
    rewrite makeTApps_snoc' in H.
    rewrite makeTApps_snoc' in H.
    inverts H.
    eapply IHts1 in H1. subst.
    auto.
Qed.


Lemma makeTApps_eq_params
 : forall tc1 tc2 ts1 ts2
 ,  makeTApps (TCon tc1) ts1 = makeTApps (TCon tc2) ts2
 -> tc1 = tc2 /\ ts1 = ts2.
Proof.
 intros.
 assert (tc1 = tc2).
  eapply makeTApps_tycon_eq; eauto.
  subst.
 assert (ts1 = ts2).
  eapply makeTApps_args_eq; eauto.
  subst.
 auto.
Qed.


(********************************************************************)
(* Well formed types are closed under the given kind environment. *)
Inductive wfT (kn: nat) : ty -> Prop :=
 | WfT_TVar
   :  forall ki
   ,  ki < kn
   -> wfT kn (TVar ki)

 | WfT_TCon
   :  forall n
   ,  wfT kn (TCon n)

 | WfT_TForall
   :  forall t
   ,  wfT (S kn) t
   -> wfT kn (TForall t)

 | WfT_TApp
   :  forall t1 t2
   ,  wfT kn t1 -> wfT kn t2
   -> wfT kn (TApp t1 t2).
Hint Constructors wfT.


(* Closed types are well formed under an empty environment. *)
Definition closedT : ty -> Prop
 := wfT O.
Hint Unfold closedT.


Lemma wfT_succ
 :  forall tn t1
 ,  wfT tn     t1
 -> wfT (S tn) t1.
Proof.
 intros. gen tn.
 induction t1; intros; inverts H; eauto.
Qed.
Hint Resolve wfT_succ.


Lemma wfT_more
 :  forall tn1 tn2 tt
 ,  tn1 <= tn2
 -> wfT tn1 tt
 -> wfT tn2 tt.
Proof.
 intros. gen tn1 tn2.
 induction tt; intros; inverts H0; eauto.

 Case "TVar".
  eapply WfT_TVar; burn.

 Case "TForall".
  eapply WfT_TForall.
  lets D: IHtt H2 (S tn2).
  eapply D. omega.
Qed.
Hint Resolve wfT_more.


Lemma wfT_max
 :  forall tn1 tn2 tt
 ,  wfT tn1 tt
 -> wfT (max tn1 tn2) tt.
Proof.
 intros.
 assert (  ((tn1 <  tn2) /\ max tn1 tn2 = tn2)
        \/ ((tn2 <= tn1) /\ max tn1 tn2 = tn1)).
  eapply Max.max_spec.

 inverts H0. rip. rs.
  eapply wfT_more; eauto.

 inverts H1. rip. rs.
Qed.
Hint Resolve wfT_max.


Lemma wfT_exists
 :  forall t1
 ,  (exists tn, wfT tn t1).
Proof.
 intros.
 induction t1.
 Case "TCon".
  exists 0. auto.

 Case "TVar".
  exists (S n). eauto.

 Case "TForall".
  shift tn.
  eapply WfT_TForall; eauto.

 Case "TApp".
  destruct IHt1_1 as [tn1].
  destruct IHt1_2 as [tn2].
  exists (max tn1 tn2).
  eapply WfT_TApp.
   eauto.
   rewrite Max.max_comm. eauto.
Qed.
Hint Resolve wfT_exists.


Lemma makeTApps_wfT
 :  forall n t1 ts
 ,  wfT n t1
 -> Forall (wfT n) ts
 -> wfT n (makeTApps t1 ts).
Proof.
 intros. gen t1.
 induction ts; intros.
  simpl. auto.
  simpl.
  inverts H0.
  assert (ts = nil \/ (exists t ts', ts = t <: ts')) as HS.
   apply snocable.
   inverts HS.
    simpl. auto.
    dest H0. dest H0. subst.
    eapply IHts. auto.
     auto.
Qed.
