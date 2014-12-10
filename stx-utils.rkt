#lang racket

(require predicates
         racket/syntax
         syntax/parse
         syntax/parse/define)

(provide with-derived-ids
         identifier-bound-to?
         stx-expander
         syntax-list-with-head?)

(define (disp a) (displayln a) a)

;; Takes a predicate p and produces a predicate satisfied by syntax objects
;; which are identifiers bound to values satisfying p
(define (identifier-bound-to? p)
  (and? identifier?
        (compose p maybe-syntax-local-value)))

(define (syntax-list-with-head? . ps)
  (compose (apply list-with-head? ps)
           syntax->list))

;; Falsey non-throwing verison of syntax-local-value
(define (maybe-syntax-local-value stx)
  (syntax-local-value stx (λ () #f)))

;; Takes a syntax-object predicate and a syntax transformer, then returns
;; a procedure that parses a syntax object and determines at each level of
;; the syntax tree if that subtree satisfies the predicate. If it does,
;; that subtree is replaced with the result of (transformer subtree-stx)
(define ((stx-expander expand? transformer) stx)
  (if (expand? stx)
      (transformer stx)
      (syntax-parse stx
        [(a . b) #`(#,((stx-expander expand? transformer) #'a)
                    #,@((stx-expander expand? transformer) #'b))]
        [() #'()]
        [a #'a])))

;; Shorthand for adding new identifiers based on other formatted ones to
;; syntax patterns
(define-simple-macro (with-derived-ids ([pat-id:id format base-id-stx] ...) stx-expr)
  (with-syntax ([pat-id
                 (format-id base-id-stx
                            format
                            base-id-stx)] ...)
    stx-expr))

