module ParserFinal where

import Control.Monad (liftM, ap)
import Data.Char (digitToInt)

class Monad m => MonadZero m where
  zero :: m a

class MonadZero m => MonadPlus m where
  -- non-deterministic
  (++) :: m a -> m a -> m a

  -- deterministic
  (+++) :: m a -> m a -> m a

-- Parser definition
data Parser a = Parser (String -> [(a, String)])

instance Functor Parser where
  fmap = liftM

instance Applicative Parser where
  pure = return
  (<*>) = ap

instance Monad Parser where
  return v  = Parser (\inp -> [(v, inp)])
  p >>= f   = Parser (\inp -> concat [parse (f v) inp' |
                                (v, inp') <- parse p inp])

instance MonadZero Parser where
  zero = Parser (const [])

instance MonadPlus Parser where
  p ++ q = Parser (\inp -> parse p inp Prelude.++ parse q inp)
  p +++ q = first (p Parser.++ q)


parse :: Parser a -> (String -> [(a, String)])
parse (Parser p) = p

item :: Parser Char
item = Parser (\inp -> case inp of
                          "" -> []
                          (x:xs) -> [(x, xs)])

force :: Parser a -> Parser a
force p = Parser (\inp -> let x = parse p inp in
                  (fst (head x), snd (head x)) : tail x)

first :: Parser a -> Parser a
first p = Parser (\inp -> case parse p inp of
                            [] -> []
                            (x:_) -> [x])

sat :: (Char -> Bool) -> Parser Char
sat p = do {x <- item; if p x then return x else zero}

many :: Parser a -> Parser [a]
many p = force (many1 p +++ return [])

many1 :: Parser a -> Parser [a]
many1 p = do {x <- p; xs <- many p; return (x:xs)}

sepby :: Parser a -> Parser b -> Parser [a]
p `sepby` sep = (p `sepby` sep) +++ return []

sepby1 :: Parser a -> Parser b -> Parser [a]
p `sepby1` sep = do a <- p
                    as <- many (do {sep; p})
                    return (a:as)

chainl :: Parser a -> Parser (a -> a -> a) -> a -> Parser a
chainl p op a = (p `chainl1` op) +++ return a

chainl1 :: Parser a -> Parser (a -> a -> a) -> Parser a
p `chainl1` op = do {a <- p; rest a}
  where
    rest a = (do  f <- op
                  b <- p
                  rest (f a b))
              +++ return a

chainr :: Parser a -> Parser (a -> a -> a) -> a -> Parser a
chainr p op a = (p `chainr1` op) +++ return a

chainr1 :: Parser a -> Parser (a -> a -> a) -> Parser a
p `chainr1` op =
  p >>= \x ->
    (do {f <- op; y <- p `chainr1` op; return (f x y)}) +++ return x


char :: Char -> Parser Char
char x = sat (\y -> y == x)

digit :: Parser Char
digit = sat (\x -> '0' <= x && x <= '9')

lower :: Parser Char
lower = sat (\x -> 'a' <= x && x <= 'z')

upper :: Parser Char
upper = sat (\x -> 'A' <= x && x <= 'Z')

letter :: Parser Char
letter = lower Parser.++ upper

alphanum :: Parser Char
alphanum = letter +++ digit

string :: String -> Parser String
string ""      = return ""
string (x:xs)  = do {char x; string xs; return (x:xs)}

ops :: [(Parser a, b)] -> Parser b
ops xs = foldr1 (+++) (do (p, op) <- xs
                          return (do {p; return op}))

word :: Parser String
word = many letter

-- Parse an identifier
ident :: Parser String
ident = do {x <- lower; xs <- many alphanum; return (x:xs)}

-- Parse a natural number
nat :: Parser Int
nat = do {xs <- many1 digit; return $ eval xs}
    where
      eval xs = foldl1 op [digitToInt x | x <- xs]
      m `op` n = 10 * m + n

-- Parse an integer
int :: Parser Int
int = do {f <- op; n <- nat; return $ f n}
      where
        op = do {char '-'; return negate} +++ return id

-- Parse something between openning and closing brackets
bracket :: Parser a -> Parser b -> Parser c -> Parser b
bracket open p close = do {open; x <- p; close; return x}

-- Parse a series of intergers separated by commas
ints :: Parser [Int]
ints = do bracket (char '[')
                  (int `sepby1` char ',')
                  (char ']')

-- Parse a string of spaces, tabs, and newlines
spaces :: Parser ()
spaces = (do {many1 (sat isSpace); return ()})
        where
          isSpace x =
            (x == ' ') || (x == '\n') || (x == '\t')

comment :: Parser ()
comment = do {string "--"; many (sat (\x -> x /= '\n')); return ()}

junk :: Parser ()
junk = do {many (spaces +++ comment); return ()}

-- Apply a parser p, throwing away any leading space
apply :: Parser a -> String -> [(a, String)]
apply p = parse (do {junk; p})


-- Parse a token using parser p, throwing away any trailing space
token :: Parser a -> Parser a
token p = do {a <- p; spaces; return a}

natural :: Parser Int
natural = token nat

integer :: Parser Int
integer = token int

-- Parse a symbolic token
symbol :: String -> Parser String
symbol xs = token (string xs)

-- Parse an identifier
identifier :: [String] -> Parser String
identifier ks = do {x <- ident; return (x `notElem` ks); return x}

-- Parsing simple arithmetic expressions
--
-- expr   ::= expr addop factor | factor
-- addop  ::= + | -
-- factor ::= nat | (expr)

expr :: Parser Int
expr = term `chainl1` addop

term :: Parser Int
term = factor `chainr1` expop

factor :: Parser Int
factor = nat +++ bracket (char '(') expr (char ')')

addop :: Parser (Int -> Int -> Int)
addop = ops [(char '+', (+)), (char '-', (-))]

expop :: Parser (Int -> Int -> Int)
expop = ops [(char '^', (^))]

eval :: Parser Int
eval = do x <- nat
          f <- addop
          y <- nat
          return (f x y)