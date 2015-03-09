#lang racket

(require  (for-syntax racket/match
                      lenses))

(provide define-syntax-with-scoped-pre-transformers
         (for-syntax with-scoped-pre-transformer
                     with-scoped-pre-transformers))

(define-for-syntax ((with-scoped-pre-transformer transformer stx-lens pre-transformer) stx)
  (transformer (lens-transform stx-lens pre-transformer stx)))

(define-for-syntax (with-scoped-pre-transformers transformer pre-transformer-lens-pairs)
  (match pre-transformer-lens-pairs
    ['() transformer]
    [(list (list stx-lens pre-transformer) rest ...)
     (with-scoped-pre-transformers (with-scoped-pre-transformer stx-lens transformer) rest)]))

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
