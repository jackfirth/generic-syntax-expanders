#lang racket

(require (for-syntax syntax/parse
                     "expander-types.rkt"
                     "expanders.rkt"
                     "with-identifiers.rkt"))

(provide define-expander-type)

(define-syntax define-expander-type
  (syntax-parser
    [(_ name:id)
     (with-derived-ids #'name ([?-expander-type "~a-expander-type"]
                               [make-?-expander "make-~a-expander"]
                               [?-expander? "~a-expander?"]
                               [define-?-expander "define-~a-expander"]
                               [expand-all-?-expanders "expand-all-~a-expanders"])
                       #'(begin
                           (define-for-syntax ?-expander-type (make-expander-type))
                           (define-for-syntax (make-?-expander transformer)
                             (expander ?-expander-type transformer))
                           (define-for-syntax (?-expander? v)
                             (expander-of-type? ?-expander-type v))
                           (define-syntax-rule (define-?-expander expander-name transformer)
                             (define-syntax expander-name (make-?-expander transformer)))
                           (define-for-syntax (expand-all-?-expanders stx)
                             (expand-syntax-tree-with-expanders-of-type ?-expander-type stx))))]))
