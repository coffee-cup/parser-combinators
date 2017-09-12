import Stream from './stream';
import { Success, Failure } from './result';

export default class Parser {
  constructor(parse) {
    this.parse = parse;
  }

  run(iterable) {
    if (iterable instanceof Stream) {
      return this.parse(iterable);
    } else {
      return this.parse(new Stream(iterable));
    }
  }

  map(f) {
    return new Parser(stream => this.parse(stream).map(f));
  }

  bimap(s, f) {
    return new Parser(stream => this.parse(stream).bimap(s, f));
  }

  chain(f) {
    return new Parser(stream =>
      this.parse(stream).chain((v, s) => f(v).run(s))
    );
  }

  fold(s, f) {
    return new Parser(stream => this.parse(stream).fold(s, f));
  }
}

const where = pred =>
  new Parser(stream => {
    if (stream.length === 0) {
      return new Failure('unexpected end', stream);
    }

    const value = stream.head();
    if (pred(value)) {
      return new Success(value, stream.move(1));
    }

    return new Failure('predicate did not match', stream);
  });

export const char = c => where(x => x === c);

export const either = list =>
  new Parser(stream => {
    for (let i = 0; i < list.length; i++) {
      const parser = list[i];
      const result = parser.run(stream);
      if (result instanceof Success) {
        return result;
      }
    }
    return new Failure('either failed', stream);
  });

export const always = value => new Parser(stream => new Success(value, stream));

export const never = value => new Parser(stream => new Failure(value, stream));

export const append = (p1, p2) => p1.chain(vs => p2.map(v => vs.concat([v])));

export const concat = (p1, p2) => p1.chain(xs => p2.map(ys => xs.concat(ys)));

export const sequence = list =>
  list.reduce((acc, parser) => append(acc, parser), always([]));

export const maybe = parser =>
  new Parser(stream =>
    parser
      .run(stream)
      .fold((v, s) => new Success(v, s), (v, s) => new Success(null, stream))
  );

export const lookahead = parser =>
  new Parser(stream =>
    parser.run.fold(v => new Success(v, stream), v => new Failure(v, stream))
  );

export const zeroOrMore = parser =>
  new Parser(stream =>
    parser.run(stream).fold(
      (value, s) =>
        zeroOrMore(parser)
          .map(rest => [value].concat(rest))
          .run(s),
      (value, s) => new Success([], stream)
    )
  );

export const string = str => sequence(str.split('').map(char));

export const not = parser =>
  new Parser(stream =>
    parser
      .run(stream)
      .fold(
        (value, s) => new Failure('not failed', stream),
        (value, s) =>
          stream.length > 0
            ? new Success(stream.head(), stream.move(1))
            : new Failure('unexpected end', stream)
      )
  );

export const between = (l, p, r) => sequence([l, p, r]).map(v => v[1]);
