#lang racket

(require (for-syntax "scoped-transformers.rkt"))

(provide define-syntax-with-scoped-pre-transformers)

(define-syntax define-syntax-with-scoped-pre-transformers
  (syntax-rules ()
    [(_ name ([stx-lens pre-transformer] ...) transformer-expr)
     (define-syntax name
       (with-scoped-pre-transformers transformer-expr
                              (list (list stx-lens pre-transformer) ...)))]
    [(_ (name stx) ([stx-lens pre-transformer] ...) transformer-body ...)
     (define-syntax-with-scoped-pre-transformers name
       ([stx-lens pre-transformer] ...)
       (lambda (stx) transformer-body ...))]))
