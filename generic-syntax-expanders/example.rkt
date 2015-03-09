#lang racket

(require "main.rkt"
         (for-syntax syntax/parse))

(provide foo-bar
         foo-blah
         (for-syntax expand-all-foo-expanders))

(define-expander-type foo)

(define-foo-expander foo-bar
  (syntax-parser
    [(_ a b c) #'b]))

(define-foo-expander foo-blah
  (syntax-parser
    [(_ ...) #'blah]))
