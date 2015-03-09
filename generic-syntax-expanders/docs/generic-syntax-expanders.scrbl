#lang scribble/manual

@(require "example-evaluator.rkt"
          "defpredicate.rkt"
          "module-title.rkt"
          "source-code.rkt"
          (for-label racket/base
                     racket/match
                     generic-syntax-expanders))

@module-title[generic-syntax-expanders]{Generic Syntax Expanders}
@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

This library provides forms to define @italic{generic syntax
expanders}. These are essentially macros that have no meaning
on their own, but other macros can be told to expand all
generic syntax expanders of some type in some portion of
their body before themselves expanding. This is similar to
how Racket's built in @racket[match] form has @italic{match
expanders}, which allows the grammar of the @racket[match]
form to be extended with custom match expanders using
@racket[define-match-expander]. This library generalizes
the concept, making complex macros more composable and
extensible.

@source-code{https://github.com/jackfirth/generic-syntax-expanders}

@include-section{expanders.scrbl}
@include-section{expander-types.scrbl}
@include-section{define-expanders.scrbl}
@include-section{scoped-transformers.scrbl}
@include-section{define-scoped-transformers.scrbl}
