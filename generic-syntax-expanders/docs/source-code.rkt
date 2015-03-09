#lang racket

(require scribble/manual
         scribble/text)

(provide source-code)

(define (source-code link)
  (list "Source code can be found at " (url link)))
