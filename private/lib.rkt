#lang racket/base
(require racket/match)

(provide (all-defined-out))

(define (string-capitalize s)
  (match s
    [(regexp #px"(\\s*)(.)(.*)" (list _ before target after))
     (string-append before (string-upcase target) after)]
    [other other]))

(module+ test
  (require rackunit)
  (test-equal? "handles empty string" (string-capitalize "") "")
  (test-equal? "Capitalizes the first word" (string-capitalize "hello world") "Hello world")
  (test-equal? "S gotcha" (string-capitalize "silicone rubber") "Silicone rubber")
  (test-equal? "S gotcha 2" (string-capitalize "Silicone rubber") "Silicone rubber")
  (test-equal? "Handles whitespace prior" (string-capitalize "   white space!") "   White space!")
  (test-equal? "Leaves numeric prefix alone" (string-capitalize "2 potatoes") "2 potatoes"))
