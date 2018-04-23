#`# 安全な逆ポーランド記法電卓をつくる

前に作ったRPN電卓にエラー機能をつける。

```haskell
import           Control.Monad

solveRPN :: String -> Maybe Double
solveRPN st = do
    [result] <- foldM foldingFunction [] $ words st
    return result

foldingFunction :: [Double] -> String -> Maybe [Double]
foldingFunction (x:y:ys) "*"    = return ((y * x):ys)
foldingFunction (x:y:ys) "+"    = return ((y + x):ys)
foldingFunction (x:y:ys) "-"    = return ((y - x):ys)
foldingFunction xs numberString = liftM (:xs) (readMaybe numberString)

readMaybe :: (Read a) => String -> Maybe a
readMaybe st = case reads st of [(x, "")] -> Just x
                                _         -> Nothing
```

実行

```
*Main> solveRPN "1 2 * 4 +"
Just 6.0
*Main> solveRPN "1 2 * 4 + 5 *"
Just 30.0
*Main> solveRPN "1 2 * 4"
Nothing
*Main> solveRPN "1 8 werasdfasdefih"
Nothing
```

## モナディック関数の合成

第13章で `<=<` は関数合成によく似ているけど普通の関数 `a -> b` ではなく、
`a -> m b` のようなモナディック関数に作用するということが書かれていた。

```
*Main> let f = (+1) . (*100)
*Main> f 4
401
*Main> let g = (\x -> return (x+1)) <=< (\x -> return (x*100))
*Main> Just 4 >>= g
Just 401
```

複数の関数をリストに持っているとき、
全部合成して1つの関数を作る場合は id をアキュムレータ、`.` を2引数関数として畳み込むとよい。

```
*Main> let f = foldr (.) id [(+8),(*100),(+1)]
*Main> f 1
208
```

モナディック関数も同じように合成できる。
`.` の代わりに `<=<`、`id` の代わりに `return` を使うとよい。

前にチェスのナイトを3手以内で移動できるかどうか判定するプログラムを改良する。

```haskell
import           Control.Monad

type KnightPos = (Int, Int)

moveKnight :: KnightPos -> [KnightPos]
moveKnight (c,r) = do
    (c', r') <- [(c+2,r-1),(c+2,r+1),(c-2,r-1),(c-2,r+1)
                ,(c+1,r-2),(c+1,r+2),(c-1,r-2),(c-1,r+2)
                ]
    guard (c' `elem` [1..8] && r' `elem` [1..8])
    return (c', r')

in3 :: KnightPos -> [KnightPos]
in3 start = do
    first <- moveKnight start
    second <- moveKnight first
    moveKnight second

canReachIn3 :: KnightPos -> KnightPos -> Bool
canReachIn3 start end = end `elem` in3 start
```

モナディックに合成して、より一般化する

```haskell
import           Control.Monad
import           Data.List

type KnightPos = (Int, Int)

moveKnight :: KnightPos -> [KnightPos]
moveKnight (c,r) = do
    (c', r') <- [(c+2,r-1),(c+2,r+1),(c-2,r-1),(c-2,r+1)
                ,(c+1,r-2),(c+1,r+2),(c-1,r-2),(c-1,r+2)
                ]
    guard (c' `elem` [1..8] && r' `elem` [1..8])
    return (c', r')

inMany :: Int -> KnightPos -> [KnightPos]
inMany x start = return start >>= foldr (<=<) return (replicate x moveKnight)

canReachIn :: Int -> KnightPos -> KnightPos -> Bool
canReachIn x start end = end `elem` inMany x start

```

実行

```
*Main> canReachIn 5 (0,0) (8,3)
True
```

## 所感

文脈もたせたまま処理できる術がちゃんと用意されている。使えるようになるまでは時間かかりそうである。
