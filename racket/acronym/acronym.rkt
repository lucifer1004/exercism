#lang racket

(provide acronym)

(define (acronym-helper acc string first)
  (cond
    [(zero? (string-length string)) (list->string (reverse acc))]
    [else
     (let ([char (string-ref string 0)])
       (cond
         [(or (char-whitespace? char) (char=? char #\-))
          (acronym-helper acc (substring string 1) true)]
         [(and (char-alphabetic? char) first)
          (acronym-helper (cons (char-upcase char) acc) (substring string 1) false)]
         [else (acronym-helper acc (substring string 1) first)]))]))

(define (acronym string)
  (acronym-helper '() string true))
