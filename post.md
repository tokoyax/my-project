## Zipper

Haskellで木構造の要素を変更したい場合、ルート要素から指定の要素が見つかるまで探索が必要になる。
また、前回更新した要素の近くの要素を更新したい場合などでもルートから探す必要がある。
これは効率が悪い。

そこでZipperを使ってデータ構造の要素の更新を簡単にする。

## 歩く

木構造のデータ型を定義する

```haskell
data Tree a = Empty | Node a (Tree a) (Tree a) deriving (Show)
```

木構造データを定義する

```haskell
freeTree :: Tree Char
freeTree =
    Node 'P'
        (Node 'O'
            (Node 'L'
                (Node 'N' Empty Empty)
                (Node 'T' Empty Empty)
            )
            (Node 'Y'
                (Node 'S' Empty Empty)
                (Node 'A' Empty Empty)
            )
        )
        (Node 'L'
            (Node 'W'
                (Node 'C' Empty Empty)
                (Node 'R' Empty Empty)
            )
            (Node 'A'
                (Node 'A' Empty Empty)
                (Node 'C' Empty Empty)
            )
        )
```

'W' を 'P' に変更する関数

```haskell
changeToP :: Tree Char -> Tree Char
changeToP (Node x l (Node y (Node _ m n) r)) = Node x l (Node y (Node 'P' m n) r)
```

どう考えてもわかりにくい。

関数が方向のリストをとれるようにしてみる。
方向とはLかRのいずれかで、左と右に対応し、方向指示に従ってたどり着いた位置の値を更新する。

```haskell
data Direction = L | R deriving (Show)
type Directions = [Direction]

changeToP :: Directions -> Tree Char -> Tree Char
changeToP (L:ds) (Node x l r) = Node x (changeToP ds l) r
changeToP (R:ds) (Node x l r) = Node x l (changeToP ds r)
changeToP [] (Node _ l r)     = Node 'P' l r
```

方向リストに基づいて探索する要素を選択している。

方向リストをとって目的地にある要素を返す関数

```haskell
elemAt :: Directions -> Tree a -> a
elemAt (L:ds) (Node _ l _) = elemAt ds l
elemAt (R:ds) (Node _ _ r) = elemAt ds r
elemAt [] (Node x _ _)     = x
```

実行

```
*Main> newTree = changeToP [R,L] freeTree
*Main> elemAt [R,L] newTree
'P'
```

変わってる。

方向リストは木の特定の部分木、注目点を指定する役割を果たしている。
ただし、この方法は何度も要素を更新したい場合に効率が悪い。

### 背後に残った道しるべ

要素を探す時にパンくずを残していって、往路の履歴を覚えておくようにする。
すると逆方向の移動ができるようになる。

```haskell
type Breadcrumbs = [Direction]

goLeft :: (Tree a, Breadcrumbs) -> (Tree a, Breadcrumbs)
goLeft (Node _ l _, bs) = (l, L:bs)

goRight :: (Tree a, Breadcrumbs) -> (Tree a, Breadcrumbs)
goRight (Node _ _ r, bs) = (r, R:bs)
```

木とパンくずリストを受け取って、
探索した方向の木と方向を追記したパンくずリストを返す関数。

使ってみる

```
*Main> goLeft $ goRight (freeTree, [])
(Node 'W' (Node 'C' Empty Empty) (Node 'R' Empty Empty),[L,R])
```

いい感じに書くためにいい感じの関数を定義する

```haskell
x -: f = f x
```

パイプラインみたいにこうかける

```
*Main> (freeTree, []) -: goRight -: goLeft
(Node 'W' (Node 'C' Empty Empty) (Node 'R' Empty Empty),[L,R])
```

### 来た道を戻る方法

今のパンくずリストでは来た道を戻るための情報が足りていない。
辿った木構造の情報もパンくずリストに持っておく必要がある。

1つのパンくずには親ノードを構築するのに必要なすべてのデータを蓄えておく必要がある。
辿る可能性のあった経路の情報も必要。

パンくずリストを改良する。
Direction に代わる新しいデータ型を作る。

```haskell
data Crumb a = LeftCrumb a (Tree a) | RightCrumb a (Tree a) deriving (Show)
```

移動元に含まれていた要素と、辿らなかった部分木を持つようになっている。
L の代わりに LeftCrumb、R の代わりに RightCrumb となっている。

