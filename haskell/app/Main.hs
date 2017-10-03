module Main where

import Control.Monad
import CalculatorCoffee

main :: IO ()
main = forever $ do
  putStr "> "
  a <- getLine
  print $ eval $ run a
