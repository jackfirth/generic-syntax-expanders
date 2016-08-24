#lang racket

(require syntax/parse
         syntax/parse/experimental/eh
         generic-syntax-expanders
         syntax/stx
         (for-syntax syntax/parse
                     racket/syntax)
         rackunit)

(define-expander-type eh-mixin)

(begin-for-syntax
  (define eh-post-accumulate (make-parameter #f)))

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

(check-equal? (syntax-parse #'(#:some)
                [((~no-order (aa) (bb))) 'ok])
              'ok)

(check-equal? (syntax-parse #'(#:other)
                [((~no-order (aa) (bb))) 'ok])
              'ok)

(check-equal? (syntax-parse #'(#:some #:other)
                [((~no-order (aa) (bb))) 'wrong]
                [_ 'ok])
              'ok)