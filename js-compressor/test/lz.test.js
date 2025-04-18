import { expect } from 'chai';
import { compress, decompress } from '../lz.js';

describe('LZ Compression', () => {
  it('should compress and decompress correctly', () => {
    const input = Buffer.from('ABABABABABAB');
    const compressed = compress(input);
    const decompressed = decompress(compressed);
    expect(decompressed.toString()).to.equal(input.toString());
  });

  it('should handle non-repeating data', () => {
    const input = Buffer.from('ABCDEFGH');
    const compressed = compress(input);
    const decompressed = decompress(compressed);
    expect(decompressed.toString()).to.equal(input.toString());
  });

  it('should handle long repeated sequences', () => {
    const input = Buffer.from('ABCABCABCABCABC');
    const compressed = compress(input);
    const decompressed = decompress(compressed);
    expect(decompressed.toString()).to.equal(input.toString());
  });
});
