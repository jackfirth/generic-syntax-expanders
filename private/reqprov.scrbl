#lang scribble/manual
@(require "doc-util.rkt")

@title{@racket[require] and @racket[provide] transformers}

@defform[#:kind "require transformer"
         (expander-in id)]{
 This @techlink[#:doc '(lib "scribblings/reference/reference.scrbl")]{
  require transformer} imports the identifiers defined by 
 @racket[(define-expander-type id)]:
 @itemlist[@item{@tt{@emph{id}-expander-type}}
           @item{@tt{make-@emph{id}-expander}}
           @item{@tt{@emph{id}-expander?}}
           @item{@tt{define-@emph{id}-expander}}
           @item{@tt{expand-all-@emph{id}-expanders}}]}

@defform[#:kind "provide transformer"
         (expander-out id)]{
 This @techlink[#:doc '(lib "scribblings/reference/reference.scrbl")]{
  provide transformer} exports the identifiers defined by
 @racket[(define-expander-type id)]:
 @itemlist[@item{@tt{@emph{id}-expander-type}}
           @item{@tt{make-@emph{id}-expander}}
           @item{@tt{@emph{id}-expander?}}
           @item{@tt{define-@emph{id}-expander}}
           @item{@tt{expand-all-@emph{id}-expanders}}]}