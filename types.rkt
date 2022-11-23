#lang racket/base

(require
 racket/contract/base
 racket/contract/region)

(provide (all-defined-out))

(struct/contract ingredient ([quantity exact-nonnegative-integer?] [item string?]) #:transparent)
(struct/contract recipe ([item string?] [ingredients (listof ingredient?)]) #:transparent)
