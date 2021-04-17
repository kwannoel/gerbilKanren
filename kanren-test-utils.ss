(export #t)

;; Since this module is a test-library,
;; we'd like to compile it via `gxc`.
;;
;; However, it will fail to compile if define as a function,
;; because `println` is only available in interactive environment.
;;
;; Workaround: define `test-equal' as a macro.
;; `define-syntax` only expands during runtime phases (but before evaluation).
(define-syntax test-equal?
  (syntax-rules ()
    ((test-equal? stmt actual expected)
     (begin (print stmt ": ")
            (if (equal? expected actual)
                (println "SUCCESS\n")
                (begin (println "FAIL\nexpected:")
                       (display expected)
                       (println "\n\nactual:")
                       (display actual)
                       (println "\n")))))))
