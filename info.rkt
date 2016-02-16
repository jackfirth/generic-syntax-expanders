#lang info

(define collection 'multi)


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
  '("cover"
    "cover-coveralls"
    "scribble-lib"
    "rackunit-lib"
    "racket-doc"
    "git://github.com/jackfirth/package-scribblings-tools))


(define test-omit-paths
  '("info.rkt"
    "generic-syntax-expanders/info.rkt"
    "generic-syntax-expanders/scribblings"))
