## プログラムにログを追加する

ユークリッド互除法。2つの数を取り、最大公約数を求めるアルゴリズム。

`gcd`関数を自前で作る

```haskell
gcd' :: Int -> Int -> Int
gcd' a b
    | b == 0    = a
    | otherwise = gcd' b (a `mod` b)
```

実行

```
*Main> gcd' 8 3
1
```

8 と 3 の最大公約数は 1 なので正解

ログの機能をつける

```haskell
gcd' :: Int -> Int -> Writer [String] Int
gcd' a b
    | b == 0    = do
        tell ["Finished with " ++ show a]
    | otherwise = do
        tell [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)]
        gcd' b (a `mod` b)
```

実行

```
*Main> fst $ runWriter (gcd' 8 3)
1
*Main> mapM_ putStrLn $ snd $ runWriter (gcd' 8 3)
8 mod 3 = 2
3 mod 2 = 1
2 mod 1 = 0
Finished with 1
```

## 非効率なリスト構築

リストは`mappend`の実装に `++` を使っているが、
これを使ってリストの最後にものを追加する操作はリストが長いと遅くなる。

```haskell
gcdReverse :: Int -> Int -> Writer [String] Int
gcdReverse a b
    | b == 0 = do
        tell ["Finished with " ++ show a]
        return a
    | otherwise = do
        result <- gcdReverse b (a `mod` b)
        tell [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)]
        return result
```

実行

```
*Main> mapM_ putStrLn $ snd $ runWriter (gcdReverse 8 3)
Finished with 1
2 mod 1 = 0
3 mod 2 = 1
8 mod 3 = 2
```

この関数は`++`を右結合でなく左結合で使ってしまうので非効率。
そこで、常に効率的な結合をサポートするデータ構造を使うのが一番よい。

## 差分リストを使う

差分リストとは実際にはリストを取って、別のリストを先頭に付け加える関数である。

`[1,2,3]` と `\xs -> [1,2,3] ++ xs` は等しい。

2つの差分リストを結合する操作

```
f `append` g = \xs -> f (g xs)
```

`f,g`はリストを取ってその前に何かをつける関数。
`f`が`("dog"++)`で`g`が`("meat"++)`という関数なら、次の関数と等価になる

```
\xs -> "dog" ++ ("meat" ++ xs)
```

引数に2つ目の差分リスト、そして1つ目の差分リストを適用する関数になる。
差分リストの`newtype`ラッパーを作る。

```haskell
newtype DiffList a = DiffList { getDiffList :: [a] -> [a] }
```

普通のリストと差分リストの相互変換

```haskell
toDiffList :: [a] -> DiffList a
toDiffList xs = DiffList (xs++)

fromDiffList :: DiffList a -> [a]
fromDiffList (DiffList f) = f []
```

差分リストのMonoidインスタンス

```haskell
instance Monoid (DiffList a) where
    mempty = DiffList (\xs -> [] ++ xs)
    (DiffList f) `mappend` (DiffList g) = DiffList (\xs -> f (g xs))
```

mempty は id 関数であり、mappend は関数合成になっている。

実行

```
*Main> fromDiffList (toDiffList [1,2,3,4] `mappend` toDiffList [1,2,3])
[1,2,3,4,1,2,3]
```

これを使って、`gcdReverse` の効率を上げる

```haskell
gcdReverse :: Int -> Int -> Writer (DiffList String) Int
gcdReverse a b
    | b == 0 = do
        tell (toDiffList ["Finished with " ++ show a])
        return a
    | otherwise = do
        result <- gcdReverse b (a `mod` b)
        tell (toDiffList [show a ++ " mod " ++ show b ++ " = " ++ show (a `mod` b)])
        return result
```

実行

```
*Main> mapM_ putStrLn . fromDiffList . snd . runWriter $ gcdReverse 110 34
Finished with 2
8 mod 2 = 0
34 mod 8 = 2
110 mod 34 = 8
```

## 性能の比較

差分リストの性能比較をする

まず、差分リストから

```haskell
finalCountDown :: Int -> Writer (DiffList String) ()
finalCountDown 0 = do
    tell (toDiffList ["0"])
finalCountDown x = do
    finalCountDown (x-1)
    tell (toDiffList [show x])
```

実行

```
*Main> mapM_ putStrLn . fromDiffList . snd . runWriter $ finalCountDown 500000
0
...
500000
```

普通のリストの場合

```haskell
finalCountDown' :: Int -> Writer [String] ()
finalCountDown' 0 = do
    tell ["0"]
finalCountDown' x = do
    finalCountDown' (x-1)
    tell [show x]
```

実行

```
*Main> mapM_ putStrLn . snd . runWriter $ finalCountDown' 500000
0
...
```

めっちゃ遅い。

## 所感

実際に動かしてみることでかなり性能差があることがわかった。
