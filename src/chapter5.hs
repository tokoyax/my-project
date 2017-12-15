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
flip' f y x = f x y

-- p68
map' :: (a -> b) -> [a] -> [b]
map' _ [] = []
map' f (x:xs) = f x : map' f xs

-- p69
filter' :: (a -> Bool) -> [a] -> [a]
filter' _ [] = []
filter' p (x:xs)
  | p x       = x : filter' p xs
  | otherwise = filter' p xs


