#lang scribble/manual

@(require scribble/eval
          (for-label package-name
                     racket/base))

@title{package-name}

@(define the-eval (make-base-eval))
@(the-eval '(require "main.rkt"))

@defmodule[package-name]

@author[@author+email["Jack Firth" "jackhfirth@gmail.com"]]

source code: @url["https://github.com/jackfirth/package-name"]