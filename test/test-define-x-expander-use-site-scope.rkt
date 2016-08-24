#lang racket

;; This test is a real-world use case for the simplified test in the
;; test-define-x-expander-use-site-scope-simple.rkt file. See that other
;; file for more thorrough explanations.

(require syntax/parse
         syntax/parse/experimental/eh
         generic-syntax-expanders
         syntax/stx
         (for-syntax syntax/parse
                     racket/syntax)
         rackunit)

(define-expander-type eh-mixin)

(define-for-syntax eh-post-accumulate (make-parameter #f))

(define-for-syntax (strip-use-site stx)
  (define bd
    (syntax-local-identifier-as-binding (syntax-local-introduce #'here)))
  (define delta
    (make-syntax-delta-introducer (syntax-local-introduce #'here) bd))
  (delta stx 'remove))

(define-syntax define-eh-alternative-mixin
  (syntax-parser
    [(_ name ((~literal pattern) pat) ... (~optional (~seq #:post post)))
     (let ()
       #`(define-eh-mixin-expander name
           (λ (_)
             #,@(if (attribute post)
                    #`(((eh-post-accumulate) (quote-syntax post)))
                    #'())
             (quote-syntax (~or . #,(strip-use-site #'(pat ...)))))))]))

(define-syntax ~no-order
  (pattern-expander
   (λ (stx)
     (syntax-case stx ()
       [(self pat ...)
        (let ()
          (define acc '())
          (define (add-to-acc p)
            (set! acc (cons p acc)))
          (define alts
            (parameterize ([eh-post-accumulate add-to-acc])
              (expand-all-eh-mixin-expanders
               #'(pat ...))))
          #`(~and (~seq (~or . #,alts) (... ...))
                  #,@acc))]))))

;; Test:

(define-eh-alternative-mixin aa
  (pattern (~optional (~and some-pat #:some))))

(define-eh-alternative-mixin bb
  (pattern (~optional (~and other-pat #:other)))
  ;; Without the fix in PR #8, the following line gives the error
  ;;   attribute: not bound as a pattern variable in: some-pat
  #:post (~fail #:when (and (attribute some-pat)
                            (attribute other-pat))))

(test-true
 "Test that `#:some` and `#:other` are mutually exclusive.
This test will not compile without PR #8.
* `aa` expands to `(~and some-pat #:some)`
* `bb` expands to `(~and other-pat #:other)`
* `bb` injects after the unorderd sequence the check
       `(and (attribute some-pat) (attribute other-pat))`
However, without the patch, `some-pat` inside the expression
 `(and (attribute some-pat) (attribute other-pat))` has an extra
 scope ¹ added by `define-eh-mixin-expander` on the whole body
 of `bb`, while the pattern `(~and some-pat #:some)` has an extra
 scope ² added by `define-eh-mixin-expander` on the whole body
 of `aa`.
This means that `some-pat` inside the check is unbound, and the
 compiler gives an error on the `some-pat` identifier declared
 above."
 (syntax-parse #'(#:some #:other)
   [((~no-order (aa) (bb))) #f]
   [_ #t]))

(test-true
 "Test that `#:some` on its own is accepted.
 This test will not compile without PR #8 for the same reason as the
 mutually-exclusive test above."
 (syntax-parse #'(#:some)
   [((~no-order (aa) (bb))) #t]))

(test-true
 "Test that `#:other` on its own is accepted.
 This test will not compile without PR #8 for the same reason as the
 mutually-exclusive test above."
 (syntax-parse #'(#:other)
   [((~no-order (aa) (bb))) #t]))