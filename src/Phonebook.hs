type PhoneNumber = String
type Name = String
type PhoneBook = [(Name, PhoneNumber)]

phoneBook :: PhoneBook
phoneBook =
  [("betty", "555-2938")
  ,("bonnie1", "334-8878")
  ,("bonnie1", "334-8877")
  ,("bonnie1", "334-8876")
  ,("bonnie1", "334-8875")
  ,("bonnie2", "334-8878")
  ,("bonnie3", "334-8878")
  ,("bonnie3", "335-8878")
  ,("bonnie4", "334-8878")
  ]

inPhoneBook :: Name -> PhoneNumber -> PhoneBook -> Bool
inPhoneBook name pnumber pbook = (name, pnumber) `elem` pbook
