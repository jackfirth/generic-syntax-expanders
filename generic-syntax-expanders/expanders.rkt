#lang racket

(require "expander-types.rkt"
         syntax/parse
         syntax/stx
         predicates
         fancy-app)

(provide (struct-out expander)
         (contract-out
          [expander-of-type? (-> expander-type? expander? boolean?)]
          [expand-syntax-tree-with-expanders-of-type (-> expander-type? syntax? syntax?)]))

(define (maybe-syntax-local-value stx)
  (syntax-local-value stx (λ () #f)))

(struct expander (type transformer))

(define (expander-of-type? type expander)
  (expander-type-includes? type (expander-type expander)))

(define (expander-stx? v)
  (and (syntax? v)
       (syntax-parse v
         [(id:id _ ...) (expander? (maybe-syntax-local-value #'id))]
         [_ #f])))

(define (expander-stx->expander expander-stx)
  (syntax-parse expander-stx
    [(id:id _ ...) (maybe-syntax-local-value #'id)]))

(define (expander-stx-of-type? type v)
  (and (expander-stx? v)
       (expander-of-type? type (expander-stx->expander v))))

(define (expand-syntax-tree fully-expanded-node? expand-syntax-once stx)
  (if (fully-expanded-node? stx)
      (syntax-parse stx
        [(a ...) (datum->syntax stx (stx-map (expand-syntax-tree fully-expanded-node? expand-syntax-once _) #'(a ...)))]
        [a #'a])
      (expand-syntax-tree fully-expanded-node? expand-syntax-once (expand-syntax-once stx))))

(define (call-expander-transformer expander-stx)
  (define expander (expander-stx->expander expander-stx))
  (define transformer (expander-transformer expander))
  (transformer expander-stx))

(define (expand-syntax-tree-with-expanders-of-type type stx)
  (define not-expander-stx-of-type? (not? (expander-stx-of-type? type _)))
  (expand-syntax-tree not-expander-stx-of-type?
                      call-expander-transformer
                      stx))