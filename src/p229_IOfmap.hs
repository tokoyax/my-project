main = do
    line <- fmap reverse getLine
    putStrLn $ "You said " ++ line ++ " backwords!"
    putStrLn $ "Yes, you said " ++ line ++ " backwords!"
