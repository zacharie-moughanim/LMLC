Require Export Coq.Classes.Init.
Require Import Coq.Program.Basics.
Require Import Coq.Program.Tactics.
Require Import Coq.Relations.Relation_Definitions.
Require Import Relation_Definitions.
From Coq Require Import Lists.List.
Import ListNotations.
Require Import PeanoNat.

From LMLCProof Require Import Utils Source Object Transpiler.

(* REMARKS : 
    - The cohabitation of in_list and In may not be the greatest idea, we'll see at the end
      if we use the fact that In is decidable on list of nat
    - As mush as possible, we authorise to admit. a case in the main proof only for goals
      of the form [~(In x l)] or [in_list l x = false], when it seems clear from the specification
      of fresh variables that these are true

  CASES LEFT TO PROVE :
  - _In the main proof_
    * minus
    * times
  - _In the proof of substitution_ (necessary to the case of a redex in the main proof)
    * fixfun
    * plus
    * minus
    * times
    * gtz
    * if then else
    * cons
    * fold_right
    * pair
    * fst
    * snd
*)


(** Beta-Reduction properties *)

Lemma beta_red_is_reflexive : reflexive lambda_term (beta_star).
Proof. unfold reflexive. intro x. unfold beta_star. apply refl.
Qed.

Lemma S_predn : forall (n : nat), n = 0 \/ S (pred n) = n.
Proof. 
  intros [|n].
  - simpl. left. reflexivity.
  - simpl. right. reflexivity.
Qed.

Lemma S_predn' : forall (n : nat), 0 < n -> S (pred n) = n.
Proof. 
  intros *. intro H.  Abort.


Lemma pred_minus : forall (n : nat), pred n = n - 1.
Proof.
  destruct n.
  - reflexivity.
  - simpl. rewrite minus_n_0. reflexivity.
Qed.

Lemma succ_church : forall n : nat,
  church_succ2 (church_int n) = church_int (S n).
