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
;; assoc-list := ((var-id, value) ...)
;;
;; value = var-id | data-structures
;;
;; data-structures = ???
;;
;; Assuming we are only dealing with discrete data structures, these can just be represented as:
;; 1. primitives: booleans, integers, atoms, etc..
;; 2. products/pairs of valid values
;;
;; Hence,
;; value = var-id
;;         | prims
;;         | pair value value
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
;; Let us see how we can use it
(fresh
 (lambda (a) ; our fresh variable
   (lambda (state) ; input program state
     (list (cons (car state) ; we preserve the counter
                 (cons (cons a 1) (cdr state)) ; create a binding to 'a'
                 )))))
;; In most language, we declare the variable's name, and what it is bound to.
;; In a relational language, we declare the variable's name,
;; as well as a relation:
(def (fresh f)
  (lambda (state)
    (let ([var-count (car state)]
          [assoc-list (cdr state)])
      (f var-count (cons (+ var-count 1) assoc-list)))))

;; Example of using fresh
