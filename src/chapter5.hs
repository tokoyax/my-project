-- p62
multThree :: Int -> Int -> Int -> Int
multThree x y z = x * y * z

compareWithHundred :: Int -> Ordering
compareWithHundred = compare 100


-- p64
divideByTen :: (Floating a) => a -> a
divideByTen = (/10)
