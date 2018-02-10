--import Data.Char
--main = do
--    putStrLn "Hello, what's your first name?"
--    firstName <- getLine
--    putStrLn "What's your last name?"
--    lastName <- getLine
--    let bigFirstName = map toUpper firstName
--        bigLastName = map toUpper lastName
--    putStrLn $ "Hey " ++ bigFirstName ++ " "
--                      ++ bigLastName
--                      ++ ", how are you?"

--main = do
--    putStr "Hey, "
--    putStr "I'm "
--    putStr "Andy!"

--main = do
--    putChar 't'
--    putChar 'e'
--    putChar 's'

--main = do
--    print True
--    print 2
--    print "haha"
--    print 3.2
--    print [3,4,3]

--import Control.Monad
--
--main = do
--    input <- getLine
--    when (input == "SWORDFISH") $ do
--        putStrLn input

--main = do
--    rs <- sequence [getLine, getLine, getLine]
--    print rs

--import Control.Monad
--import Data.Char
--
--main = forever $ do
--    putStr "Give me some input: "
--    l <- getLine
--    putStrLn $ map toUpper l

import Control.Monad

main = do
    colors <- forM [1,2,3,4] $ \a -> do
        putStrLn $ "Which color do you associate with the number "
                   ++ show a ++ "?"
        color <- getLine
        return color
    putStrLn "The colors that you associate with 1, 2, 3 and 4 are: "
    mapM putStrLn colors
