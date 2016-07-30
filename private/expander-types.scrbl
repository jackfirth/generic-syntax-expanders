#lang scribble/manual
@(require "doc-util.rkt")

@title{Expander Types}

Under the hood, each generic expander defined with this library has
an associated @italic{expander type}. Syntax transformers built
with this library examine this type to determine whether or not
they should expand them.

@defpredicate[expander-type?]{
 A predicate for values produced by @racket[make-expander-type] and
 variants.
 @generic-syntax-examples[
 (expander-type? (make-expander-type))
 (expander-type? 'foo)]}

@defproc[(make-expander-type) expander-type?]{
 Creates a unique @racket[expander-type?] for use in defining a new
 kind of generic expander.
 @generic-syntax-examples[
 (make-expander-type)]}

@defproc[(make-union-expander-type [type expander-type?] ...+) expander-type?]{
 Creates a union @racket[expander-type?]. This union type includes
 all of the given types, as well as any union type of a subset of
 the given types.
 @generic-syntax-examples[
 (make-union-expander-type (make-expander-type) (make-expander-type))]}

@defproc[(expander-type-includes? [type-1 expander-type?] [type-2 expander-type?]) boolean?]{
 Returns @racket[#t] if the two types are either identical, or if either
 type is a union type that contains the other, or if both types are
 union types and contain a nonempty intersection. Returns @racket[#f]
 otherwise.
 @generic-syntax-examples[
 (define A (make-expander-type))
 (define B (make-expander-type))
 (define C (make-expander-type))
 (expander-type-includes? A A)
 (expander-type-includes? B C)
 (define AB (make-union-expander-type A B))
 (define BC (make-union-expander-type B C))
 (expander-type-includes? AB A)
 (expander-type-includes? AB C)
 (expander-type-includes? AB BC)]}
