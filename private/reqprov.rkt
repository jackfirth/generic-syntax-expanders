#lang racket/base

(require racket/require-syntax
         racket/provide-syntax
         (for-syntax racket/base
                     racket/provide-transform
                     racket/syntax
                     syntax/parse))

(provide expander-in
         expander-out)

(define-for-syntax (reqprov-transformer2 id combiner prefix)
  (with-syntax
      ([id-expander-type (format-id id "~a-expander-type" id)]
       [make-id-expander (format-id id "make-~a-expander" id)]
       [id-expander? (format-id id "~a-expander?" id)]
       [define-id-expander (format-id id "define-~a-expander" id)]
       [expand-all-id-expanders (format-id id "expand-all-~a-expanders" id)])
    #`(#,combiner (for-syntax (#,@prefix id-expander-type))
                  (for-syntax (#,@prefix make-id-expander))
                  (for-syntax (#,@prefix id-expander?))
                  (#,@prefix define-id-expander)
                  (for-syntax (#,@prefix expand-all-id-expanders)))))

(define-require-syntax expander-in
  (syntax-parser
    [(_ require-spec id:id)
     (reqprov-transformer2 #'id #'combine-in #'(only-in require-spec))]))

(define-provide-syntax expander-out
  (syntax-parser
    [(_ id:id)
     (reqprov-transformer2 #'id #'combine-out #'(combine-out))]))