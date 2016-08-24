#lang racket

;; This test is simpler than test-define-x-expander-use-site-scope.rkt,
;; but is a bit more artificial. For a more realistic use-case, see the
;; test-define-x-expander-use-site-scope.rkt file.

(require generic-syntax-expanders
         rackunit)

(define-expander-type foo)

(define-syntax (expand-foos stx)
  (syntax-case stx ()
    [(_ body)
     (expand-all-foo-expanders #'body)]))

;; Without PR #8, the `x` in `bb` is not `bound-identifier=?` to the `x`
;; defined by `aa`, despite the use of `syntax-local-introduce` to make the
;; macros unhygienic.
;;
;; This happens because `define-foo-expander` added an extra "use-site" scope
;; to the body of `aa` and a different "use-site" scope to the body of `bb`.
(define-foo-expander aa
  (λ (_)
    (syntax-local-introduce #'[x #t])))

(define-foo-expander bb
  (λ (_)
    (syntax-local-introduce #'x)))

;; Due to the way `let` itself adds scopes to its definition and body, this
;; makes the identifiers `x` from `aa` and `x` from `bb` distinct, and the
;; latter cannot be used to refer to the former.
;;
;; Approximately, the code below expands to
;;
;;     (let [(x⁰¹ #t)]
;;       x⁰²)
;;
;; The `let` form then adds a "local" scope to both occurrences of `x`, and an
;; internal-definition context "intdef" scope to the `x` present in the body of
;; the `let` (but not to the one present in the bindings). The expanded form
;; therefore becomes:
;;
;;     (let [(x⁰¹³ #t)]
;;       x⁰²³⁴)
;;
;; where:
;;   ⁰ are the module's scopes
;;   ¹ is the undesired "use-site" scope added by `define-foo-expander` on `aa`
;;   ² is the undesired "use-site" scope added by `define-foo-expander` on `bb`
;;   ³ is the "local" scope added by `let`
;;   ⁴ is the "intdef" scope added by `let`
;;
;; Since {0,2,3,4} is not a subset of {0,1,3}, the `x` inside the `let` is
;; unbound.
(test-true
 "Test that `x` as produced by `(bb)` is correctly bound by the `x`
 introduced by `(aa)`.

This test fails without the PR #8 patch, because the body of `bb` and the body
 of `aa` each have a different use-site scope, introduced by accident by
 `define-foo-expander`. The occurrence of `x` introduced by `aa` and the
 occurrence of `x` introduced by `bb` therefore have different scopes, and the
 latter is not bound by the former.

Without the PR #8 patch, this test case will not compile, and will fail with
 the error `x: unbound identifier in module`."
 (expand-foos
  (let ((aa))
    (bb))))

;; ----------

;; It is worth noting that `define` seems to strip the "use-site" scopes present
;; on the defined identifier. If the code above is changed so that a `define`
;; form is used, the problem does not occur:
(define-foo-expander aa-def
  (λ (_)
    (syntax-local-introduce #'[define y #t])))

(define-foo-expander bb-def
  (λ (_)
    (syntax-local-introduce #'y)))

;; This is because the code below expands to:
;;
;;     (begin (define y⁰ #t)
;;            (define y-copy y⁰²⁵)
;;
;; where:
;;   ⁰ are the module's scopes
;;   ¹ is the undesired "use-site" scope added by `define-foo-expander` on `aa`
;;     and it is stripped by `define` from the first `y`
;;   ² is the undesired "use-site" scope added by `define-foo-expander` on `bb`
;;   ⁵ is the "use-site" scope added because it is in an expression position
;;
;; Since {0,2,5} is a subset of {0}, the second `y` refers to the first `y`.
(expand-foos
 (begin (aa-def)
        (define y-copy (bb-def))))
(test-true
 "Test that `y` as produced by `(bb-def)` is correctly bound by the `y`
 defined by `(aa-def)`.

This test succeeds without the PR #8 patch, which shows that `define` removes
 all use-site scopes on the defined identifier (or at least it removes all the
 use-site scopes present in this example). This can be checked in the macro
 debugger, and explains why the test case did not fail with a simple `define`,
 but does fail with a binding introduced by a `let`."
 y-copy)

;; ----------

;; The code below attempts to remove the extra "use-site" scope with
;; `syntax-local-identifier-as-binding`. However, that function does
;; not remove all use-site scopes, unlike the `define` above.

(define-foo-expander aa-as-binding
  (λ (_)
    #`[#,(syntax-local-identifier-as-binding (syntax-local-introduce #'z)) #t]))

(define-foo-expander bb-as-binding
  (λ (_)
    (syntax-local-introduce #'z)))

(test-true
 "Test that `z` as produced by `(bb-as-binding)` is correctly bound by
 the `z` defined by `(aa-as-binding)`.

This test fails without the PR #8 patch, which shows that that unlike `define`,
 the `syntax-local-identifier-as-binding` function does not remove all use-site
 scopes.

Without the PR #8 patch, this test case will not compile, and will fail with
 the error `z: unbound identifier in module`."
 (expand-foos
  (let ((aa-as-binding))
    (bb-as-binding))))

;; ----------

;; The `cc` expander acts either as aa or as bb depending on the keyword passed
;; to it. Without PR #8, the code below still compiles fine.
;;
;;
;; The fact that it worked without the patch testifies that the extra scope
;;   was added on the definition of `aa` and `bb`, instead of being a new fresh
;;   scope added each time the expander is called. Here, we have two calls to
;;   the `cc` expander successfully communicating via the `w` variable, thanks
;;   to `syntax-local-introduce` (which makes the macros unhygienic).
(define-foo-expander cc
  (λ (stx)
    (syntax-case stx ()
      [(_ #:aa)
       (begin
         (syntax-local-introduce #'[w #t]))]
      [(_ #:bb)
       (begin
         (syntax-local-introduce #'w))])))

(test-true
 "Test that `w` as produced by `(cc #:bb)` is correctly bound by the `w`
 introduced by `(cc #:aa)`.

This test succeeds without the PR #8 patch, which shows that the extra
 scopes are per-expander and not per-invocation. Expanders can still be
 unhygienic using `syntax-local-introduce`, but can communicate only with
 themselves."
 (expand-foos
  (let ((cc #:aa))
    (cc #:bb))))