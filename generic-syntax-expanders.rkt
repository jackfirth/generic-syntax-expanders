#lang racket

(require syntax/parse/define
         (for-syntax syntax/parse
                     "stx-utils.rkt"))

(provide define-syntax-with-expanders)

(define-syntax define-syntax-with-expanders
  (syntax-parser
    [(_ foo:id transformer-expr)
     (with-derived-ids ([foo-expander "~a-expander" #'foo]
                        [foo-expander? "~a-expander?" #'foo]
                        [foo-expander-transformer "~a-expander-transformer" #'foo]
                        [define-foo-expander "define-~a-expander" #'foo])
       #'(begin
           (define-expander-struct foo-expander)
           (define-expander-definer define-foo-expander foo-expander)
           (define-syntax foo
             (compose transformer-expr
                      (stx-expander
                        (syntax-list-with-head? (identifier-bound-to? foo-expander?))
                        (λ (expander-stx)
                          (call-expander foo-expander-transformer
                                         (car (syntax->list expander-stx))
                                         expander-stx)))))))]))

;; Helpers for define-syntax-with-expanders

;; Binds id as a struct at phase level 1 that will contain a single field named "transformer"
;; that is a procedure accepting a syntax object and returning a syntax object
(define-simple-macro (define-expander-struct id:id)
  (begin-for-syntax
    (struct id (transformer))))

;; Binds definer-id as a form that defines expanders for another syntactic form by using the
;; phase level 1 struct created with define-expander-struct
(define-simple-macro (define-expander-definer definer-id:id expander-struct-id:id)
  (define-simple-macro (definer-id expander:id transformer)
    (define-syntax expander
      (expander-struct-id transformer))))

;; Small helper that assumes expander-stx is an identifier bound to an expander struct value
;; at phase level 1, and extracts the expander's transformer procedure with accessor then
;; calls that transformer on stx-to-expand
(define-for-syntax (call-expander accessor expander-stx stx-to-expand)
  ((accessor (syntax-local-value expander-stx)) stx-to-expand))