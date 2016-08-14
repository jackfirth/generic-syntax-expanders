#lang scribble/manual
@(require "doc-util.rkt")

@title{Defining Generic Syntax Expanders}

This module provides a high-level API for creating generic
expanders for use with other macros.

@defform[(define-expander-type id)]{
 Creates an expander type and binds several derived values
 for working with the expander type:
 @itemlist[
 @item{@code{id-expander-type} - a new unique @racket[expander-type?]
   bound at phase level 1}
 @item{@code{make-id-expander} - a procedure bound at phase level 1
   that accepts a transformer procedure and returns an @racket[expander?]
   with @code{id-expander-type}}
 @item{@code{id-expander?} - a predicate bound at phase level 1
   recognizing expanders produced by @code{make-id-expander}}
 @item{@code{define-id-expander} - a syntactic form at phase level
   0 that takes an identifier and a transformer procedure and binds the
   identifier as a @code{id-expander?} for use in a transformer
   environment}
 @item{@code{expand-all-id-expanders} - a procedure bound at phase
   @; TODO: expand-all-expanders-of-type is not documented
   level 1 that's equivalent to @racket[expand-all-expanders-of-type] with
   the @code{id-expander-type} as the type argument}
 ]}
