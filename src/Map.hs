data MyMap k v = MyMap k v deriving (Show)

class MyFunctor f where
        fmap' :: (a -> b) -> f a -> f b

instance MyFunctor (MyMap k) where
        fmap' f (MyMap k v) = MyMap k (f v)
