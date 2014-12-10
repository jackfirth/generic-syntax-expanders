#lang scribble/manual

@(require "generic-syntax-expanders.rkt")

@title{Generic Syntax Expanders}
@defmodule[generic-syntax-expanders]

@defform[(define-syntax-with-expanders id transformer-expr)]{
Defines @racket[id] as syntax, but also defines several additional bindings that allow
for additional syntax to be defined within the body of wherever @racket[id] is used,
in the same way @racket[define-match-expander] allows for additional syntax to be
defined in the body of @racket[match] patterns. The bindings defined are as follows:
@defsubform[(define-id-expander expander-id expander-transformer-expr)]{
A syntactic form that binds @racket[expander-id] as a @racket[id-expander?], which
will expand within the body of an @racket[id] syntactic form using
@racket[expander-transformer-expr] before @racket[id] expands.
}
}