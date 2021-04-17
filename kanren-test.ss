(import :kanren)
(import :kanren-test-utils)

(test-equal? "test function success" 1 1)
(test-equal? "test function fail" 1 2)

(test-equal? "Lookup success"
             (lookup (var 1) (list (cons (var 1) 1)))
             1)

(test-equal? "Lookup fail"
             (lookup (var 1) (list (cons (var 0) 1)))
             #f)

(test-equal? "Lookup empty"
             (lookup (var 1) '())
             #f)

(test-equal? "walk around nowhere"
             (walk (var 1) '())
             (var 1))

(test-equal? "walk around somewhere"
             (walk (var 0) (list (cons (var 0) 1)))
             1)

(test-equal? "walk into var"
             (walk (var 0) (list (cons (var 0) (var 2))))
             (var 2))

(test-equal? "walk with prims"
             (walk 1 '(list (cons 1 2)))
             1)

(test-equal? "is var"
             (var? (var 1))
             #t)

(test-equal? "is not var"
             (var? 1)
             #f)

;; (test-equal? "cmp var, not var"
;;              (var=? (var 0) 1)
;;              #f)

(test-equal? "extends assocs"
             (ext-assocs (var 0) 1 '())
             (list (cons (var 0) 1)))

(test-equal? "unify vars"
             (unify (var 0) (var 1) '())
             (list (cons (var 0) (var 1))))

(test-equal? "unify with empty assocs-list"
             (unify (var 0) 1 '())
             (list (cons (var 0) 1)))

(test-equal? "== success"
             ((== (var 1) 1) state0)
             (list (cons 0 (list (cons (var 1) 1)))))

(test-equal? "fresh success"
             (let ((r (fresh (lambda (a) (== a 1)))))
               (run* state0 r))
             (list (cons 1 (list (cons (var 0) 1)))))

(test-equal? "conj success"
             (let ((r (fresh (lambda (a)
                               (fresh (lambda (b)
                                        (conj (== a 1)
                                              (== a b))))))))
               (run* state0 r))
             (list (cons 2 (list (cons (var 1) 1) (cons (var 0) 1)))))

(test-equal? "disj success"
             (let ((r (fresh (lambda (a)
                               (disj (== a 1)
                                     (== a 2))))))
               (run* state0 r))
             (list (cons 1 (list (cons (var 0) 1)))
                   (cons 1 (list (cons (var 0) 2)))))
