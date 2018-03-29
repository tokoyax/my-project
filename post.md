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


