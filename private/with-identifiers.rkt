#lang racket

(require syntax/parse/define
         racket/syntax)

(provide with-formatted-ids
         with-derived-ids)

(define-simple-macro (with-formatted-ids ([pat-id:id format base-id-stx] ...) stx-expr)
  (with-syntax ([pat-id
                 (format-id base-id-stx
                            format
                            base-id-stx)] ...)
    stx-expr))

(define-simple-macro (with-derived-ids base-id-stx ([pat-id:id format] ...) stx-expr)
  (with-formatted-ids ([pat-id format base-id-stx] ...) stx-expr))
