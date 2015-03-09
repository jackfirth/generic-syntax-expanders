#lang racket

(require scribble/eval)

(provide package-examples)

(define generic-syntax-expanders-eval (make-base-eval))
(generic-syntax-expanders-eval '(require generic-syntax-expanders))

(define-syntax-rule (package-examples example-body ...)
  (examples #:eval generic-syntax-expanders-eval example-body ...))