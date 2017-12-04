doubleMe x = x + x
-- doubleUs x y = x * 2 + y * 2
doubleUs x y = doubleMe x + doubleMe y

doubleSmallNumber x = if x > 100
                        then x
                        else x * 2

doubleSmallNumber' x = (if x > 100 then x else x * 2) + 1


-- リスト内包表記
boomBangs xs = [ if x < 10 then "BOOM!!!" else "BANG!!!" | x <- xs, odd x]
removeNonUppercase st = [ c | c <- st, c `elem` ['A'..'Z']]