このデータ型を使ってプログラムを書き換える

```haskell
type Breadcrumbs a = [Crumb a]

goLeft :: (Tree a, Breadcrumbs a) -> (Tree a, Breadcrumbs a)
goLeft (Node x l r, bs) = (l, LeftCrumb x r:bs)

goRight :: (Tree a, Breadcrumbs a) -> (Tree a, Breadcrumbs a)
goRight (Node x l r, bs) = (r, RightCrumb x l:bs)

goUp :: (Tree a, Breadcrumbs a) -> (Tree a, Breadcrumbs a)
goUp (t, LeftCrumb x r:bs)  = (Node x t r, bs)
goUp (t, RightCrumb x l:bs) = (Node x l t, bs)
```

上に上がる処理も追加している。

あるデータ構造の注目点、および周辺の情報を含んでいるデータ構造のことをZipperという。
型シノニムを定義する。

```haskell
type Zipper a = (Tree a, Breadcrumbs a)
```

### 注目している木を操る

Zipperが注目している部分木のルート要素を書き換える関数を書く

```haskell
modify :: (a -> a) -> Zipper a -> Zipper a
modify f (Node x l r, bs) = (Node (f x) l r, bs)
modify f (Empty, bs)      = (Empty, bs)
```

実行

```
*Main> newFocus = (freeTree, []) -: goLeft -: goRight -: modify (\_ -> 'P')
*Main> newFocus
(Node 'P' (Node 'S' Empty Empty) (Node 'A' Empty Empty),[RightCrumb 'O' (Node 'L' (Node 'N' Empty Empty) (Node 'T' Empty Empty)),LeftCrumb 'P' (Node 'L' (Node 'W' (Node 'C' Empty Empty) (Node 'R' Empty Empty)) (Node 'A' (Node 'A' Empty Empty) (Node 'C' Empty Empty)))])
```

1つ上に移動し 'X' に置き換え

```
*Main> newFocus2 = newFocus -: goUp -: modify (\_ -> 'X')
*Main> newFocus2
(Node 'X' (Node 'L' (Node 'N' Empty Empty) (Node 'T' Empty Empty)) (Node 'P' (Node 'S' Empty Empty) (Node 'A' Empty Empty)),[LeftCrumb 'P' (Node 'L' (Node 'W' (Node 'C' Empty Empty) (Node 'R' Empty Empty)) (Node 'A' (Node 'A' Empty Empty) (Node 'C' Empty Empty)))])
```

部分木を継ぎ足す操作を作る

```haskell
attach :: Tree a -> Zipper a -> Zipper a
attach t (_, bs) = (t, bs)
```

これは、空の部分木に対して新しい部分木を追加するだけでなく既存の部分木を置換もできる。

```
*Main> farLeft = (freeTree, []) -: goLeft -: goLeft -: goLeft -: goLeft
*Main> newFocus = farLeft -: attach (Node 'Z' Empty Empty)
*Main> newFocus
(Node 'Z' Empty Empty,[LeftCrumb 'N' Empty,LeftCrumb 'L' (Node 'T' Empty Empty),LeftCrumb 'O' (Node 'Y' (Node 'S' Empty Empty) (Node 'A' Empty Empty)),LeftCrumb 'P' (Node 'L' (Node 'W' (Node 'C' Empty Empty) (Node 'R' Empty Empty)) (Node 'A' (Node 'A' Empty Empty) (Node 'C' Empty Empty)))])
```

goUpでルートまで戻ると新しい木が取得できる。

### 木のてっぺんまで戻る

木のてっぺんに戻る関数

```haskell
topMost :: Zipper a -> Zipper a
topMost (t, []) = (t, [])
topMost z       = topMost (goUp z)
```

てっぺんに着くまで再帰で辿る

```
*Main> farLeft = (freeTree, []) -: goLeft -: goLeft -: goLeft -: goLeft
*Main> newFocus = farLeft -: attach (Node 'Z' Empty Empty)
*Main> topMost newFocus
(Node 'P' (Node 'O' (Node 'L' (Node 'N' (Node 'Z' Empty Empty) Empty) (Node 'T' Empty Empty)) (Node 'Y' (Node 'S' Empty Empty) (Node 'A' Empty Empty))) (Node 'L' (Node 'W' (Node 'C' Empty Empty) (Node 'R' Empty Empty)) (Node 'A' (Node 'A' Empty Empty) (Node 'C' Empty Empty))),[])
```

