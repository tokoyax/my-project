-- foo :: Maybe String
-- foo = Just 3 >>= (\x ->
--       Just "!" >>= (\y ->
--       Just (show x ++ y)))

foo :: Maybe String
foo = do
        x <- Just 3
        y <- Just "!"
        Just (show x ++ y)
