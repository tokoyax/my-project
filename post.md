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
`>>=` は
