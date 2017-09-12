class Stream {
  constructor(iterable, cursor, length) {
    this.iterable = iterable;
    this.cursor = cursor || 0;
    this.length = length === undefined ? iterable.length - this.cursor : length;
  }

  // Get the first value from the iterable
  head() {
    if (this.length <= 0) {
      throw new TypeError('index out of range');
    }
    return this.iterable[this.cursor];
  }

  // Consume the stream by moving the cursor
  move(distance) {
    return new Stream(
      this.iterable,
      this.cursor + distance,
      this.length - distance
    );
  }

  slice(start, stop) {
    if (stop < start) {
      throw new Error('stop < start');
    }

    if (stop && stop > this.length) {
      throw new TypeError('index out of range');
    }

    return new Stream(
      this.iterable,
      this.cursor + start,
      (stop || this.length) - start
    );
  }
}

export default Stream;
