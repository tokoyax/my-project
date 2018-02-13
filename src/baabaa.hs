--import System.IO
--
--main = do
--    handle <- openFile "baabaa.txt" ReadMode
--    contents <- hGetContents handle
--    putStr contents
--    hClose handle

--import System.IO
--
--main = do
--    withFile "baabaa.txt" ReadMode $ \handle -> do
--        contents <- hGetContents handle
--        putStr contents

--import Control.Exception
--import System.IO
--
--main = do
--    withFile' "baabaa.txt" ReadMode $ \handle -> do
--        contents <- hGetContents handle
--        putStr contents
--
--withFile' :: FilePath -> IOMode -> (Handle -> IO a) -> IO a
--withFile' name mode f = bracket (openFile name mode)
--    (\handle -> hClose handle)
--    (\handle -> f handle)

--import System.IO
--import Data.Char
--
--main = do
--    contents <- readFile "baabaa.txt"
--    putStr contents

import System.IO
import Data.Char

main = do
    contents <- readFile "baabaa.txt"
    writeFile "baabaacaps.txt" (map toUpper contents)
