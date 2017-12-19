-- p62
multThree :: Int -> Int -> Int -> Int
multThree x y z = x * y * z

compareWithHundred :: Int -> Ordering
compareWithHundred = compare 100


-- p64
divideByTen :: (Floating a) => a -> a
divideByTen = (/10)

-- p65
applyTwice :: (a -> a) -> a -> a
applyTwice f x = f (f x)

-- p66
zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = [] -- リスト a が空
zipWith' _ _ [] = [] -- リスト b が空
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys

-- p67
flip' :: (a -> b -> c) -> b -> a -> c
flip' f = \x y -> f y x

-- p68
--map' :: (a -> b) -> [a] -> [b]
--map' _ [] = []
--map' f (x:xs) = f x : map' f xs

-- p69
--filter' :: (a -> Bool) -> [a] -> [a]
--filter' _ [] = []
--filter' p (x:xs)
--  | p x       = x : filter' p xs
--  | otherwise = filter' p xs

-- p70
largestDivisible :: Integer
largestDivisible = head (filter p [100000,99999..])
  where p x = x `mod` 3829 == 0

-- p72
chain :: Integer -> [Integer]
chain 1 = [1]
chain n
  | even n = n : chain (n `div` 2)
  | odd n  = n : chain (n * 3 + 1)

numLongChains :: Int
numLongChains = length (filter (\xs -> length xs > 15) (map chain [1..100]))

-- p74
addThree :: Int -> Int -> Int -> Int
addThree x y z = x + y + z

addThree' :: Int -> Int -> Int -> Int
addThree' = \x -> \y -> \z -> x + y + z

-- p76
--sum' :: (Num a) => [a] -> a
--sum' xs = foldl (\acc x -> acc + x) 0 xs

-- p77
sum' :: (Num a) => [a] -> a
sum' = foldl (+) 0

map' :: (a -> b) -> [a] -> [b]
map' f xs = foldr (\x acc -> f x : acc) [] xs

elem' :: (Eq a) => a -> [a] -> Bool
elem' y ys = foldr (\x acc -> if x == y then True else acc) False ys

-- p78
maximum' :: (Ord a) => [a] -> a
maximum' = foldl1 max

-- p79
reverse' :: [a] -> [a]
reverse' = foldl (flip (:)) []

product' :: (Num a) => [a] -> a
product' = foldl1 (*)

filter' :: (a -> Bool) -> [a] -> [a]
filter' p = foldr (\x acc -> if p x then x : acc else acc) []

last' :: [a] -> a
last' = foldl1 (\_ x -> x)

-- p81
and' :: [Bool] -> Bool
and' xs = foldr (&&) True xs

-- p82
sqrtSums :: Int
sqrtSums = length (takeWhile (<1000) (scanl1 (+) (map sqrt [1..]))) + 1
