import { expect } from 'chai';
import { compress, decompress } from '../rle.js';

describe('RLE Compression', () => {
  it('should compress and decompress correctly', () => {
    const input = Buffer.from('AAABBBCCCCCDDDDE');
    const compressed = compress(input);
    const decompressed = decompress(compressed);
    expect(decompressed.toString()).to.equal(input.toString());
  });

  it('should handle single character input', () => {
    const input = Buffer.from('A');
    const compressed = compress(input);
    const decompressed = decompress(compressed);
    expect(decompressed.toString()).to.equal(input.toString());
  });

  it('should handle repeated characters', () => {
    const input = Buffer.from('AAAAA');
    const compressed = compress(input);
    const decompressed = decompress(compressed);
    expect(decompressed.toString()).to.equal(input.toString());
  });
});
