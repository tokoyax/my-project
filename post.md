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


