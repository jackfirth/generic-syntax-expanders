#lang racket

(require (for-syntax syntax/parse))

(require generic-syntax-expanders)

(define-syntax-with-expanders blah
  (syntax-parser
    [(_ (any ...))
     #'(begin (foo any) ...)]))

(define-blah-expander baz
  (syntax-parser
    [(_ n:number)
     #`(#,@(build-list (syntax-e #'n) values))]))

(expand-once #'(blah (1 2 3 4 5)))
;; => expands to (begin (foo 1) (foo 2) (foo 3) (foo 4) (foo 5))

(expand-once #'(blah (baz 5)))
;; => expands to (begin (foo 0) (foo 1) (foo 2) (foo 3) (foo 4))
