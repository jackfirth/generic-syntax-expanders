#lang racket

(require scribble/manual)

(provide defpredicate)

(define-syntax-rule (defpredicate id pre-flow ...)
  (defthing #:kind "predicate" id predicate/c pre-flow ...))
