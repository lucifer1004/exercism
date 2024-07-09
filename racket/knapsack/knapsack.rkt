#lang racket

(provide item
         maximum-value)

(struct item (weight value) #:transparent)

(define (maximum-value maximum-weight items)
  (let ([dp (make-vector (+ maximum-weight 1) 0)])
    (for ([item items])
      (for ([w (in-range maximum-weight (sub1 (item-weight item)) -1)])
        (vector-set! dp
                     w
                     (max (vector-ref dp w)
                          (+ (item-value item) (vector-ref dp (- w (item-weight item))))))))
    (vector-ref dp maximum-weight)))
