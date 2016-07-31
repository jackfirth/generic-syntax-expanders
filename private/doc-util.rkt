#lang at-exp racket/base

(provide (for-label (all-from-out generic-syntax-expanders
                                  racket/base
                                  racket/contract))
         defpredicate
         generic-syntax-examples
         source-code)

(require (for-label generic-syntax-expanders
                    racket/base
                    racket/contract)
         scribble/example
         scribble/manual
         scribble/text)


(define requirements
  '(generic-syntax-expanders))

(define (make-eval)
  (make-base-eval #:lang 'racket/base
                  (cons 'require requirements)))

(define-syntax-rule (generic-syntax-examples example ...)
   (examples #:eval (make-eval) example ...))

(define-syntax-rule (defpredicate id pre-flow ...)
  (defthing #:kind "procedure" id predicate/c pre-flow ...))

(define (source-code dest-url)
  @begin/text{Source code is available at @url[dest-url]})
