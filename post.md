## モナドを作る

モナドは作りたいと思って作るものではない。
ある問題の側面をモデル化した型を作り、
後からその型が文脈付きの値を表現していてモナドのように振る舞うとわかった場合に、
Monadインスタンスを与える場合が多い。

リスト [3,5,9] を、整数3, 5, 9が同時に存在している状態だとすると、
それぞれの数の存在確率の情報が足りないと気づく。

確率も含めて表現するとこう、

```
[(3,0.5),(5,0.25),(9,0.25)]
```

数学では確率は0から1までの実数で表現する。
確率を浮動小数で表現した場合、すぐに精度が落ちて困る。
そのため、Haskellには分数のためのデータ型がある。
Rationalと呼ばれる、Data.Ratioモジュールにある。
分子と分母は`%`記号で区切る。

```
*Main Data.Ratio> 1%4
1 % 4
*Main Data.Ratio> 1%2 + 1%2
1 % 1
*Main Data.Ratio> 1%3 + 5%4
19 % 12
```

確率をRationalで表す。

```
*Main Data.Ratio> [(3,1%2),(5,1%4),(9,1%4)]
[(3,1 % 2),(5,1 % 4),(9,1 % 4)]
```

これを newtype で新しい型に包む

```haskell
import Data.Ratio

newtype Prob a = Prob { getProb :: [(a, Rational)] } deriving Show
```

リストはファンクターであるので、Probもファンクターになれる。

```haskell
instance Functor Prob where
    fmap f (Prob xs) = Prob $ map (\(x, p) -> (f x, p)) xs
```

動作させてみる

```
*Main Data.Ratio> fmap negate (Prob [(-3,1 % 2),(-5,1 % 4),(-9,1 % 4)])
Prob {getProb = [(3,1 % 2),(5,1 % 4),(9,1 % 4)]}
```

確率の総和は常に1である。

これはモナドかどうか考える。
まず、return について。リストのreturnは値を取って単一要素のリストに入れる関数。
Probの場合も、単一要素を作るっぽい。確率は、1。
`>>=`は、`m >>= f` と `join (fmap f m)` が等価であることを使って確率リストを平らにすることを考える。

'a','b'が起こる確率が25%,'c','d'が起こる確率が75%とした場合の状況を確率リストで表す。

```haskell
thisSituation :: Prob (Prob Char)
thisSituation = Prob
    [(Prob [('a',1%2),('b', 1%2)], 1%4)
    ,(Prob [('c',1%2),('d', 1%2)], 3%4)
    ]
```

型が `Prob (Prob Char)`と入れ子になっている。これを平らにする。

```haskell
flatten :: Prob (Prob a) -> Prob a
flatten (Prob xs) = Prob $ concat $ map multAll xs
    where multAll (Prob innerxs, p) = map (\(x, r) -> (x, p*r)) innerxs
```

関数 multAll は、確率リストとある確率pのタプルをとって、
リストの中の確率をp倍して、事象と確率の組のリストを返す関数。

flatten は、multAll を入れ子確率リストの各要素を適用してまわり、
得られた入れ子リストを最後にリストとして平らにする。

Monadインスタンスを書く。(Applicativeも書かないとGHCがエラー出す)

参考 : https://qiita.com/Aruneko/items/e72f7c6ee49159751cba

```haskell
instance Applicative Prob where
    pure x = Prob [(x,1%1)]

instance Monad Prob where
    return x = Prob [(x,1%1)]
    m >>= f = flatten (fmap f m)
    fail _ = Prob []
```

モナドインスタンスが手に入ったので、
確率計算をするプログラムを書く。
普通のコインが2枚と、10回投げると9回裏がでるよう細工されたコイン1枚を全部同時に投げて、
全部裏が出る確率をもとめる。

```haskell
data Coin = Heads | Tails deriving (Show, Eq)

coin :: Prob Coin
coin = Prob [(Heads,1%2),(Tails,1%2)]

loadedCoin :: Prob Coin
loadedCoin = Prob [(Heads,1%10),(Tails,9%10)]

flipThree :: Prob Bool
flipThree = do
    a <- coin
    b <- coin
    c <- loadedCoin
    return (all (==Tails) [a,b,c])
```

実行

```
*Main Data.Ratio> getProb flipThree
[(False,1 % 40),(False,9 % 40),(False,1 % 40),(False,9 % 40),(False,1 % 40),(False,9 % 40),(False,1 % 40),(True,9 % 40)]
```

3枚とも裏が出る確率は、9/40になる。

## 所感

自分で書ける気がしない。


