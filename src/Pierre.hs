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
    landLeft 1 second

