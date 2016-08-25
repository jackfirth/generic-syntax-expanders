#lang racket

(require generic-syntax-expanders
         (for-syntax syntax/parse)
         rackunit)

(define-expander-type foo)

(define-foo-expander some-foo-expander
  (syntax-parser
    [(_ a:id b:id c:id . d:id) #'(d c b a)]))

(define-syntax (test-foo-expander stx)
  (syntax-parse stx
    [(_ e:expr)
     #`'#,(expand-all-foo-expanders #'e)]))

(test-equal?
 "Check that some-foo-expander accepts being called
 when it is the first item of a dotted list"
 (test-foo-expander (some-foo-expander x y z . t))
 '(t z y x))