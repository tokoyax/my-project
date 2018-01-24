fizzbuzz :: Int -> [String]
fizzbuzz 0 = []
fizzbuzz x
  | x `mod` 15 == 0 = fizzbuzz (x-1) ++ ["FizzBuzz"]
  | x `mod` 3 == 0 = fizzbuzz (x-1) ++ ["Fizz"]
  | x `mod` 5 == 0 = fizzbuzz (x-1) ++ ["Buzz"]
  | otherwise = fizzbuzz (x-1) ++ [show x]
