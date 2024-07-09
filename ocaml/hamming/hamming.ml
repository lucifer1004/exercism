type nucleotide = A | C | G | T

let hamming_distance left right =
  if List.length left == 0 && List.length right == 0 then
    Ok 0
  else if List.length left == 0 then
    Error "left strand must not be empty"
  else if List.length right == 0 then
    Error "right strand must not be empty"
  else if List.length left != List.length right then
    Error "left and right strands must be of equal length"
  else
    let rec loop l r acc = match l, r with
      | [], [] -> Ok acc
      | lh :: lt, rh :: rt -> loop lt rt (if lh == rh then acc else acc + 1)
      | _ -> failwith "impossible"
    in
    loop left right 0
