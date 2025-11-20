module Knapsack (maximumValue) where

import Data.Array (listArray, (!), (//))

maximumValue :: Int -> [(Int, Int)] -> Int
maximumValue capacity items = dp ! capacity
  where
    dp = foldl updateDP initialDP items
    initialDP = listArray (0, capacity) (repeat 0)

    updateDP arr (weight, value) = arr // updates
      where
        updates =
          [ (w, max (arr ! w) (value + arr ! (w - weight)))
          | w <- [capacity, capacity - 1 .. weight]
          ]
