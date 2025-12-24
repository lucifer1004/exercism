(module
  ;;
  ;; Calculate the square of the sum of the first N natural numbers
  ;;
  ;; @param {i32} max - The upper bound (inclusive) of natural numbers to consider
  ;;
  ;; @returns {i32} The square of the sum of the first N natural numbers
  ;;
  (func $squareOfSum (export "squareOfSum") (param $max i32) (result i32)
    ;; (max * (max + 1) / 2) * (max * (max + 1) / 2)
    (local $sum i32)

    (local.get $max)
    (i32.const 1)
    (i32.add)
    (local.get $max)
    (i32.mul)
    (i32.const 2)
    (i32.div_s)

    (local.tee $sum)
    (local.get $sum)
    (i32.mul)
  )

  ;;
  ;; Calculate the sum of the squares of the first N natural numbers
  ;;
  ;; @param {i32} max - The upper bound (inclusive) of natural numbers to consider
  ;;
  ;; @returns {i32} The sum of the squares of the first N natural numbers
  ;;
  (func $sumOfSquares (export "sumOfSquares") (param $max i32) (result i32)
    ;; (max * (max + 1) * (2 * max + 1)) / 6
    (local.get $max)
    (i32.const 1)
    (i32.add)
    (local.get $max)
    (i32.mul)
    (i32.const 2)
    (local.get $max)
    (i32.mul)
    (i32.const 1)
    (i32.add)
    (i32.mul)
    (i32.const 6)
    (i32.div_s)
  )

  ;;
  ;; Calculate the difference between the square of the sum and the sum of the
  ;; squares of the first N natural numbers.
  ;;
  ;; @param {i32} max - The upper bound (inclusive) of natural numbers to consider
  ;;
  ;; @returns {i32} Difference between the square of the sum and the sum of the
  ;;                squares of the first N natural numbers.
  ;;
  (func (export "difference") (param $max i32) (result i32)
    (local.get $max)
    (call $squareOfSum)
    (local.get $max)
    (call $sumOfSquares)
    (i32.sub)
  )
)
