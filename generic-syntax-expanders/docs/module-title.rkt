#lang racket

(require scribble/manual)

(provide module-title)

(define-syntax-rule (module-title id title-text pre-flow ...)
  (begin
    (title title-text)
    (defmodule id pre-flow ...)))
