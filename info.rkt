#lang info

(define collection 'multi)


(define deps
  '("base"
    "rackunit-lib"
    "fancy-app"
    "mischief"
    "lenses"
    "point-free"
    "predicates"
    "scribble-lib"
    "scribble-text-lib"))


(define build-deps
  '("cover"
    "scribble-lib"
    "rackunit-lib"
    "racket-doc"
    "package-scribblings-tools"))
