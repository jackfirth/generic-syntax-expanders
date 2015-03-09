#lang racket

(require fancy-app
         predicates
         point-free)

(provide
 (contract-out
  [expander-type? predicate/c]
  [make-expander-type (-> expander-type?)]
  [make-union-expander-type (->* (expander-type?) () #:rest expander-type? expander-type?)]
  [expander-type-includes? (-> expander-type? expander-type? boolean?)]))

(define (type-includes? symtree-type1 symtree-type2)
  (define flat-type1 (flatten symtree-type1))
  (define flat-type2 (flatten symtree-type2))
  (true? (ormap (member _ flat-type1) flat-type2)))

(struct expander-type (symtree-type) #:prefab)

(define (make-expander-type)
  (expander-type (gensym)))

(define (make-union-expander-type . expander-types)
  (define symtree-types (map expander-type-symtree-type expander-types))
  (expander-type symtree-types))

(define/wind-pre* expander-type-includes?
  type-includes? expander-type-symtree-type)
