## 便利なモナディック関数

モナドを扱う関数はモナディック関数と呼ばれる。

### liftM

関数とモナド値をとって、関数でモナド値を写してくれる。
fmapっぽい。

```haskell
liftM :: Monad m => (a1 -> r) -> m a1 -> m r
```

fmap の型

```haskell
fmap :: Functor f => (a -> b) -> f a -> f b
```

ファンクター則とモナド則を満たしている場合、fmap と liftM はまったく同じものになる。

liftM を試す

```
*Main> liftM (*3) (Just 8)
Just 24
*Main> fmap (*3) (Just 8)
Just 24
*Main> runWriter $ liftM not $ writer (True, "chickpeas")
(False,"chickpeas")
*Main> runWriter $ fmap not $ writer (True, "chickpeas")
(False,"chickpeas")
*Main> runState (liftM (+100) pop) [1,2,3,4]
(101,[2,3,4])
*Main> runState (fmap (+100) pop) [1,2,3,4]
(101,[2,3,4])
```

fmap と liftM は同じ動きしてる。

次はアプリカティブ値

```
*Main> (+) <$> Just 3 <*> Just 5
Just 8
*Main> (+) <$> Just 3 <*> Nothing
Nothing
```

`<$>`はただのfmap。`<*>`はこう

```
(<*>) :: (Applicative f) => f (a -> b) -> f a -> f b
```

fmap に似ているが、関数自身も文脈の中に入っている。

ap という関数があり、本質的には`<*>`と同じだが、Applicativeの代わりにMonad型クラス制約がついている。

```haskell
ap :: (Monad m) => m (a -> b) -> m a -> m b
ap mf m = do
    f <- mf
    x <- m
    return (f x)
```

mf は結果が関数であるようなモナド値。

使ってみる

```
*Main> Just (+3) <*> Just 4
Just 7
*Main> Just (+3) `ap` Just 4
Just 7
*Main> [(+1),(+2),(+3)] <*> [10,11]
[11,12,12,13,13,14]
*Main> [(+1),(+2),(+3)] `ap` [10,11]
[11,12,12,13,13,14]
```

モナドの威力は少なくともアプリカティブやファンクター以上である。
すべてのモナドはファンクターでもアプリカティブでもあるのにそのインスタンスになっているとは限らない。
また、ファンクターやアプリカティブファンクターが使う関数と等価なモナド版の関数が存在する。

### join

任意の入れ子になったモナドは平らにできる。
このために join がある。

```haskell
join :: (Monad m) => m (m a) -> m a
```

使ってみる

```
*Main> join (Just (Just 9))
Just 9
*Main> join (Just Nothing)
Nothing
*Main> join Nothing
Nothing
*Main> join [[1,2,3],[4,5,6]]
[1,2,3,4,5,6]
*Main> runWriter $ join (writer (writer (1, "aaa"), "bbb"))
(1,"bbbaaa")
*Main> join (Right (Right 9))
Right 9
*Main> join (Right (Left "error"))
Left "error"
*Main> join (Left "error")
Left "error"
*Main> runState (join (state $ \s -> (push 10, 1:2:s))) [0,0,0]
((),[10,1,2,0,0,0])
```