てっぺんに着いている

## リストに注目する

リストのZipperを作る

```haskell
type ListZipper a = ([a], [a])

goFoward :: ListZipper a -> ListZipper a
goFoward (x:xs, bs) = (xs, x:bs)

goBack :: ListZipper a -> ListZipper a
goBack (xs, b:bs) = (b:xs, bs)
```

実行

```
*Main> xs = [1,2,3,4]
*Main> goFoward (xs, [])
([2,3,4],[1])
*Main> goFoward ([2,3,4], [1])
([3,4],[2,1])
*Main> goFoward ([3,4], [2,1])
([4],[3,2,1])
*Main> goBack ([4], [3,2,1])
([3,4],[2,1])
```

## シンプルなファイルシステム

ごく単純化したファイルシステムを木で表現する。
そのファイルシステムに対するZipperを作り、本物のファイルシステムみたいにフォルダ間を移動できるようにする。

* ファイル : 名前がついていて、データが入っている
* フォルダ : 名前がついていて、複数のファイルやフォルダをアイテムとして含む

データ型を作る

```haskell
type Name = String
type Data = String
data FSItem = File Name Data | Folder Name [FSItem] deriving (Show)
```

フォルダのサンプル

```haskell
myDisk :: FSItem
myDisk =
    Folder "root"
    [ File "goat_yelling_like_man.wmv" "baaaaaa"
    , File "pope_time.avi" "god bless"
    , Folder "pics"
        [ File "ape_throwing_up.jpg" "bleargh"
        , File "watermelon_smash.gif" "smash!!"
        , File "skull_man(scary).bmp" "Yikes!"
        ]
    , File "dijon_poupon.doc" "best mustard"
    , Folder "programs"
        [ File "fartwizard.exe" "10gotofart"
        , File "owl_bandit.dmg" "mov eax, h00t"
        , File "not_a_virus.exe" "really not a virus"
        , Folder "source code"
            [ File "best_hs_prog.hs" "main = print (fix error)"
            , File "random.hs" "main = print 4"
            ]
        ]
    ]
```

Zipperを作る

パンくずリストのデータ型を定義

```haskell
data FSCrumb = FSCrumb Name [FSItem] [FSItem] deriving (Show)
```

Zipperの定義

```haskell
type FSZipper = (FSItem, [FSCrumb])
```

階層構造を上に戻る関数

```haskell
fsUp :: FSZipper -> FSZipper
fsUp (item, FSCrumb name ls rs:bs) = (Folder name (ls ++ [item] ++ rs), bs)
```

パンくずには、フォルダの名前、フォルダの中で注目点より前にあったアイテムのリスト(ls)、
注目点より後ろにあったアイテムのリスト(rs) が全部入っている。

フォルダの中にあるファイルまたはフォルダに注目点を移す関数

```haskell
import           Data.List

fsTo :: Name -> FSZipper -> FSZipper
fsTo name (Folder folderName items, bs) = let (ls, item:rs) = break (nameIs name) items
                                          in  (item, FSCrumb folderName ls rs:bs)

nameIs :: Name -> FSItem -> Bool
nameIs name (Folder folderName _) = name == folderName
nameIs name (File fileName _)     = name == fileName
```

break は述語とリストを引数にとり、リストのペアを返す。
述語がFalseを返すような要素が第一要素に入る。
ここで、探していたものより前にあるか後ろにあるかを振り分けている。

実際に移動してみる

```
*Main> newFocus = (myDisk, []) -: fsTo "pics" -: fsTo "skull_man(scary).bmp"
*Main> fst newFocus
File "skull_man(scary).bmp" "Yikes!"
```

そのまま上に戻って、別のファイルを見る

```
*Main> newFocus2 = newFocus -: fsUp -: fsTo "watermelon_smash.gif"
*Main> fst newFocus2
File "watermelon_smash.gif" "smash!!"
```

### ファイルシステムの操作

リネーム関数

```haskell
fsRename :: Name -> FSZipper -> FSZipper
fsRename newName (Folder name items, bs) = (Folder newName items, bs)
fsRename newName (File name dat, bs)     = (File newName dat, bs)
```

"pics" フォルダの名前を "cspi" に変更

