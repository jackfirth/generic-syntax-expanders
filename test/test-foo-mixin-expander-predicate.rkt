#lang racket

(require generic-syntax-expanders
         (for-syntax syntax/parse
                     rackunit))
(require (for-syntax generic-syntax-expanders))
(define-expander-type foo)
(define-expander-type other)
(define-foo-expander foo-exp (λ (stx) #''foo-exp-is-a-foo-expander))
(define-other-expander other-exp (λ (stx) #''other-exp-is-not-a-foo-expander))
(define-syntax not-an-expander 'syntax-local-value-is-not-an-expander)
(begin-for-syntax
  (test-not-exn
   "Check that foo-expander? can be passed any value, not just an expander?"
   (λ ()
     (foo-expander? 123)
     (void)))
  
  (test-false
   "Check that (static foo-expander?) rejects syntax that is not an identifier?"
   (syntax-parse #'(definitely not-a-foo-expander)
     [(~var exp (static foo-expander? "a foo expander")) #t]
     [_ #f]))
  
  (test-false
   "Check that (static foo-expander?) rejects an id without syntax-local-value"
   (syntax-parse #'no-syntax-local-value
     [(~var exp (static foo-expander? "a foo expander")) #t]
     [_ #f]))

  (test-begin
   (test-false
    "Check that foo-expander? rejects an id which is not an expander?"
    (foo-expander? (syntax-local-value #'not-an-expander)))
   (test-false
    "Check that foo-expander? rejects an id which is not an expander?"
    (syntax-parse #'not-an-expander
      [(~var exp (static foo-expander? "a foo expander")) #t]
      [_ #f])))

  (test-begin
   (test-false
    (string-append "Check that foo-expander? rejects an id which is an"
                   " expander? but not a foo-expander?")
    (foo-expander? (syntax-local-value #'other-exp)))
   (test-false
    (string-append "Check that foo-expander? rejects an id which is an"
                   " expander? but not a foo-expander?")
    (syntax-parse #'other-exp
      [(~var exp (static foo-expander? "a foo expander")) #t]
      [_ #f])))

  (test-begin
   (test-true
    "Check that foo-expander? accepts an id which is a foo-expander?"
    (foo-expander? (syntax-local-value #'foo-exp)))
   (test-true
    "Check that foo-expander? accepts an id which is a foo-expander?"
    (syntax-parse #'foo-exp
      [(~var exp (static foo-expander? "a foo expander")) #t]
      [_ #f]))))