Proof.
  intros n. unfold church_int. unfold church_int_free. unfold church_succ2.
  destruct n as [|n'].
  - reflexivity.
  - reflexivity.
Qed.

Example H3Modif : forall (n0 : nat) (h0 : lambda_term) (ht0 : lambda_term) (tlt0 : list lambda_term),
     (forall n : nat,
     match find_opt (h0 :: ht0 :: tlt0) n with
     | Some a =>
         match find_opt (h0 :: ht0 :: tlt0) (S n) with
         | Some b => a ->b b
         | None => True
         end
     | None => True
     end) -> match find_opt (h0 :: ht0 :: tlt0) (S n0) with
     | Some a =>
         match find_opt (h0 :: ht0 :: tlt0) (S (S n0)) with
         | Some b => a ->b b
         | None => True
         end
     | None => True
     end.
Proof. intros *. intro H3. apply H3. Qed.

Lemma beta_alpha :
  forall (M M' N N' : lambda_term),
    M ->b* N -> M ~a M' -> N ~a N' -> M' ->b* N'.
Proof.
  intros.
  apply alpha_quot in H0.
  apply alpha_quot in H1.
  rewrite <- H0, <- H1.
  apply H. Qed.

Lemma beta_alpha_toplvl : forall (M N : lambda_term) (x y z : var), ~(In z (fvL M)) -> ~(In z (fvL N)) ->
        Labs z (substitution M (Lvar z) x) ->b* Labs z (substitution N (Lvar z) y) -> Labs x M ->b* Labs y N.
Proof. intros M N x y z H G H0. apply beta_alpha with (M := Labs z (substitution M (Lvar z) x)) (N := Labs z (substitution N (Lvar z) y)).
  - apply H0.
  - apply alpha_sym. apply alpha_rename with (N := M).
    + apply H.
    + apply alpha_refl.
    + reflexivity.
  - apply alpha_sym. apply alpha_rename with (N := N).
    + apply G.
    + apply alpha_refl.
    + reflexivity.
Qed.

(* MAIN PROOF *)
Lemma lmlc_substitution : forall (M N : ml_term) (x : var),
                          lmlc (ml_substitution M N x) = substitution (lmlc M) (lmlc N) x.
Proof. induction M as [ x | M1 IHappl1 M2 IHappl2 | x M' IHfunbody| f x M' IHfixfunbody
                      | M1 IHplus1 M2 IHplus2 | M1 IHminus1 M2 IHminus2 | M1 IHtimes1 M2 IHtimes2 | n
                      | M' IHgtz
                      | | C IHifc T IHift E IHife
                      | HD IHconshd TL IHconsnil| |LST IHfoldlst OP IHfoldop INIT IHfoldinit
                      | P1 IHpair1 P2 IHpair2 | P IHfst | P IHsnd ].
(* M = x *)
  - intros *. simpl. destruct (x0 =? x).
    + reflexivity.
    + reflexivity.
(* M = (M1)M2 *)
  - intros *. simpl. rewrite IHappl1. rewrite IHappl2. reflexivity.
(* M = fun x -> M' *)
  - intros *. simpl. destruct (x0 =? x).
    + reflexivity.
    + simpl. rewrite IHfunbody. reflexivity.
(* M = fixfun f x -> M' *)
  - admit.
(* M = M1 + M2 *)
  - admit.
(* M = M1 - M2 *)
  - admit.
(* M = M1 * M2 *)
  - admit.
(* M = n [in NN] *)
  - intros. simpl. destruct (x =? 1) eqn:eqx1.
    + reflexivity.
    + destruct (x =? 0) eqn:eqx0.
      * reflexivity.
      * { induction n as [|n' IHn'].
          - simpl. rewrite eqx0. reflexivity.
          - admit.
        }
(* M = 0 < M *)
  - admit.
(* M = true *)
  - intros. simpl. destruct b.
    + unfold church_true. destruct (x =? 0) eqn:eqx0.
      * simpl. rewrite eqx0. reflexivity.
      * destruct (x =? 1) eqn:eqx1.
        -- simpl. rewrite eqx0. rewrite eqx1. reflexivity.
        -- simpl. rewrite eqx0. rewrite eqx1. reflexivity.
    + unfold church_false. destruct (x =? 0) eqn:eqx0.
      * simpl. rewrite eqx0. reflexivity.
      * destruct (x =? 1) eqn:eqx1.
        -- simpl. rewrite eqx0. rewrite eqx1. reflexivity.
        -- simpl. rewrite eqx0. rewrite eqx1. reflexivity.
(* M = If C then T else E *)
  - admit.
(* M = HD::TL *)
  - admit.
(* M = [] *)
  - intros. simpl. destruct (x =? 0) eqn:eqx0.
      * simpl. reflexivity.
      * destruct (x =? 1) eqn:eqx1.
        -- reflexivity.
        -- reflexivity.
(* M = Fold_right LST OP INIT *)
  - admit.
(* M = <P1,P2> *)
  - admit.
(* M = fst P *)
  - admit.
(* M = snd P *)
  - admit.
Admitted.

(**
If you want to induct :
[ y | L1 IHappl1' L2 IHappl2' | y L IHfunbody'| g y L IHfixfunbody'
| L1 IHplus1' L2 IHplus2' | L1 IHminus1' L2 IHminus2' | L1 IHtimes1' L2 IHtimes2' | m
| L IHgtz'
| | | C' IHifc' T' IHift' E' IHife'
| HD' IHconshd' TL' IHconsnil' | | LST' IHfoldlst' OP' IHfoldop' INIT' IHfoldinit'
| P1' IHpair1' P2' IHpair2' | P' IHfst' | P' IHsnd' ]


If you want to destruct :
[ y | L1 L2 | y L | g y L
| L1 L2 | L1 L2 | L1 L2 | m
| L
| | | C' T' E'
| HD' TL' | | LST' OP' INIT'
| P1' P2' | P' | P' ]

*)

Theorem lmlc_correct : forall (M N : ml_term), M ->ml N -> (lmlc M) ->b* (lmlc N).
Proof. intros.
induction H as
[
    x M M' HM IHfun_contextual
  | f x M M' HM IHfixfun_contextual
  | M M' N HM IHappl_contextual
  | M N N' HN IHappl_contextual
  | M M' N HM IHplus_contextual
  | M N N' HN IHplus_contextual
  | M M' N HM IHminus_contextual
  | M N N' HN IHminus_contextual
  | M M' N HM IHtimes_contextual
  | M N N' HN IHtimes_contextual
  | M M' N IHgtz_contextual
  | C C' T E HC IHif_contextual
  | C T T' E HT IHif_contextual
  | C T E E' HE IHif_contextual
  | HD HD' TL HHD IHcons_contextual
  | HD TL TL' HTL IHcons_contextual
  | LST LST' FOO INIT HLST IHfold_contextual
  | LST FOO FOO' INIT HFOO IHfold_contextual
  | LST FOO INIT INIT' HINIT IHfold_contextual
  | P1 P1' P2 HP1 IHpair
  | P1 P2 P2' HP2 IHpair
  | P P' HP IHfst
  | P P' HP IHsnd
  | x M N
  | f x M IHfixfun
  | n m
  | n m
  | n m
  | n
  | FOO INIT
  | HD TL FOO INIT
  | P1 P2
  | P1 P2
].
(* contextual cases *)
  (* fun *)
  - simpl. apply bredstar_contextual_abs. apply IHfun_contextual.
  (* fixfun *)
  - simpl. unfold turing_fixpoint_applied. apply bredstar_contextual_appl.
    + apply bredstar_contextual_abs. apply bredstar_contextual_abs. apply IHfixfun_contextual.
    + apply bredstar_contextual_appl.
      * apply refl.
      * apply bredstar_contextual_abs. apply bredstar_contextual_abs. apply IHfixfun_contextual.
  (* application - function *)
  - simpl. apply bredstar_contextual_appl.
    + apply IHappl_contextual.
    + apply refl.
  (* application - argument *)
  - simpl. apply bredstar_contextual_appl.
    + apply refl.
    + apply IHappl_contextual.
  (* plus - lhs *)
  - simpl. unfold church_plus. Search fvML fvL. rewrite <- fvML_L.
     rewrite <- fvML_L. rewrite <- fvML_L.
    remember (fresh (fvL (lmlc M) ++ fvL (lmlc M') ++ fvL (lmlc N))) as new_x.
    remember (fresh (fvL (lmlc M) ++ fvL (lmlc N))) as x. remember (fresh (fvL (lmlc M') ++ fvL (lmlc N))) as x'.
    apply beta_alpha_toplvl with (z := new_x).
    + admit.
    + admit.
    + apply bredstar_contextual_abs.
      remember (fresh [x]) as y.
      remember (fresh [x']) as y'. simpl.
      assert (x =? y = false). { admit. } assert (x' =? y' = false). { admit. }
      rewrite H0. remember (fresh [new_x]) as new_y. rewrite H.
      apply beta_alpha_toplvl with (z := new_y).
      * admit.
      * admit.
      * apply bredstar_contextual_abs. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
        simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
        assert (y =? new_x = false). { admit. } assert (y' =? new_x = false). { admit. }
        rewrite H1. rewrite H2. { apply bredstar_contextual_appl.
          - apply bredstar_contextual_appl.
            + rewrite substitution_fresh_l. rewrite substitution_fresh_l.
              rewrite substitution_fresh_l. rewrite substitution_fresh_l. apply refl.
              * admit.
              * admit.
              * admit.
              * admit.
            + apply refl.
          - apply bredstar_contextual_appl.
            + apply bredstar_contextual_appl.
              * {   rewrite substitution_fresh_l.
                  - rewrite substitution_fresh_l.
                    + {   rewrite substitution_fresh_l.
                        - rewrite substitution_fresh_l.
                          + apply IHplus_contextual.
                          + admit.
                        - admit.
                      }
                    + admit.
                  - admit.
                }
              * apply refl.
            + apply refl.
        }
  (* plus - rhs *)
  - simpl. unfold church_plus. Search fvML fvL. rewrite <- fvML_L.
     rewrite <- fvML_L. rewrite <- fvML_L.
    remember (fresh (fvL (lmlc M) ++ fvL (lmlc N) ++ fvL (lmlc N'))) as new_x.
    remember (fresh (fvL (lmlc M) ++ fvL (lmlc N))) as x. remember (fresh (fvL (lmlc M) ++ fvL (lmlc N'))) as x'.
    apply beta_alpha_toplvl with (z := new_x).
    + admit.
    + admit.
    + apply bredstar_contextual_abs.
      remember (fresh [x]) as y.
      remember (fresh [x']) as y'. simpl.
      assert (x =? y = false). { admit. } assert (x' =? y' = false). { admit. }
      rewrite H0. remember (fresh [new_x]) as new_y. rewrite H.
      apply beta_alpha_toplvl with (z := new_y).
      * admit.
      * admit.
      * apply bredstar_contextual_abs. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
        simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
        assert (y =? new_x = false). { admit. } assert (y' =? new_x = false). { admit. }
        rewrite H1. rewrite H2. { apply bredstar_contextual_appl.
          - apply bredstar_contextual_appl.
            + rewrite substitution_fresh_l. rewrite substitution_fresh_l.
              rewrite substitution_fresh_l. rewrite substitution_fresh_l.
              apply IHplus_contextual.
              admit.
              admit.
              admit.
              admit.
            + apply refl.
          - apply bredstar_contextual_appl.
            + apply bredstar_contextual_appl.
              * {   rewrite substitution_fresh_l.
                  - rewrite substitution_fresh_l.
                    + {   rewrite substitution_fresh_l.
                        - rewrite substitution_fresh_l.
                          + apply refl.
                          + admit.
                        - admit.
                      }
                    + admit.
                  - admit.
                }
              * apply refl.
            + apply refl.
        }
  (* minus - lhs *)
  - simpl. unfold church_minus. apply bredstar_contextual_appl_function. apply bredstar_contextual_appl_function.
    apply IHminus_contextual.
  (* minus - rhs *)
  - simpl. unfold church_minus. apply bredstar_contextual_appl_argument.
    apply IHminus_contextual.
  (* times - lhs *)
  - simpl. unfold church_times. remember (fresh (fvL (lmlc M) ++ fvL (lmlc N))) as x.
    remember (fresh [x]) as y. remember (fresh (fvL (lmlc M') ++ fvL (lmlc N))) as x'.
    remember (fresh [x']) as y'. remember (fresh (fvL (lmlc M) ++ (fvL (lmlc M') ++ fvL (lmlc N)))) as x''.
    apply beta_alpha_toplvl with (z := x'').
    + admit.
    + admit.
    + simpl. apply bredstar_contextual_abs. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
      assert (x =? y = false). { admit. }
      assert (x' =? y' = false). { admit. }
      rewrite H. rewrite H0. clear H. clear H0.
      rewrite substitution_fresh_l. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
      rewrite substitution_fresh_l.
      * remember (fresh [x'']) as y''. apply beta_alpha_toplvl with (z := y'').
        -- admit.
        -- admit.
        -- simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
           assert (y =? x'' = false). { admit. }
           assert (y' =? x'' = false). { admit. }
           rewrite H. rewrite H0. clear H. clear H0.
           apply bredstar_contextual_abs.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           ++ apply bredstar_contextual_appl_argument. apply bredstar_contextual_appl_function.
              apply bredstar_contextual_appl_function. apply IHtimes_contextual.
           ++ admit.
           ++ admit.
           ++ admit.
           ++ admit.
      * admit.
      * admit.
      * admit.
      * admit.
  (* times - rhs *)
  - simpl. unfold church_times. remember (fresh (fvL (lmlc M) ++ fvL (lmlc N))) as x.
    remember (fresh [x]) as y. remember (fresh (fvL (lmlc M) ++ fvL (lmlc N'))) as x'.
    remember (fresh [x']) as y'. remember (fresh (fvL (lmlc M) ++ fvL (lmlc N) ++ (fvL (lmlc N')))) as x''.
    apply beta_alpha_toplvl with (z := x'').
    + admit.
    + admit.
    + simpl. apply bredstar_contextual_abs. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
      assert (x =? y = false). { admit. }
      assert (x' =? y' = false). { admit. }
      rewrite H. rewrite H0. clear H. clear H0.
      rewrite substitution_fresh_l. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
      rewrite substitution_fresh_l.
      * remember (fresh [x'']) as y''. apply beta_alpha_toplvl with (z := y'').
        -- admit.
        -- admit.
        -- simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
           assert (y =? x'' = false). { admit. }
           assert (y' =? x'' = false). { admit. }
           rewrite H. rewrite H0. clear H. clear H0.
           apply bredstar_contextual_abs.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           ++ apply bredstar_contextual_appl_function. apply bredstar_contextual_appl_function.
              apply IHtimes_contextual.
           ++ admit.
           ++ admit.
           ++ admit.
           ++ admit.
      * admit.
      * admit.
      * admit.
      * admit.
  (* gtz *)
  - simpl. unfold church_gtz. apply bredstar_contextual_appl.
    + apply bredstar_contextual_appl.
      * apply IHgtz_contextual.
      * apply refl.
    + apply refl.
  (* if then else - condition*)
  - simpl. unfold church_if. apply bredstar_contextual_appl.
    + apply bredstar_contextual_appl.
      * apply IHif_contextual.
      * apply refl.
    + apply refl.
  (* if then else - then branch *)
  - simpl. apply bredstar_contextual_appl.
    + apply bredstar_contextual_appl.
      * apply refl.
      * apply IHif_contextual.
    + apply refl.
  (* if then else - else branch *)
  - simpl. apply bredstar_contextual_appl.
    + apply refl.
    + apply IHif_contextual.
  (* cons - head *)
  - simpl. remember (fresh [fresh (fvML HD ++ fvML TL)]). remember (fresh (fvML HD ++ fvML TL)).
      remember (fresh (fvML HD' ++ fvML TL)) as v0'. remember (fresh [v0']) as v'.
      remember (fresh (fvML HD ++ fvML HD' ++ fvML TL)) as new_v0.
      apply beta_alpha_toplvl with (z := new_v0).
    + admit.
    + admit.
    + remember (fresh [new_v0]) as new_v. apply bredstar_contextual_abs.
      rewrite subst_lambda_cont. rewrite subst_lambda_cont.
      simpl. assert (v =? v0 = false). { admit. } assert (v' =? v0' = false). { admit. } rewrite Nat.eqb_refl.
      rewrite Nat.eqb_sym. rewrite H. rewrite Nat.eqb_refl. rewrite Nat.eqb_sym. rewrite H0.
      apply beta_alpha_toplvl with (z := fresh [new_v0]).
      * admit.
      * admit.
      * apply bredstar_contextual_abs. simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
        assert (v =? new_v0 = false). { admit. } assert (v' =? new_v0 = false). { admit. }
        rewrite H1. rewrite H2. apply bredstar_contextual_appl.
        -- apply bredstar_contextual_appl.
          ++ rewrite substitution_fresh_l. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
              rewrite substitution_fresh_l. apply refl. admit. admit. admit. admit.
          ++ apply refl.
        -- apply bredstar_contextual_appl_function. apply bredstar_contextual_appl_argument.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           rewrite substitution_fresh_l. apply IHcons_contextual. admit. admit. admit. admit.
      * admit.
      * admit.
  (* cons - tail *)
  - simpl. remember (fresh [fresh (fvML HD ++ fvML TL)]). remember (fresh (fvML HD ++ fvML TL)).
      remember (fresh (fvML HD ++ fvML TL')) as v0'. remember (fresh [v0']) as v'.
      remember (fresh (fvML HD ++ fvML TL ++ fvML TL')) as new_v0.
      apply beta_alpha_toplvl with (z := new_v0).
    + admit.
    + admit.
    + remember (fresh [new_v0]) as new_v. apply bredstar_contextual_abs.
      rewrite subst_lambda_cont. rewrite subst_lambda_cont.
      simpl. assert (v =? v0 = false). { admit. } assert (v' =? v0' = false). { admit. } rewrite Nat.eqb_refl.
      rewrite Nat.eqb_sym. rewrite H. rewrite Nat.eqb_refl. rewrite Nat.eqb_sym. rewrite H0.
      apply beta_alpha_toplvl with (z := fresh [new_v0]).
      * admit.
      * admit.
      * apply bredstar_contextual_abs. simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
        assert (v =? new_v0 = false). { admit. } assert (v' =? new_v0 = false). { admit. }
        rewrite H1. rewrite H2. apply bredstar_contextual_appl.
        -- apply bredstar_contextual_appl_function.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           rewrite substitution_fresh_l. apply IHcons_contextual. admit. admit. admit. admit.
        -- apply bredstar_contextual_appl_function. apply bredstar_contextual_appl_argument.
           rewrite substitution_fresh_l. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
           rewrite substitution_fresh_l. apply refl. admit. admit. admit. admit.
      * admit.
      * admit.
  (* fold - list *)
  - simpl. apply bredstar_contextual_appl.
    + apply bredstar_contextual_appl.
      * apply IHfold_contextual.
      * apply refl.
    + apply refl.
  (* fold - operator *)
  - simpl. apply bredstar_contextual_appl.
    + apply bredstar_contextual_appl.
      * apply refl.
      * apply IHfold_contextual.
    + apply refl.
  (* fold - initial value *)
  - simpl. apply bredstar_contextual_appl.
    + apply bredstar_contextual_appl.
      * apply refl.
      * apply refl.
    + apply IHfold_contextual.
  (* pair - first element *)
  - simpl. remember (fresh (fvML P1 ++ fvML P2)) as x.  remember (fresh (fvML P1' ++ fvML P2)) as x'.
     remember (fresh (fvML P1 ++ fvML P1' ++ fvML P2)) as new_x.
     apply beta_alpha_toplvl with (z := new_x).
      + admit.
      + admit.
      + apply bredstar_contextual_abs. rewrite subst_appl_cont. rewrite subst_appl_cont with (M := Lappl (Lvar x') (lmlc P1')).
        apply bredstar_contextual_appl.
        * rewrite subst_appl_cont. rewrite subst_appl_cont. apply bredstar_contextual_appl.
          -- simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl. apply refl.
          -- rewrite substitution_fresh_l.
            ++ rewrite substitution_fresh_l.
              ** apply IHpair.
              ** admit.
            ++ admit.
        * rewrite substitution_fresh_l.
          -- rewrite substitution_fresh_l.
            ++ apply refl.
            ++ admit.
          -- admit.
  (* pair - second element *)
  - simpl. remember (fresh (fvML P1 ++ fvML P2)) as x.  remember (fresh (fvML P1 ++ fvML P2')) as x'.
     remember (fresh (fvML P1 ++ fvML P2 ++ fvML P2')) as new_x.
     apply beta_alpha_toplvl with (z := new_x).
      + admit.
      + admit.
      + apply bredstar_contextual_abs. rewrite subst_appl_cont. rewrite subst_appl_cont with (M := Lappl (Lvar x') (lmlc P1)).
        apply bredstar_contextual_appl.
        * rewrite subst_appl_cont. rewrite subst_appl_cont. apply bredstar_contextual_appl.
          -- simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl. apply refl.
          -- rewrite substitution_fresh_l.
            ++ rewrite substitution_fresh_l.
              ** apply refl.
              ** admit.
            ++ admit.
        * rewrite substitution_fresh_l.
          -- rewrite substitution_fresh_l.
            ++ apply IHpair.
            ++ admit.
          -- admit.
(* fst *)
  - simpl. apply bredstar_contextual_appl.
    + apply IHfst.
    + remember (fresh (fvML P ++ fvML P')) as new_x. apply beta_alpha_toplvl with (z := new_x).
      * admit.
      * admit.
      * apply bredstar_contextual_abs. simpl.
        assert (fresh (fvML P) =? fresh [fresh (fvML P)] = false).
        { admit. } rewrite H. rewrite Nat.eqb_refl.
        assert (fresh (fvML P') =? fresh [fresh (fvML P')] = false).
        { admit. } rewrite H0. rewrite Nat.eqb_refl.
        apply beta_alpha_toplvl with (z := fresh [new_x]).
        -- admit.
        -- admit.
        -- apply bredstar_contextual_abs. simpl.
           assert (fresh [fresh (fvML P)] =? new_x = false). { admit. }
           assert (fresh [fresh (fvML P')] =? new_x = false). { admit. }
           rewrite H1. rewrite H2. apply refl.
(* snd *)
  - simpl. apply bredstar_contextual_appl.
    + apply IHsnd.
    + remember (fresh (fvML P ++ fvML P')) as new_x. apply beta_alpha_toplvl with (z := new_x).
      * admit.
      * admit.
      * apply bredstar_contextual_abs. simpl.
        assert (fresh (fvML P) =? fresh [fresh (fvML P)] = false).
        { admit. } rewrite H.
        assert (fresh (fvML P') =? fresh [fresh (fvML P')] = false).
        { admit. } rewrite H0.
        apply beta_alpha_toplvl with (z := fresh [new_x]).
        -- admit.
        -- admit.
        -- apply bredstar_contextual_abs. simpl. rewrite Nat.eqb_refl. rewrite Nat.eqb_refl.
           apply refl.
(** Actual reduction cases *)
(* redex case *)
  - simpl. rewrite lmlc_substitution. apply onestep. apply redex_contraction.
(* fixfun case *)
  - simpl. unfold turing_fixpoint_applied. apply bredstar_contextual_appl.
    + apply refl.
    + apply trans with (y := Lappl (Labs 0 (Lappl (Lvar 0) (Lappl turing_fixpoint (Lvar 0)))) (Labs f (Labs x (lmlc M)))).
      * unfold turing_fixpoint. apply bredstar_contextual_appl.
        -- apply onestep. apply redex_contraction.
        -- apply refl.
      * apply onestep. apply redex_contraction.
(* plus case *)
  - simpl. unfold church_int. simpl. unfold church_plus. simpl.
      remember (fresh []) as s.
      remember (fresh [s]) as z.
      assert (Labs 1 (Labs 0 (church_int_free (n+m))) =
      Labs s (substitution (Labs z (substitution (church_int_free (n+m)) (Lvar z) 0)) (Lvar s) 1)).
      {
        apply alpha_quot.
        apply alpha_rename with (N := Labs z (substitution (church_int_free (n+m)) (Lvar z) 0)).
        -- admit.
        -- apply alpha_rename with (N := church_int_free (n+m)).
          ** admit.
          ** apply alpha_refl.
          ** reflexivity.
        -- reflexivity.
      }
      * rewrite H.
        apply bredstar_contextual_abs. rewrite subst_lambda_cont.
        -- rewrite Heqz. rewrite Heqs. apply bredstar_contextual_abs.
           { rewrite <- Heqs. rewrite <- Heqz. apply trans with (y := 
Lappl (substitution (Labs 0 (church_int_free m)) (Lvar s) 1)
  (Lappl (Lappl (Labs 1 (Labs 0 (church_int_free n))) (Lvar s)) (Lvar z))).
            - apply bredstar_contextual_appl.
              + apply onestep. apply redex_contraction.
              + apply refl.
            - apply trans with (y := 
Lappl (substitution (Labs 0 (church_int_free m)) (Lvar s) 1)
  (Lappl (substitution (Labs 0 (church_int_free n)) (Lvar s) 1) (Lvar z))).
          + apply bredstar_contextual_appl_argument. apply bredstar_contextual_appl_function.
            apply onestep. apply redex_contraction.
          + apply trans with (y := 
Lappl (substitution (Labs 0 (church_int_free m)) (Lvar s) 1)
  (substitution (substitution (church_int_free n) (Lvar s) 1) (Lvar z) 0)).
          * apply bredstar_contextual_appl_argument.
            apply onestep. apply redex_contraction.
          * remember (substitution (substitution (church_int_free (n + m)) (Lvar z) 0) (Lvar s) 1) as churchNplusM.
            remember (substitution (substitution (church_int_free n) (Lvar s) 1) (Lvar z) 0) as churchN.
            rewrite subst_lambda_cont.
           -- apply trans with (y := substitution (substitution (church_int_free m) (Lvar s) 1) churchN 0).
              ** apply onestep. apply redex_contraction.
              ** rewrite HeqchurchN. rewrite HeqchurchNplusM.
                 generalize dependent Heqs. generalize dependent Heqz. unfold fresh. unfold fresh_aux.
                 intro Heqz. intro Heqs. assert (lt01 : 1 <=? 0 = false).
                 { apply Nat.leb_nle. intro contra. inversion contra. } rewrite Heqs in Heqz.
                 rewrite lt01 in Heqz. apply church_plus_is_plus.
                 ++ rewrite Heqs. intro contra. discriminate contra.
                 ++ rewrite Heqz. intro contra; discriminate contra.
                 ++ rewrite Heqs. rewrite Heqz. intro contra; discriminate contra.
           -- intro contra. discriminate contra.
          }
        -- generalize dependent Heqs. generalize dependent Heqz. unfold fresh. unfold fresh_aux.
            intro Heqz. intro Heqs. rewrite Heqs in Heqz. assert (lt01 : 1 <=? 0 = false).
            { apply Nat.leb_nle. intro contra. inversion contra. } rewrite lt01 in Heqz. rewrite Heqz.
            intro contra; discriminate contra.
(* times case *)
  - admit.
(* minus case *)
  - simpl. unfold church_minus.
(* greather than zero case *)
  - destruct (0 <? n) eqn:ineqn.
    + simpl. apply Nat.ltb_lt in ineqn. apply Nat.succ_pred_pos in ineqn. remember (Nat.pred n) as n'.
      unfold church_gtz. unfold church_int.
      apply trans with (y := Lappl (substitution (Labs 0 (church_int_free n)) (Labs 0 church_true) 1) church_false).
      * apply bredstar_contextual_appl_function. apply onestep; apply redex_contraction.
      * simpl.
        apply trans with (y := substitution (substitution (church_int_free n) (Labs 0 church_true) 1) church_false 0).
        -- apply onestep; apply redex_contraction.
        -- rewrite <- ineqn. apply church_gtz_Sn.
    + apply Nat.ltb_nlt in ineqn. apply Nat.nlt_ge in ineqn. inversion ineqn. simpl. unfold church_gtz.
      unfold church_int. unfold church_int_free. apply trans with (y := Lappl (Labs 0 (Lvar 0)) (church_false)).
      * assert ((Labs 0 (Lvar 0)) = substitution (Labs 0 (Lvar 0)) (Labs 0 church_true) 1). { reflexivity. }
        rewrite H0. assert (Lappl (Lappl (Labs 1 (substitution (Labs 0 (Lvar 0)) (Labs 0 church_true) 1)) (Labs 0 church_true)) = Lappl (Lappl (Labs 1 (Labs 0 (Lvar 0))) (Labs 0 church_true))).
        { reflexivity. } rewrite H1. apply bredstar_contextual_appl.
        -- apply onestep. apply redex_contraction.
        -- apply refl.
      * apply onestep. assert (church_false = substitution (Lvar 0) church_false 0). { reflexivity. }
        rewrite H0. assert (Lappl (Labs 0 (Lvar 0)) (substitution (Lvar 0) church_false 0) = Lappl (Labs 0 (Lvar 0)) (church_false)).
        { rewrite <- H0. reflexivity. } rewrite H1. apply redex_contraction.
(* fold base case *)
  - simpl. apply trans with (y := (Lappl (Labs 1 (Lvar 1)) (lmlc INIT))).
    + apply bredstar_contextual_appl.
      * assert (Labs 1 (Lvar 1) = substitution (Labs 1 (Lvar 1)) (lmlc FOO) 0). { reflexivity. } rewrite H.
        assert (Lappl (Labs 0 (substitution (Labs 1 (Lvar 1)) (lmlc FOO) 0)) (lmlc FOO) = Lappl (Labs 0 (Labs 1 (Lvar 1))) (lmlc FOO) ).
        { reflexivity. } rewrite H0. apply onestep. apply redex_contraction.
      * apply refl.
    + apply onestep. apply redex_contraction.
(* fold induction step case *)
  - simpl. remember (fresh (fvML HD ++ fvML TL)) as op'. remember (fresh [op']) as init'.
    remember (fresh (fvML HD ++ fvML TL ++ fvML FOO)) as op. remember (fresh [op]) as init.
    assert (  Lappl
                (Lappl
                   (Labs op
                      (Labs init
                         (Lappl (Lappl (lmlc TL) (Lvar op))
                            (Lappl (Lappl (Lvar op) (lmlc HD)) (Lvar init))))) 
                   (lmlc FOO)) (lmlc INIT) =
               Lappl
              (Lappl
                 (Labs op'
                    (Labs init'
                       (Lappl (Lappl (lmlc TL) (Lvar op'))
                          (Lappl (Lappl (Lvar op') (lmlc HD)) (Lvar init'))))) 
                 (lmlc FOO)) (lmlc INIT)).
    {
      apply alpha_quot. apply alpha_context_appl.
      - apply alpha_context_appl.
        + apply alpha_rename with (N := (Labs init
              (Lappl (Lappl (lmlc TL) (Lvar op)) (Lappl (Lappl (Lvar op) (lmlc HD)) (Lvar init))))).
          * admit.
          * apply alpha_refl.
          * simpl. assert (op =? init = false). { admit. }
            rewrite H. clear H. rewrite Nat.eqb_refl. rewrite substitution_fresh_l. rewrite substitution_fresh_l. symmetry.
            apply alpha_quot. apply alpha_rename with (N := (Lappl (Lappl (lmlc TL) (Lvar op')) (Lappl (Lappl (Lvar op') (lmlc HD)) (Lvar init)))).
            -- simpl. admit.
            -- apply alpha_refl.
            -- simpl. rewrite Nat.eqb_refl. assert (init =? op' = false). { admit. } rewrite H. clear H.
               rewrite substitution_fresh_l. rewrite substitution_fresh_l. reflexivity.
               admit.
               admit.
            -- admit.
            -- admit.
        + apply alpha_refl.
      - apply alpha_refl.
    } rewrite <- H. clear H. clear Heqinit'. clear Heqop'. clear op'. clear init'.
    apply trans with (y := Lappl
                          (substitution
                             (
                                (Labs init
                                   (Lappl (Lappl (lmlc TL) (Lvar op)) (Lappl (Lappl (Lvar op) (lmlc HD)) (Lvar init)))))
                             (lmlc FOO) op) (lmlc INIT)).
    + apply bredstar_contextual_appl_function. apply onestep. apply redex_contraction.
    + simpl. assert (op =? init = false). {
        rewrite Nat.eqb_sym. rewrite Heqinit. apply fresh_spec. simpl. rewrite Nat.eqb_refl.
        reflexivity.
      } rewrite H. rewrite Nat.eqb_refl.
      rewrite substitution_fresh_l. rewrite substitution_fresh_l.
      apply trans with (y := substitution (
        (Lappl (Lappl (lmlc TL) (lmlc FOO)) (Lappl (Lappl (lmlc FOO) (lmlc HD)) (Lvar init)))) (lmlc INIT) init).
      * apply onestep. apply redex_contraction.
      * simpl. rewrite Nat.eqb_refl. rewrite substitution_fresh_l. rewrite substitution_fresh_l.
        rewrite substitution_fresh_l. apply refl.
        admit.
        admit.
        admit.
      * admit.
      * admit.
(* fst case *)
  - simpl. remember (fresh (fvML P1 ++ fvML P2)) as z. remember (fresh [z]) as z'.
    apply trans with (y := (substitution (Lappl (Lappl (Lvar z) (lmlc P1)) (lmlc P2)) (Labs z (Labs z' (Lvar z))) z)).
    + apply onestep. apply redex_contraction.
    + simpl. rewrite Nat.eqb_refl. rewrite substitution_fresh_l.
      * { apply trans with (y := Lappl (substitution (Labs z' (Lvar z)) (lmlc P1) z)
            (substitution (lmlc P2) (Labs z (Labs z' (Lvar z))) z)).
          - apply bredstar_contextual_appl.
            + apply onestep. apply redex_contraction.
            + apply refl.
          - simpl. rewrite Nat.eqb_refl. assert (z =? z' = false).
            {
              rewrite Nat.eqb_sym. rewrite Heqz'. apply fresh_spec. simpl. rewrite Nat.eqb_refl. reflexivity.
            }
            rewrite H.
            apply trans with (y := substitution (lmlc P1) (substitution (lmlc P2) (Labs z (Labs z' (Lvar z))) z) z').
            + apply onestep. apply redex_contraction.
            + rewrite substitution_fresh_l.
              * apply refl.
              * assert (in_list (fvL (lmlc P1) ++ fvL (lmlc P2)) z' = false).
                { rewrite Heqz'. apply fresh_of_fresh_is_fresh. rewrite fvML_L. rewrite fvML_L. apply Heqz. }
                apply in_list_app1 in H0. destruct H0 as [H1 H2]. apply H1.
        }
      * assert (in_list (fvL (lmlc P1) ++ fvL (lmlc P2)) z = false).
        { rewrite Heqz. rewrite fvML_L. rewrite fvML_L. apply fresh_spec_2. }
        apply in_list_app1 in H. destruct H as [H1 H2]. apply H1.
(* snd case *)
  - simpl. remember (fresh (fvML P1 ++ fvML P2)) as z. remember (fresh [z]) as z'.
    apply trans with (y := (substitution (Lappl (Lappl (Lvar z) (lmlc P1)) (lmlc P2)) (Labs z (Labs z' (Lvar z'))) z)).
    + apply onestep. apply redex_contraction.
    + simpl. rewrite Nat.eqb_refl. rewrite substitution_fresh_l.
      * { apply trans with (y := Lappl (substitution (Labs z' (Lvar z')) (lmlc P1) z)
            (substitution (lmlc P2) (Labs z (Labs z' (Lvar z'))) z)).
          - apply bredstar_contextual_appl.
            + apply onestep. apply redex_contraction.
            + apply refl.
          - simpl. assert (z =? z' = false).
            {
              rewrite Nat.eqb_sym. rewrite Heqz'. apply fresh_spec. simpl. rewrite Nat.eqb_refl. reflexivity.
            }
            rewrite H.
            apply trans with (y := substitution (Lvar z') (substitution (lmlc P2) (Labs z (Labs z' (Lvar z'))) z) z').
            + apply onestep. apply redex_contraction.
            + simpl. rewrite Nat.eqb_refl. rewrite substitution_fresh_l.
              * apply refl.
              * assert (in_list (fvL (lmlc P1) ++ fvL (lmlc P2)) z = false).
                { rewrite Heqz. rewrite fvML_L. rewrite fvML_L. apply fresh_spec_2. }
                apply in_list_app1 in H0. destruct H0 as [H1 H2]. apply H2.
        }
      * assert (in_list (fvL (lmlc P1) ++ fvL (lmlc P2)) z = false).
        { rewrite Heqz. rewrite fvML_L. rewrite fvML_L. apply fresh_spec_2. }
        apply in_list_app1 in H. destruct H as [H1 H2]. apply H1.








