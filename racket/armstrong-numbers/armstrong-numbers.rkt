#lang racket

(provide armstrong-number?)

(define (armstrong-number? n)
  (armstrong-number-helper n n 0 (string-length (number->string n))))

(define (armstrong-number-helper n rem sum order)
  (cond
    [(= rem 0) (= n sum)]
    [else
     (let ([digit (remainder rem 10)])
       (armstrong-number-helper n (quotient rem 10) (+ sum (expt digit order)) order))]))
