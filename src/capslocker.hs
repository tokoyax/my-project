--import Control.Monad
--import Data.Char

--main = forever $ do
--    l <- getLine
--    putStrLn $ map toUpper l

import Data.Char

main = do
    contents <- getContents
    putStr $ map toUpper contents
