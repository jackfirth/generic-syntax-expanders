#lang racket

(require  racket/match
          lenses)

(provide with-scoped-pre-transformer
         with-scoped-pre-transformers)

(define ((with-scoped-pre-transformer transformer stx-lens pre-transformer) stx)
  (transformer (lens-transform stx-lens pre-transformer stx)))

(define (with-scoped-pre-transformers transformer pre-transformer-lens-pairs)
  (match pre-transformer-lens-pairs
    ['() transformer]
    [(list (list stx-lens pre-transformer) rest ...)
     (with-scoped-pre-transformers (with-scoped-pre-transformer stx-lens transformer) rest)]))
