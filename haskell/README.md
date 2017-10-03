# parser-combinator-haskell

This is a parser combinator implementation in Haskell.

This was written after studying the following resources

- [Monadic Parser Combinators](http://www.itu.dk/people/carsten/courses/f02/handouts/MonadicParserCombinators.pdf)
- [Monadic Parsing in Haskell](http://www.cs.nott.ac.uk/~pszgmh/pearl.pdf)
- [Parser Combinators](http://dev.stephendiehl.com/fun/002_parsers.html)

Big thanks to Graham Hutton, Erik Meijer, and Stephen Diehl for writing those articles.

This code has been iterated upon many times. Version v1 is `ParserV1.hs`. V2 is `ParserV2.hs`, and the most complete version is `CoffeeParser.hs`. I use these implementations in `LambdaExpressions.hs` and `CalcualtorCoffee.hs`.

## Building

- `stack setup`
- `stack build`

## Using

You can use the calculator with

```
stack runghc app/Main.hs
```

This will bring up a prompt where you can evaluate arithmetic expressions (`+`, `-`, `*`).

Check out `src/CoffeeParser.hs` and `src/CalculatorCoffee.hs` to see how it works.