## Writer

Writerモナドはもう1つの値がくっついた値を表し、付加された値はログのように振る舞う。
Writerモナドを使うと、一連の計算を行っている間全てのログが単一のログ値にまとめて記録されることを保証できる。

盗賊団の人数をとり、それが大きな盗賊団であるかを返す関数

```haskell
isBigGang :: Int -> (Bool, String)
isBigGang x = x > 9
```

ただ True or False を返すだけでなく、この関数が何をしたかを示す文字列も一緒に返してほしい場合、

```haskell
isBigGang :: Int -> (Bool, String)
isBigGang x = (x > 9, "Compared gang size to 9.")
```

タプルが返るようになり、値に文脈がついた。

```
*Main> isBigGang 3
(False,"Compared gang size to 9.")
*Main> isBigGang 30
(True,"Compared gang size to 9.")
```

`(3, "Smallish gang.")` を渡したい場合どうすればよいか

```haskell
applyLog :: (a, String) -> (a -> (b, String)) -> (b, String)
applyLog (x, log) f = let (y, newLog) = f x in (y, log ++ newLog)
```

上記のような関数をつくる。`(a, String)`値はログを表す値が付いているという文脈を持つ。

実行

```
*Main> (3, "Smallish gang.") `applyLog` isBigGang
(False,"Smallish gang.Compared gang size to 9.")
*Main> (30, "A freaking platoon..") `applyLog` isBigGang
(True,"A freaking platoon..Compared gang size to 9.")
```

## モノイドの助けを借りる

ログはStringである必要はない

```haskell
applyLog :: (a, [c]) -> (a -> (b, [c])) -> (b, [c])
```

applyLogをByteStringに使えるかどうか。リストしか許容していないので使えない。
そこで、リストもByteStringも Monoid型クラスのインスタンスであることを利用する。

```
*Main B> [1,2,3] `mappend` [4,5,7]
[1,2,3,4,5,7]
*Main B> B.pack [99,104,105] `mappend` B.pack [104,117,97,104,117,97]
"chihuahua"
```

applyLogがMonoidを受けるようにする

```haskell
applyLog :: (Monoid => m)(a, m) -> (a -> (b, m)) -> (b, m)
applyLog (x, log) f = let (y, newLog) = f x in (y, log `mappend` newLog)
```

実行

```
*Main> (3, "Smallish gang.") `applyLog` isBigGang
(False,"Smallish gang.Compared gang size to 9.")
*Main> (30, "A freaking platoon..") `applyLog` isBigGang
(True,"A freaking platoon..Compared gang size to 9.")
```

値とログの組という解釈は必要なくなり、値とモノイド値のおまけとして解釈できるようになった。

商品の名前と価格の組の例

```haskell
import           Data.Monoid

type Food = String
type Price = Sum Int

addDrink :: Food -> (Food, Price)
addDrink "beans" = ("milk", Sum 25)
addDrink "jerky" = ("whiskey", Sum 99)
addDrink _       = ("beer", Sum 30)
```

`Sum`で包まれた値を`mappend`するとこうなる

```
*Main Data.Monoid> Sum 2 `mappend` Sum 5
Sum {getSum = 7}
```

食べ物と値札の組に`applyLog`を使って適用する

```
*Main> ("beans", Sum 10) `applyLog` addDrink
("milk",Sum {getSum = 35})
*Main> ("jerky", Sum 25) `applyLog` addDrink
("whiskey",Sum {getSum = 124})
*Main> ("dogmeat", Sum 5) `applyLog` addDrink
("beer",Sum {getSum = 35})
```

ログだけではなく、数値の合計が計算できている。

連続で注文もできる

```
*Main> ("dogmeat", Sum 5) `applyLog` addDrink `applyLog` addDrink
("beer",Sum {getSum = 65})
```

これはモナドに似ている

## Writer型

型定義

```haskell
newtype Writer w a = Writer { runWriter :: (a, w) }
```

Monad インスタンス

```haskell
instance (Monoid w) => Monad (Writer w) where
  return x = Writer (x, mempty)
  (Writer (x, v)) >>= f = let (Writer (y, v')) = f x
                            in Writer (y, v `mappend` v')
```

## Writerをdo記法で使う

do記法は複数のWriterをまとめて何かしたいときに便利。

```haskell
import           Control.Monad.Writer

logNumber :: Int -> Writer [String] Int
logNumber x = writer (x, ["Got number: " ++ show x])

multWithLog :: Writer [String] Int
multWithLog = do
    a <- logNumber 3
    b <- logNumber 5
    return (a * b)
```

実行

```

```
