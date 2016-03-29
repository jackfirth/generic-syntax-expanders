#lang scribble/manual
@(require "doc-util.rkt")

@title{Lens Scoped Syntax Transformers - Definition Form}

Syntax definition forms built on @racket[with-scoped-pre-transformer]
and friends.

@defform[(define-syntax-with-scoped-pre-transformers id
           ([stx-lens pre-transformer] ...)
           transformer-expr)]{
 Binds @racket[id] as a syntax transformer that is equivalent to
 @racket[(with-scoped-pre-transformers transformer-expr ([stx-lens pre-transformer] ...))].
}
