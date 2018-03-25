## 騎士の旅

チェス盤の上にナイトの駒が1つだけ乗っており、ナイトを3回動かして特定のマスまで移動させられるかという問題を解く。

```haskell
type KnightPos = (Int, Int)

moveKnight :: KnightPos -> [KnightPos]
moveKnight (c,r) = do
    (c', r') <- [(c+2,r-1),(c+2,r+1),(c-2,r-1),(c-2,r+1)
                ,(c+1,r-2),(c+1,r+2),(c-1,r-2),(c-1,r+2)
                ]
    guard (c' `elem` [1..8] && r' `elem` [1..8])
    return (c', r')
```

ナイトの位置を表す型と、ナイトの現在位置をとって移動可能な位置を全て返す関数。


