#lang scribble/manual

@(require "example-evaluator.rkt"
          "defpredicate.rkt"
          "module-title.rkt"
          (for-label racket/base
                     generic-syntax-expanders/expanders
                     generic-syntax-expanders/expander-types))

@module-title[generic-syntax-expanders/expanders]{Expanders And Transformers}

Generic expanders are implemented as values of the @racket[expander?] struct
bound with @racket[define-syntax], that store both a type and a transformer
procedure. Future versions of this library may support storing an additional
transformer for use outside expander-contexts in normal syntax parsing. This
could be used for better error messages, or for an expander meant to have
meaning in both a particularly typed expansion context and a normal expression
expansion context.

@defstruct[expander ([type expander-type?] [transformer (-> syntax? syntax?)])]{
  A structure type for generic syntax expanders. A generic syntax expander
  has an associated @italic{type} and @italic{transformer}. The transformer
  can be any arbitrary function that accepts a syntax object in the same
  manner a transformer given to @racket[define-syntax] would behave.
}

@defproc[(expander-of-type? [type expander-type?] [expander expander?]) boolean?]{
  Returns @racket[#t] if the @racket[expander] has type @racket[type],
  according to the semantics of @racket[expander-type-includes?], and
  returns @racket[#f] otherwise.
  @package-examples[
    (define A (make-expander-type))
    (define exp (expander A (λ (stx) stx)))
    (expander-of-type? A exp)
]}

@defproc[(expand-stx-tree-with-expanders-of-type [type expander-type?] [syntax syntax?]) syntax?]{
  Recursively searches through @racket[syntax] for identifiers bound to
  generic syntax expanders of the given type. When an expander is found,
  its transformer is called with the given syntax value of its location
  in the tree. The returned syntax object with have all expanders of the
  given type fully expanded, but nothing else will be expanded. Due to
  how expanders are bound to identifiers, this procedure can only be
  called in a transformer environment.
}
