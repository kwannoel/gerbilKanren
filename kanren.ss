;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;; MicroKanren in Gerbil Scheme ;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Kanren means relation in Japanese, Mini / Micro emphasizes the fact the the kernel of this language is
;; rather small and portable. It can and has been embedded in a series of languages. See: minikanren.org.
;;
(export #t)
;;
;; ;;;;;;;;;;;;;;;;;
;; ;; Description ;;
;; ;;;;;;;;;;;;;;;;;
;;
;; A relation is a set of mappings between elements of 2 sets.
;; We can do so constructively (actually drawing the lines between elements),
;; Or restrictively, by saying what should not be mapped, and through elimination the rest have mappings.
;;
;; Some scenarios where relations can be useful in programs:
;;
;; 1. We have an initial data structure, maybe arrays of useful data. We can apply constraints to this data.
;;    We can obtain the filtered results.
;;
;; 2. We have the resulting data structure. A relation goes both ways, we can go in reverse as well,
;;    get defintiions of possible initial sets.
;;
;; However, this is not sufficient. In programs we might want to introduce new variables as well.
;; How can we reconcile this with relations?
;;
;; MiniKanren approaches this by saying that the set we are mapping from contains 2 things:
;;
;; 1. A way to construct new variables
;; 2. A way to say what is bound to what data structures / variables
;;
;; For 1. this can simply be a variable counter.
;; For 2. this can simply be an association list of variable to their values
;;
;; We call this the program state.
;;
;; state := (var-counter, assoc-list)
(def (mk-state c assocs) (cons c assocs))
(def (get-c st) (car st))
(def (get-assocs st) (cdr st))
;; assoc-list := ((var, value) ...)
(def (get-var assoc) (car assoc))
(def (get-val assoc) (cdr assoc))
;; value = var | prims | cons value value
(def (var c) (vector c))
(def (var? v) (vector? v))
(def (var=? v1 v2) (= (vector-ref v1 0) (vector-ref v2 0)))
;;
;; Next, we formalize a relation as well.
;; relation := state -> (state ...)
;;
;; But hey! Isn't a relation between 2 sets, shouldn't it be defined as:
;; relation := state -> state ?
;;
;; Well, earlier we mentioned "restrictive" way of relating 2 sets.
;; Turns out this may not be *deterministic* in the sense of returning one possible result.
;; Suppose we say given a set of integers, any valid output sets contain only even numbers.
;; Given set: {1, 2, 3, 4, 5, 6}
;; Possible output sets: {}, {2}, {4}, {6}, {2, 4}, ... you get the idea.
;;
;; Thus (state ...) represents this (possibly infinite) possibilities.
;;
;; With all these in mind, we are ready to write out relational program interpreter.

;; We will program this kanren from top-down, starting from the program interpreter interface:
;; It should accept:
;; 1. An environment (initialState)
;; 2. A relation we want to satisfy
;;
;; We call it run*, since it returns all resultant states (0 or more).
;;
;; run* : state -> relation -> (state ...)

(def (run* state rel)
  (rel state))

;; We then define our initial state
;; It is the initial var-counter, 0
;; And the assoc list: empty-list, '()
(def state0 '(0 . ())) ; Can also be written as: (define state0 '(0))

;; We can define a toy-relation, which maps each element to itself
;; (def (id state)
;;   (list state))

;; Running the relation
;; (run* state0 id)
;;
;; The first utility function: FRESH
;; FRESH helps us to instantiate new variables, for use in relations
;; Let us see how we can use it:
;; (fresh
;;  (lambda (a) ; our fresh variable
;;    (lambda (state) ; input program state
;;      (list (cons (car state) ; we preserve the counter
;;                  (cons (cons a 1) (cdr state)) ; create a binding to 'a'
;;                  )))))
;; 1. The `fresh` variable gets introduced into scope with `lambda`
;; 2. We declare what we want to do with it.
;;
;;    Since we return a relation, we can update state as necessary,
;;    to introduce bindings for the `fresh` var.

;; Hence this will be our definition for fresh
(def (fresh f)
  (lambda (state)
    (let ((var-count (car state))
          (assoc-list (cdr state)))
      (f var-count (cons (+ var-count 1) assoc-list)))))

;; Next, we want a relation of equality
;; This allows us relate terms of our program
;; e.g. (== a b), which unifies a and b
(def (== t1 t2)
  (lambda (state)
    (let ((new-assocs? (unify t1 t2 (get-assocs state)))) ;; Unify t1, t2 with association list
      (cond
       ([new-assocs? (list (mk-state (get-c state) new-assocs?))]
        '())))))

;; Unification of terms, (t1, t2) with an association list (assocs)
(def (unify t1 t2 assocs)
  (let ((t1_ (walk t1 assocs)) ;; Get the current bindings for t1
        (t2_ (walk t2 assocs))) ;; as above, for t2
    (cond
      ([(and (var? t1_) (var? t2_) (var=? t1_ t2_)) assocs] ;; Equivalent, no need to update
       [(var? t1_) (ext-assocs t1_ t2_ assocs)] ;; Assignment to unify
       [(var? t2_) (ext-assocs t2_ t1_ assocs)] ;; as above
       [(and (pair? t1_) (pair? t2_)) ;; Unify their pair-components
        (let ((new-assocs (unify (car t1_) (car t2_) assocs))) ;; Unify head
          (and new-assocs (unify (cdr t1_) (cdr t2_) new-assocs)) ;; If head can be unified, unify tail as well
          )]
      (and (eqv? t1_ t2_) assocs))))) ;; Otherwise both are equivalent values / cannot be unified

(def (ext-assocs var val assocs)
     (cons (cons var val) assocs))

;; Traverse to the end
;; Note: If cycles exist we will walk indefinitely
(def (walk t assocs)
     (let ((assoc (assp (lambda (asc) (var=? t (get-var asc))) assocs)))
       (and assoc ;; If we find an assoc-pair,
            (let ((val (get-val assoc)))
              (if (var? (get-val assoc))
                (walk t (get-val assoc)) ;; Continue to get var bindings
                (get-val assoc)))))) ;; otherwise return the prim val

(def (assp pred l)
     (and (pair? l)
          (if (pred (car l))
              (car l)
              (assp pred (cdr l)))))

;; Next we'd like conjunction (AND) of relations
(def (conj r1 r2)
     (lambda (state)
       (bind (r1 state) r2)))

;; bind here is for list-monad
(def (bind h/t f)
     (if (pair? h/t)
         (mplus (f (car h/t))
                (bind (cdr h/t) f))
         '()))

;; Interleaving list concatenation
(def (mplus l1 l2)
     (cond ([(null? l1) l2]
            [(null? l2) l1]
            (cons (car l1) (mplus l2 (cdr l1))))))

;; Finally we'd like to have disjunction (OR) of relations
(def (disj r1 r2)
     (lambda (state)
       (mplus (r1 state) (r2 state))))
