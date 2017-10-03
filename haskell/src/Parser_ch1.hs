module Parser where

type Parser a = String -> [(a, String)]

result :: a -> Parser a
result v inp = [(v, inp)]

zero :: Parser a
zero _ = []

item :: Parser Char
item inp = case inp of
              [] -> []
              (x:xs) -> [(x, xs)]

bind :: Parser a -> (a -> Parser b) -> Parser b
p `bind` f = \inp -> concat [f v inp' | (v, inp') <- p inp]

seq :: Parser a -> Parser b -> Parser (a, b)
p `seq` q = p `bind` \x ->
            q `bind` \y ->
            result (x, y)

sat :: (Char -> Bool) -> Parser Char
sat p = item `bind` \x ->
        if p x then result x else zero

plus :: Parser a -> Parser a -> Parser a
p `plus` q = \inp -> p inp ++ q inp

char :: Char -> Parser Char
char x = sat (\y -> x == y)

digit :: Parser Char
digit = sat (\x -> '0' <= x && x <= '9')

lower :: Parser Char
lower = sat (\x -> 'a' <= x && x <= 'z')

upper :: Parser Char
upper = sat (\x -> 'A' <= x && x <= 'Z')

letter :: Parser Char
letter = lower `plus` upper

alphanum :: Parser Char
alphanum = letter `plus` digit

word :: Parser String
word = newWord `plus` result ""
        where
          newWord = letter `bind` \x ->
                    word `bind` \xs ->
                    result (x:xs)