#lang racket
(require generic-syntax-expanders rackunit)
(define-expander-type foo)
(define-foo-expander foo1 (λ _ #''ok))
(define-syntax (bar stx)
  (syntax-case stx ()
    [(_ body)
     (expand-all-foo-expanders #'body)]))
;; When hovering "foo1" in the code below with the mouse, an arrow should 
;; be shown in DrRacket from the foo1 in (define-foo-expander foo1 …) above.
;; This is not automatically checked, as it would be difficult/brittle to check
;; for the syntax property. Patches welcome.
(check-equal? (bar (foo1)) 'ok)