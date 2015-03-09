#lang racket

(require "main.rkt"
         lenses
         racket/match
         (for-syntax syntax/parse))

(define-expander-type cond)

(define-syntax my-cond
  (compose
   (syntax-parser
     [(_ cond-clause ...)
      #'(cond cond-clause ...)])
   expand-all-cond-expanders))

(define-cond-expander $m
  (syntax-parser
    [(_ val pat body ...)
     #'[(match val [pat #t] [_ #f]) (match val [pat body ...])]]))

(my-cond [$m '(1 2 3) (list a b c) (+ a b c)]
         [else 'bar])