/* global test, expect */

import {
  char,
  sequence,
  zeroOrMore,
  between,
  string,
  not,
  always
} from '../src/parser';

// throws an error
const error = e => {
  throw new Error(e);
};

// expect rest to be
const expectSuccess = value => v => expect(v).toEqual(value);

test('parse a single char', () => {
  char('a')
    .run('a')
    .fold(expectSuccess('a'), error);
});

test('parse a sequence', () => {
  sequence([char('a'), char('b'), char('c')])
    .run('abc')
    .fold(expectSuccess(['a', 'b', 'c']), error);
});

test('parses stuff inbetween <html> tags', () => {
  const here = between(
    zeroOrMore(not(string('<here>'))),
    between(
      string('<here>'),
      zeroOrMore(not(string('</here>'))),
      string('</here>')
    ),
    always()
  );

  here
    .run('blah blah <here>hello world</here> blah')
    .fold(expectSuccess('hello world'.split('')), error);
});
