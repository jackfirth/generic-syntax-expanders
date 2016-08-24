#lang racket

(require (for-syntax syntax/parse
                     "expander-types.rkt"
                     "expanders.rkt"
                     "with-identifiers.rkt"))

(provide define-expander-type)

(define-for-syntax (remove-use-site-scope stx)
  (define bd
    (syntax-local-identifier-as-binding (syntax-local-introduce #'here)))
  (define delta
    (make-syntax-delta-introducer (syntax-local-introduce #'here) bd))
  (delta stx 'remove))

(define-syntax define-expander-type
  (syntax-parser
    [(_ name:id)
     (with-derived-ids #'name ([?-expander-type "~a-expander-type"]
                               [make-?-expander "make-~a-expander"]
                               [?-expander? "~a-expander?"]
                               [define-?-expander "define-~a-expander"]
                               [define-?-expander-bug "define-~a-expander-bug"]
                               [expand-all-?-expanders "expand-all-~a-expanders"])
                       #`(begin
                           (define-for-syntax ?-expander-type (make-expander-type))
                           (define-for-syntax (make-?-expander transformer)
                             (expander ?-expander-type transformer))
                           (define-for-syntax (?-expander? v)
                             (expander-of-type? ?-expander-type v))
                           (define-syntax (define-?-expander stx)
                             (syntax-case stx ()
                               [(_ expander-name transformer)
                                (remove-use-site-scope
                                 #'(define-syntax expander-name (make-?-expander transformer)))]))
                           (define-for-syntax (expand-all-?-expanders stx)
                             (expand-syntax-tree-with-expanders-of-type ?-expander-type stx))))]))
