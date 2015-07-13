#lang scribble/manual

@(require "example-evaluator.rkt"
          package-scribblings-tools
          (for-label racket/base
                     lens
                     generic-syntax-expanders/scoped-transformers
                     generic-syntax-expanders/define-scoped-transformers))

@module-title[generic-syntax-expanders/define-scoped-transformers]{Lens Scoped Syntax Transformers - Definition Form}

Syntax definition forms built on @racket[with-scoped-pre-transformer]
and friends.

@defform[(define-syntax-with-scoped-pre-transformers id
           ([stx-lens pre-transformer] ...)
           transformer-expr)]{
  Binds @racket[id] as a syntax transformer equivalent to
  @racket[with-scoped-pre-transformers transformer-expr ([stx-lens pre-transformer] ...)].
}
