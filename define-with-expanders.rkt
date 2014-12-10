#lang racket

(require syntax/parse/define
         (for-syntax syntax/parse
                     syntax/parse/define
                     racket/syntax
                     predicates
                     (for-syntax racket/base
                                 syntax/parse)))

(define-for-syntax (disp a) (displayln a) a)

(define-for-syntax syntax-list? (and? syntax? (compose list? syntax->list)))
(define-for-syntax (identifier-bound-to? p)
  (and? identifier? (compose p maybe-syntax-local-value)))

(define-for-syntax (maybe-syntax-local-value stx)
  (syntax-local-value stx (λ () #f)))

(define-for-syntax ((stx-expander expand? transformer) stx)
  (if (expand? stx)
      (transformer stx)
      (syntax-parse stx
        [(a . b) #`(#,((stx-expander expand? transformer) #'a)
                    #,@((stx-expander expand? transformer) #'b))]
        [() #'()]
        [a #'a])))

(begin-for-syntax
  (define-simple-macro (with-derived-ids ([pat-id:id format base-id-stx] ...) stx-expr)
    (with-syntax ([pat-id (format-id base-id-stx format base-id-stx)] ...)
      stx-expr)))

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
                       (compose
                        (list-with-head? (identifier-bound-to? foo-expander?))
                        syntax->list)
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

(define-syntax-with-expanders foo
  (syntax-parser
    [(_ blah ...)
     #'(blah ...)]))

(define-foo-expander baz
  (syntax-parser
    [(_ n:number blah)
     #'blah]))

