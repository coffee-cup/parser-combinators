import { char, sequence } from './parser';

// char('a')
//   .chain(v1 => char('b').chain(v2 => char('c').map(v3 => [v1, v2, v3])))
//   .run('abc')
//   .fold(v => console.log('success', v), e => console.log('error', e));

sequence([char('a'), char('b'), char('c')])
  .run('abc')
  .fold(v => console.log('success', v), e => console.log('error', e));