```
*Main> newFocus = (myDisk, []) -: fsTo "pics" -: fsRename "cspi" -: fsUp
*Main> fst newFocus
Folder "root" [File "goat_yelling_like_man.wmv" "baaaaaa",File "pope_time.avi" "god bless",Folder "cspi" [File "ape_throwing_up.jpg" "bleargh",File "watermelon_smash.gif" "smash!!",File "skull_man(scary).bmp" "Yikes!"],File "dijon_poupon.doc" "best mustard",Folder "programs" [File "fartwizard.exe" "10gotofart",File "owl_bandit.dmg" "mov eax, h00t",File "not_a_virus.exe" "really not a virus",Folder "source code" [File "best_hs_prog.hs" "main = print (fix error)",File "random.hs" "main = print 4"]]]
```

現在のフォルダにアイテムを新規作成する関数

```haskell
fsNewFile :: FSItem -> FSZipper -> FSZipper
fsNewFile item (Folder folderName items, bs) = (Folder folderName (item:items), bs)
```

作成してみる

```
*Main> newFocus = (myDisk, []) -: fsTo "pics" -: fsNewFile (File "heh.jpg" "lol") -: fsUp
*Main> fst newFocus
Folder "root" [File "goat_yelling_like_man.wmv" "baaaaaa",File "pope_time.avi" "god bless",Folder "pics" [File "heh.jpg" "lol",File "ape_throwing_up.jpg" "bleargh",File "watermelon_smash.gif" "smash!!",File "skull_man(scary).bmp" "Yikes!"],File "dijon_poupon.doc" "best mustard",Folder "programs" [File "fartwizard.exe" "10gotofart",File "owl_bandit.dmg" "mov eax, h00t",File "not_a_virus.exe" "really not a virus",Folder "source code" [File "best_hs_prog.hs" "main = print (fix error)",File "random.hs" "main = print 4"]]]
```

Haskell のデータ構造は Immutable である。
そのため、旧バージョンのデータに何の問題もなくアクセスできる。
Zipperを使ってそのImmutableなデータ構造の中を効率よく移動できるようになった。

## 足元にご注意

パターンマッチに失敗するなどして実行時エラーが出るのをそのままにしていた。
Maybeモナドを使って失敗の可能性という文脈を追加する。

二分木を処理するZipperをモナディック関数に変更する。

```haskell
goLeft :: Zipper a -> Maybe (Zipper a)
goLeft (Node x l r, bs) = Just (l, LeftCrumb x r:bs)
goLeft (Empty, _)       = Nothing

goRight :: Zipper a -> Maybe (Zipper a)
goRight (Node x l r, bs) = Just (r, RightCrumb x l:bs)
goRight (Empty, _)       = Nothing

goUp :: Zipper a -> Maybe (Zipper a)
goUp (t, LeftCrumb x r:bs)  = Just (Node x t r, bs)
goUp (t, RightCrumb x l:bs) = Just (Node x l t, bs)
goUp (_, [])                = Nothing

modify :: (a -> a) -> Zipper a -> Zipper a
modify f (Node x l r, bs) = (Node (f x) l r, bs)
modify f (Empty, bs)      = (Empty, bs)

attach :: Tree a -> Zipper a -> Zipper a
attach t (_, bs) = (t, bs)

topMost :: Zipper a -> Zipper a
topMost (t, []) = (t, [])
topMost z       = let Just n = goUp z
                  in topMost n
```

移動系の関数についてMaybeを返すように変更

実行

```
*Main> goLeft (Empty, [])
Nothing
*Main> goLeft (Node 'A' Empty Empty, [])
Just (Empty,[LeftCrumb 'A' Empty])
```

ちゃんとNothing, Justが返ってきている。

連続で移動するためには、`-:` ではなく `>>=` を使う。

```
*Main> coolTree = Node 1 Empty (Node 3 Empty Empty)
*Main> return (coolTree, []) >>= goRight
Just (Node 3 Empty Empty,[RightCrumb 1 Empty])
*Main> return (coolTree, []) >>= goRight >>= goRight
Just (Empty,[RightCrumb 3 Empty,RightCrumb 1 Empty])
*Main> return (coolTree, []) >>= goRight >>= goRight >>= goRight
Nothing
```

ちゃんと失敗してる。

## 所感

Zipperが木構造などを扱うのに役立つというのはわかった。が、自分ではまだ書けない。
