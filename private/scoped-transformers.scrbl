#lang scribble/manual
@(require "doc-util.rkt")

@title{Lens Scoped Syntax Transformers}

This module uses the @racket[lens] package to create syntax transformers
that affect only some small subpiece of a syntax object and compose them
with other transformers. This allows for the creation of a macro that cedes
control to other macros to pre-expand parts of its body before the macro
expands. Combined with the syntax transformer produced by @racket[define-expander-type],
this makes it easy to define a macro that expands all instances of a generic
expander type in a specific subpiece of its body, turning it into an
extensible macro.

@defproc[((with-scoped-pre-transformer
           [transformer (-> syntax? syntax?)]
           [stx-lens lens?]
           [pre-transformer (-> syntax? syntax?)])
          [stx syntax?])
         syntax?]{
 Transformers @racket[stx] in two passes. First, the piece of @racket[stx]
 that @racket[stx-lens] views is transformed with @racket[pre-transformer].
 Then, the entire resulting syntax object is transformed with @racket[transformer].}

@defproc[((with-scoped-pre-transformers
           [transformer (-> syntax? syntax?)]
           [pre-transformer-lens-pairs
            (listof (list/c lens?
                            (-> syntax? syntax?)))])
          [stx syntax?])
         syntax?]{
 Similar to @racket[with-scoped-pre-transformer]. Given @racket[pre-transformer-lens-pairs],
 a list of pairs of lenses and transformers, @racket[transformer] is wrapped
 with @racket[with-scoped-pre-transformer] with the pair's pre-transformer
 and lens. The last pair in @racket[pre-transformer-lens-pairs] is applied
 to @racket[stx] first.}
