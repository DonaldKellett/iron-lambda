
Require Export Iron.Language.SimpleData.ExpBase.
Require Export Iron.Language.SimpleData.ExpAlt.


(********************************************************************)
(* When we push new elements on the environment stack of an
   expression, we need to lift free indices in the expression
   across the new elements.
   For example given:
             t1, t0 |- 0 1 (\. 0 1 2) :: t3
   Pushing two more elements gives:
     t1, t0, ta, tb |- 2 3 (\. 0 3 4) :: t3
 *)
Fixpoint
 liftX  (n:  nat) (* number of elements pushed on stack *)
        (d:  nat) (* current binding depth in expression *)
        (xx: exp) (* expression to lift *)
        {struct xx}
        : exp
 := match xx with
    |  XVar ix
    => if le_gt_dec d ix
        (* index was pointing into env, lift it across new elems *)
        then XVar (ix + n)
        (* index was locally bound, leave it be *)
        else xx

    (* increase the depth as we move across a lambda *)
    |  XLam t1 x1
    => XLam t1 (liftX n (S d) x1)

    |  XApp x1 x2
    => XApp   (liftX n d x1) (liftX n d x2)

    (* lift all the arguments of a data constructor *)
    |  XCon dc xs
    => XCon dc (map (liftX n d) xs)

    (* lift all the alternatives in a case-expression *)
    |  XCase x alts
    => XCase (liftX n d x) (map (liftA n d) alts)
    end

 with liftA (n: nat) (d: nat) (aa: alt) {struct aa}:=
  match aa with
  (* When we enter into the right of an alternative, a new type
     is pushed onto the environment for each of the arguments
     of the data constructor. We need to increase the current
     binding depth by the number of arguments. *)
  |  AAlt dc ts x
  => AAlt dc ts (liftX n (d + length ts) x)
  end.


(* The data constructor of an alternative is unchanged
   by lifting. *)
Lemma dcOfAlt_liftA
 : forall n d a
 , dcOfAlt (liftA n d a) = dcOfAlt a.
Proof.
 intros. destruct a. auto.
Qed.


(* When we lift an expression by zero places,
   then the expression is unchanged. *)
Lemma liftX_zero
 : forall d x
 , liftX 0 d x = x.
Proof.
 intros. gen d.
 induction x using exp_mutind with
  (PA := fun a => forall d
      ,  liftA 0 d a = a);
  rip; simpl;
  try (solve [f_equal; rewritess; burn]).

 Case "XVar".
  lift_cases; burn.

 Case "XCon".
  nforall.
  rewrite (map_ext_in (liftX 0 d) id); auto.
  rewrite map_id; auto.

 Case "XCase".
  nforall.
  rewrite (map_ext_in (liftA 0 d) id); auto.
  rewrite map_id. rewrite IHx; auto.
Qed.


(* Commutivity of lifting. *)
Lemma liftX_comm
 : forall n m x d
 , liftX n d (liftX m d x)
 = liftX m d (liftX n d x).
Proof.
 intros. gen d.
 induction x using exp_mutind with
  (PA := fun a => forall d
      ,  liftA n d (liftA m d a)
      =  liftA m d (liftA n d a));
   rip; simpl;
   try (solve [f_equal; rewritess; burn]).

 Case "XVar".
  repeat (simpl; lift_cases; burn);
   solve [f_equal; omega].

 Case "XCon".
  f_equal.
  repeat (rewrite map_map).
  rewrite Forall_forall in *.
  rewrite (map_ext_in
   (fun x0 => liftX n d (liftX m d x0))
   (fun x0 => liftX m d (liftX n d x0))); burn.

 Case "XCase".
  f_equal. burn.
  rewrite map_map.
  rewrite map_map.
  rewrite Forall_forall in *.
  rewrite (map_ext_in
   (fun a1 => liftA n d (liftA m d a1))
   (fun a1 => liftA m d (liftA n d a1))); burn.
Qed.


(* When consecutively lifting an expression, we can lift by one
   more place in the first lifting and but one less in the second. *)
Lemma liftX_succ
 : forall n m d x
 , liftX (S n) d (liftX m     d x)
 = liftX n     d (liftX (S m) d x).
Proof.
 intros. gen d.
 induction x using exp_mutind with
  (PA := fun a => forall d
      ,  liftA (S n) d (liftA  m    d a)
      =  liftA n     d (liftA (S m) d a));
  rip; simpl;
  try (solve [f_equal; rewritess; burn]).

 Case "XVar".
  repeat (simple; lift_cases; intros);
   try (solve [f_equal; omega]).

 Case "XCon".
  f_equal.
  repeat (rewrite map_map).
  rewrite Forall_forall in *.
  rewrite (map_ext_in
   (fun x0 => liftX (S n) d (liftX m d x0))
   (fun x0 => liftX n d (liftX (S m) d x0))); burn.

 Case "XCase".
  f_equal. eauto.
  repeat (rewrite map_map).
  rewrite Forall_forall in *.
  rewrite (map_ext_in
   (fun x1 => liftA (S n) d (liftA m d x1))
   (fun x1 => liftA n d (liftA (S m) d x1))); burn.
Qed.


(* We can collapse two consecutive lifting expressions by lifting
   just onces by the sum of the places, provided the lifting
   occurs at depth zero. *)
Lemma liftX_plus
 : forall n m x
 , liftX n 0 (liftX m 0 x) = liftX (n + m) 0 x.
Proof.
 intros. gen n.
 induction m.
  intros. rewrite liftX_zero. nnat. burn.
  intros.
   rrwrite (n + S m = S n + m).
   rewrite liftX_comm.
   rewrite <- IHm.
   rewrite liftX_comm.
   rewrite liftX_succ.
   auto.
Qed.
