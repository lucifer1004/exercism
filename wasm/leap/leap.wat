(module
  ;;
  ;; Determine if a year is a leap year
  ;;
  ;; @param {i32} year - The year to check
  ;;
  ;; @returns {i32} 1 if leap year, 0 otherwise
  ;;
  ;; Logic: divisible by 400 OR (divisible by 4 AND NOT divisible by 100)
  ;;
  (func (export "isLeap") (param $year i32) (result i32)
    ;; Check if divisible by 400
    (if (result i32)
      (i32.eq
        (i32.rem_u (local.get $year) (i32.const 400))
        (i32.const 0)
      )
      (then
        (i32.const 1)  ;; divisible by 400 → leap year
      )
      (else
        ;; Check if divisible by 100
        (if (result i32)
          (i32.eq
            (i32.rem_u (local.get $year) (i32.const 100))
            (i32.const 0)
          )
          (then
            (i32.const 0)  ;; divisible by 100 but not 400 → not leap year
          )
          (else
            ;; Check if divisible by 4
            (if (result i32)
              (i32.eq
                (i32.rem_u (local.get $year) (i32.const 4))
                (i32.const 0)
              )
              (then
                (i32.const 1)  ;; divisible by 4 but not 100 → leap year
              )
              (else
                (i32.const 0)  ;; not divisible by 4 → not leap year
              )
            )
          )
        )
      )
    )
  )
)
