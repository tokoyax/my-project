## モナド則

ある型がMonadのインスタンスとなっていることは、その型が真にモナドであることを保証しない。
真にモナドになるために、ある型はモナド則を満たす必要がある。

### 左恒等性

`return x >>= f` と `f x` は等価である。

* `return` がある値を最小限の文脈に入れるということができているかを見る
* モナド値と普通の値での操作結果に違いがないことを確認する

Maybeモナドの場合

```
Prelude> return 3 >>= (\x -> Just (x+10000))
Just 10003
Prelude> (\x -> Just (x+10000)) 3
Just 10003
```

リストモナドの場合

```
Prelude> return "WoM" >>= (\x -> [x,x,x])
["WoM","WoM","WoM"]
Prelude> (\x -> [x,x,x]) "WoM"
["WoM","WoM","WoM"]
```

### 右恒等性

`m >>= return` の結果は `m` と等価である。

例

```
Prelude> Just "move on up" >>= return
Just "move on up"
Prelude> [1,2,3,4] >>= return
[1,2,3,4]
Prelude> putStrLn "Wah!" >>= return
Wah!
```

左恒等性と右恒等性はどちらも、`return` に関する法則である。
`return` が最小限の文脈に値を入れているかどうかを確認することが重要。

### 結合法則

`(m >>= f) >>= g` と `m >>= (\x -> f x >>= g)` が等価である。

例

```
*Main> m = [4]
*Main> f x = return $ x + 1
*Main> g x = return $ x * 2
*Main> (m >>= f) >>= g
[10]
*Main> m >>= (\x -> f x >>= g)
[10]
```

掛け算のようなものをイメージする

`(m * f) * g` == `m * (f * g)`

## 所感

こんな法則があるのか。と納得するしかない。

* 参考
  * https://qiita.com/7shi/items/547b6137d7a3c482fe68
