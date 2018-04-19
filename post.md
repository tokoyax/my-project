## Eitherモナド

Maybeモナドは値に失敗するかもしれないという文脈をつけられる。
Eitherモナドも失敗の文脈を扱える。しかも、失敗に値を付加できるので失敗の説明ができたりする。

Either e a は、Right値であれば正解や計算の成功、Left値であれば失敗を表す。

```
*Main Lib> :t Right 4
Right 4 :: Num b => Either a b
*Main Lib> :t Left "out of cheese error"
Left "out of cheese error" :: Either [Char] b
```

EitherのMonadインスタンスはMaybeとよく似ている。
Control.Monad.Error モジュールで定義されている。

```haskell
instance (Error e) => Monad (Either e) where
    return x = Right x
    Right x >>= f = f x
    Left err >>= f = Left err
    fail msg = Left (strMsg msg)
```

Left e の e は、Error型クラスのインスタンスでないといけない。
Error型クラスはエラーメッセージのように振る舞える型クラス。
Error型クラスにはエラーを文字列として受け取って、その型に変換する strMsg 関数が定義されている。

モジュールロード時に以下内容の警告が出た。

```
<interactive>:1:1: warning: [-Wdeprecations]
    In the use of ‘strMsg’
    (imported from Control.Monad.Error, but defined in transformers-0.5.2.0:Control.Monad.Trans.Error):
    Deprecated: "Use Control.Monad.Trans.Except instead"
strMsg :: Error a => String -> a
```

Control.Monad.Trans.Except を使ったほうがよさそうである。

```
strMsg :: Error a => String -> a
```

String を受け取って Error型に変換する

Eitherを使ってみる

```
*Main Lib> Left "boom" >>= \x -> return (x+1)
Left "boom"
*Main Lib> Left "boom " >>= \x -> Left "no way!"
Left "boom "
*Main Lib> Right 100 >>= \x -> Left "no way!"
Left "no way!"
```

Maybeぽい動きをしている。

Right を成功する関数に渡すパターン

```
*Main Lib> Right 3 >>= \x -> return (x + 100)
Right 103
```

成功した...

本の中では型シグネチャが無いとエラーになると書いてあった

```
*Main Lib> Right 3 >>= \x -> return (x + 100) :: Either String Int
Right 103
```

こんな感じで指定する

以前やったピエールのバランス棒に何羽の鳥が止まっていたかわかるようにする。

```
import           Control.Monad.Except

type Birds = Int
type Pole = (Birds, Birds)

landLeft :: Birds -> Pole -> Either String Pole
landLeft n (left, right)
    | abs (left + n - right) < 4 = Right (left + n, right)
    | otherwise = Left $ birdsCount (left, right)

landRight :: Birds -> Pole -> Either String Pole
landRight n (left, right)
    | abs (left - (right + n)) < 4 = Right (left, right + n)
    | otherwise = Left $ birdsCount (left, right)

birdsCount :: Pole -> String
birdsCount (left, right) = "Pierre fell off the rope!!" ++
                            " birds on the left: " ++ show left ++
                            ",birds on the right: " ++ show right

banana :: Pole -> Either String Pole
banana p = Left $ birdsCount p

routine :: Either String Pole
routine = do
    start <- return (0, 0)
    first <- landLeft 2 start
    second <- landRight 2 first
    third <- landLeft 1 second
    banana third
```

最終的にバナナで滑って落ちるようにした。

実行

```
*Main> routine
Left "Pierre fell off the rope!! birds on the left: 3,birds on the right: 2"
```

最後のバナナを取り除き、落ちないパターン

```
*Main> routine
Right (3,2)
```

## 所感

初めて自分の力で練習問題ができたように思う。嬉しい。


