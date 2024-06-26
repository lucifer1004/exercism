(module
  ;;
  ;; Score a dart throw based on its coordinates.
  ;;
  ;; @param {f32} x - The x coordinate of the dart.
  ;; @param {f32} y - The y coordinate of the dart.
  ;;
  ;; @returns {i32} - The score of the dart throw (10, 5, 1, or 0).
  ;;
  (func (export "score") (param $x f32) (param $y f32) (result i32)
    (local $r f32)
    (local $score i32)
    (local $distance f32)

    ;; Calculate the distance from the origin.
    (local.get $x)
    (local.get $x)
    (f32.mul)
    (local.get $y)
    (local.get $y)
    (f32.mul)
    (f32.add)
    (f32.sqrt)

    (local.set $distance)
    (i32.const 0)
    (local.set $score)

    ;; Determine the score based on the distance.
    (local.get $distance)
    (f32.const 1.0)
    (f32.le)
    (if
      (then 
        i32.const 10
        local.set $score  
      )
      (else
        (local.get $distance)
        (f32.const 5.0)
        (f32.le)
        (if
          (then 
            i32.const 5
            local.set $score  
          )
          (else
            (local.get $distance)
            (f32.const 10.0)
            (f32.le)
            (if
              (then 
                i32.const 1
                local.set $score  
              )
            )
          )
        )
      )
    )
  
    (local.get $score)
  )
)
