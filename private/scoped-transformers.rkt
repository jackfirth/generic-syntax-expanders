#lang racket

(require  racket/match
          lens)

(provide with-scoped-pre-transformer
         with-scoped-pre-transformers)

(define ((with-scoped-pre-transformer transformer stx-lens pre-transformer) stx)
  (transformer (lens-transform stx-lens stx pre-transformer)))

(define (with-scoped-pre-transformers transformer pre-transformer-lens-pairs)
  (match pre-transformer-lens-pairs
    ['() transformer]
    [(list (list stx-lens pre-transformer) rest ...)
     (define next-transformer
       (with-scoped-pre-transformer transformer stx-lens transformer))
     (with-scoped-pre-transformers next-transformer rest)]))
