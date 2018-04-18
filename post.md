## 計算の状態

状態を扱うためにHaskellにはStateモナドが用意されている。

## 状態付きの計算

状態付きの計算とは、ある状態を取って、更新された状態と一緒に計算結果を返す関数として表現できる。

```haskell
s -> (a, s)
```

s は状態の型で、 a は状態付き計算の結果。
このような状態付きの計算も、文脈付きの値だとみなすことができる。
計算の結果が「生の値」 であり、その計算結果を得るためには初期状態を与える必要があること、
そして、計算の結果を得るのと同時に新しい状態が得られるというのが文脈にあたる。

## スタックと石

stackデータ構造をモデル化する。

* Push : スタックのてっぺんに要素を積む
* Pop : スタックのてっぺんの要素を取り除く

```haskell
type Stack = [Int]

pop :: Stack -> (Int, Stack)
pop (x:xs) = (x, xs)

push :: Int -> Stack -> ((), Stack)
push a xs = ((), a:xs)
```

スタックをシミュレートするコードを書く

```haskell
stackManip :: Stack -> (Int, Stack)
stackManip stack = let
    ((), newStack1) = push 3 stack
    (a, newStack2) = pop newStack1
    in pop newStack2
```

実行

```
*Main> stackManip [5,8,2,1]
(5,[8,2,1])
```

ところが、Stateモナドを使うと次のように書けちゃう

```haskell
stackManip = do
    push 3
    a <- pop
    pop
```

## Stateモナド

`Control.Monad.State`モジュールは、状態付き計算を包んだ newtype を提供している。

```haskell
newtype State s a = State { runState :: s -> (a, s) }
```

`State s a` は s 型の状態を操り、a 型の結果を返す状態付き計算。

状態付き計算のMonadインスタンス

```haskell
instance Monad (State s) where
    return x = State $ \x -> (x, s)
    (State h) >>= f = State $ \s -> let (a, newState) = h s
                                        (State, g) = f a
                                    in g newState
```

return は値を取って常にその値を結果として返すような状態付き計算。
`>>=` は2つの状態付き計算を繋げられる。

先程の処理をStateモナド使って書き換える

```haskell
import Control.Monad.State

pop :: State Stack Int
pop = state $ \(x:xs) -> (x, xs)

push :: Int -> State Stack ()
push a = state $ \xs -> ((), a:xs)

stackManip :: State Stack Int
stackManip = do
    push 3
    a <- pop
    pop
```

実行

```
*Main> runState stackManip [5,8,2,1]
(5,[8,2,1])
```

pop の結果 a は一度も使っていないのでこう書ける

```haskell
stackManip :: State Stack Int
stackManip = do
    push 3
    pop
    pop
```

もう少し複雑なスタックの処理を書く。
スタック1つの数を取り出して、5だったら元に戻す。
5ではなかった場合、3と8を積む。

```haskell
stackStuff :: State Stack ()
stackStuff = do
    a <- pop
    if a == 5
        then push 5
        else do
            push 3
            push 8
```

実行

```
*Main> runState stackStuff [9,0,1,2,0]
((),[8,3,0,1,2,0])
```

stackManip と stackStuff はどちらも状態付き計算なのでこの2つをつなげることができる。

```haskell
moreStack :: State Stack ()
moreStack = do
    a <- stackManip
    if a == 100
        then stackStuff
        else return ()
```

実行

```
*Main> runState moreStack [100,9,3,6,22,1,0]
((),[8,3,3,6,22,1,0])
```

## 状態の取得と設定

Stateモナドを扱うための便利な型クラスMonadStateがある。
get と put という関数が使える。

get の実装

```haskell
get = state $ \s -> (s, s)
```

put の実装

```haskell
put newState = state $ \s -> ((), newState)
```

put と get を使う

```haskell
stackeyStack :: State Stack ()
stackeyStack = do
    stackNow <- get
    if stackNow == [1,2,3]
        then put [8,3,1]
        else put [9,2,1]
```

get と put を使って pop と push を書き換える

```haskell
pop :: State Stack Int
pop = do
    (x:xs) <- get
    put xs
    return x

push :: Int -> State Stack ()
push x = do
    xs <- get
    put (x:xs)
```

## 乱数とStateモナド

Stateモナド使って乱数を扱う処理を書く

```haskell
import System.Random
import Control.Monad.State

randomSt :: (RandomGen g, Random a) => State g a
randomSt = state random
```

乱数ジェネレーターは状態付き計算であるので、state関数を使ってStateのnewtypeに包めば、
状態の扱いをモナドに任せることができる。

コインを3枚投げる処理はこう書けるようになる。

```haskell
threeCoins :: State StdGen (Bool, Bool, Bool)
threeCoins = do
    a <- randomSt
    b <- randomSt
    c <- randomSt
    return (a, b, c)
```

実行

```
*Main> runState threeCoins (mkStdGen 33)
((True,False,True),680029187 2103410263)
```

## 所感

だいたいわからん。複雑なモナドになるとコードが何してるかわからなくなる。
とりあえず前に進むこととする。


