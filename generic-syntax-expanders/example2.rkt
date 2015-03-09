#lang racket

(require "example.rkt")

(begin-for-syntax
  (displayln (expand-all-foo-expanders #'(foo-bar 1 (foo-bar 'a 'b 'c) 3))))
