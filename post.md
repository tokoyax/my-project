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

### filterM

filter関数は、Haskellプログラミングの米らしい。
map は塩らしい。

filterは述語とフィルタ対象のリストを取り、述語を満たす要素だけを残してくれる。

```haskell
filter :: (a -> Bool) -> [a] -> [a]
```

文脈を持った値を filterしたい場合、filterMを使う。Control.Monad モジュールに定義されている。

```haskell
filterM :: (Monad m) => (a -> m Bool) -> [a] -> m [a]
```

リストを取って、4より小さい要素だけを残す関数。

```
*Main> filter (\x -> x < 4) [9,1,5,2,10,3]
[1,2,3]
```

True か False だけを返すのではなく、何をしたかのログを残すような述語を作る。

```haskell
import           Control.Monad.Writer.Lazy

keepSmall :: Int -> Writer [String] Bool
keepSmall x
    | x < 4 = do
        tell ["Keeping " ++ show x]
        return True
    | otherwise = do
        tell [show x ++ " is too large, throwning it away"]
        return False
```

実行

```
*Main> fst $ runWriter $ filterM keepSmall [9,1,5,2,10,3]
[1,2,3]
```

ログを表示してみる

```
*Main> mapM_ putStrLn $ snd $ runWriter $ filterM keepSmall [9,1,5,2,10,3]
9 is too large, throwning it away
Keeping 1
5 is too large, throwning it away
Keeping 2
10 is too large, throwning it away
Keeping 3
```

filterM を使って冪集合を作る

```haskell
powerset :: [a] -> [a]
powerset xs = filterM (\x -> [True, False]) xs
```

実行

```
*Main> powerset [1,2,3]
[[1,2,3],[1,2],[1,3],[1],[2,3],[2],[3],[]]
```

### foldM

foldl のモナド版が foldM

foldl の型

```haskell
foldl :: (a -> b -> a) -> a -> [b] -> a
```

foldM の型

```haskell
foldM :: (Monad m) => (a -> b -> m a) -> a -> [b] -> m a
```

foldl 使ってみる

```
*Main> foldl (\acc x -> acc + x) 0 [2,8,3,1]
14
```

整数のリストを加算したいが、リストのいずれかの要素が9より大きい場合、
計算全体を失敗させたい。Maybeアキュムレータを返すようにする。

```haskell
import           Control.Monad

binSmalls :: Int -> Int -> Maybe Int
binSmalls acc x
    | x > 9 = Nothing
    | otherwise = Just (acc + x)
```

実行

```
*Main> foldM binSmalls 0 [2,8,3,1]
Just 14
*Main> foldM binSmalls 0 [2,11,3,1]
Nothing
```

リストに9より大きい数が入っている場合、Nothingになっている。

## 所感

モナディック関数というかっこいい名前の関数を知った。


