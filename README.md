generic-syntax-expanders
========================

A Racket package for creating macros with built-in support for defining sub-macros within them, similar to match expanders

Sometimes complex Racket macros need a way for their syntax to be extended. The Racket match form is an example, new patterns can be created for match using define-match-expander. This racket package provides a form for defining a macro with the ability to define expanders for the macro. Consider this contrived example:

(define-syntax call-each
  (syntax-parser
    [(_ f (expr ...))
    #'(begin (f expr) ...)]))
    
(call-each displayln (1 2 3))

If a user of this macro wished for a way to specify a range of numbers as the arguments, the user must define their own version of call-each with support for ranges that expands to using the original call-each. However, this racket package provides a form, define-syntax-with-expanders:

(define-syntax-with-expanders call-each
  (syntax-parser
    [(_ f (expr ...))
    #'(begin (f expr) ... )]))

(define-call-each-expander foo
  (syntax-parser
    [(_ low:number high:number)
    #`(#,@(range (syntax-e #'low) (syntax-e #'high)))]))
    
(call-each displayln (foo 1 4))

The define-syntax-with-expanders form creates a define-call-each-expander form, which defines syntax transformers that are only used inside the body of a call-each form and expand before call-each does.

You can install this package with `raco package install generic-syntax-expanders`.
