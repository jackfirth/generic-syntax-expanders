#lang racket/base

(require (for-syntax racket/base
                     racket/require-transform
                     racket/provide-transform
                     racket/syntax))

(provide expander-in
         expander-out)

(define-for-syntax ((reqprov-transformer combiner) stx)
  (syntax-case stx ()
    [(_ id)
     (identifier? #'id)
     (with-syntax
         ([id-expander-type (format-id #'id "~a-expander-type" #'id)]
          [make-id-expander (format-id #'id "make-~a-expander" #'id)]
          [id-expander? (format-id #'id "~a-expander?" #'id)]
          [define-id-expander (format-id #'id "define-~a-expander" #'id)]
          [expand-all-id-expanders (format-id #'id "expand-all-~a-expanders" #'id)])
       #'(combiner id-expander-type
                   make-id-expander
                   id-expander?
                   define-id-expander
                   expand-all-id-expanders))]))

(define-syntax expander-in
  (make-require-transformer
   (reqprov-transformer #'combine-in)))

(define-syntax expander-out
  (make-provide-transformer
   (reqprov-transformer #'combine-out)))

