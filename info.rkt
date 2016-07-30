#lang info
(define collection "generic-syntax-expanders")
(define name "generic-syntax-expanders")
(define scribblings '(("main.scrbl" () (library) "generic-syntax-expanders")))
(define deps
  '("base"
    "rackunit-lib"
    "fancy-app"
    "reprovide-lang"
    "lens"
    "point-free"
    "predicates"
    "scribble-lib"
    "scribble-text-lib"))
(define build-deps
  '("scribble-lib"
    "rackunit-lib"
    "racket-doc"))
(define compile-omit-paths
  '("private"))
(define test-omit-paths
  '(#rx"\\.scrbl$"
    #rx"info\\.rkt$"
    #rx"doc-util\\.rkt$"))
