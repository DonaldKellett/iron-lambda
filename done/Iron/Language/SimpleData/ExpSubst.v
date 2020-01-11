
Require Export Iron.Language.SimpleData.ExpBase.
Require Import Iron.Language.SimpleData.ExpLift.


(* Substitute for the outermost binder in an expression. *)
Fixpoint
 substX (d:  nat) (* current binding depth in expression *)
        (u:  exp) (* new expression to substitute *)
        (xx: exp) (* expression to substitute into *)
        : exp
 := match xx with
    | XVar ix
    => match nat_compare ix d with
       (* Index matches the one we are substituting for. *)
       | Eq  => u

       (* Index was free in the original expression.
          As we've removed the outermost binder, also decrease this
          index by one. *)
       | Gt  => XVar (ix - 1)

       (* Index was bound in the original expression. *)
       | Lt  => XVar ix
       end

    (* Increase the depth as we move across a lambda.
       Also lift free references in the exp being substituted
       across the lambda as we enter it. *)
    |  XLam t1 x2
    => XLam t1 (substX (S d) (liftX 1 0 u) x2)

    (* Applications *)
    |  XApp x1 x2
    => XApp (substX d u x1) (substX d u x2)

    |  XCon dc xs
    => XCon dc (map (substX d u) xs)

    |  XCase x alts
    => XCase (substX d u x) (map (substA d u) alts)
    end

with substA (d: nat) (u: exp) (aa: alt)
 := match aa with
    |  AAlt dc ts x
    => AAlt dc ts
         (substX (d + length ts)
                 (liftX (length ts) 0 u)
                  x)
    end.


(* Substitute several expressions.
   Note that in the definition, each time we substitute an
   exp (u), we need to lift it by the number of exps remaining
   in the list (us). This is because we're placing the substitued
   exp under the binders corresponding to the remaining ones.
   The added lifting is then gradually "undone" each time we
   substitue one of the remaining expressions. This happens due
   to the free variable/Gt case in the definition of substX.
   Example:
               (A->B), A |- 0 :: A
               (A->B), A |- 1 :: (A->B)
    (A->B), A, A, (A->B) |- (0 1) [1 0] :: B

    Substitute first exp in list.
            (A->B), A, A |- (2 0) [0] :: B
    We get '2' by adding the length of the remaining substitution
    (1) to the index substituted (1). The argument of the function
    is changed from 1 to 0 by the free variable case of substX.
    Substitute remaining exp in list.
               (A->B), A |- (1 0) :: B
    Here, 0 is subst for 0, and 2 changes to 1 due as it's a free
    variable.
*)
Fixpoint substXs (d: nat) (us: list exp) (xx: exp) :=
 match us with
 | nil      => xx
 | u :: us' => substXs d us'
                 (substX d (liftX (List.length us') 0 u)
                           xx)
 end.


(* The data constructor of an alternative is unchanged
   by substitution. *)
Lemma dcOfAlt_substA
 : forall d u a
 , dcOfAlt (substA d u a) = dcOfAlt a.
Proof.
 intros. destruct a. auto.
Qed.
