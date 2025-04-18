#!/usr/bin/env node

import { program } from 'commander';
import fs from 'fs/promises';
import { createReadStream } from 'fs';
import { compress as compressRLE, decompress as decompressRLE } from './rle.js';
import { compress as compressLZ, decompress as decompressLZ } from './lz.js';

function detectBestAlgorithm(data) {
  // Count repeating sequences
  let repeats = 0;
  for (let i = 1; i < data.length; i++) {
    if (data[i] === data[i - 1]) {
      repeats++;
    }
  }
  
  // Calculate repetition ratio
  const ratio = repeats / data.length;
  
  // Use RLE for highly repetitive data (>30% repetition)
  return ratio > 0.3 ? 'rle' : 'lz';
}

program
  .name('js-compressor')
  .description('File compression tool implementing RLE and LZ77 algorithms');

program
  .command('compress')
  .description('Compress a file using specified algorithm')
  .option('-a, --algorithm <type>', 'compression algorithm (rle or lz, auto by default)')
  .argument('<input>', 'input file path')
  .argument('<output>', 'output file path')
  .action(async (input, output, options) => {
    try {
      const data = await fs.readFile(input);
      const algorithm = options.algorithm || detectBestAlgorithm(data);
      let compressed;
      
      console.log(`Using ${algorithm.toUpperCase()} algorithm`);
      
      if (algorithm === 'rle') {
        compressed = compressRLE(data);
      } else if (algorithm === 'lz') {
        compressed = compressLZ(data);
      } else {
        throw new Error('Unknown algorithm');
      }
      
      await fs.writeFile(output, compressed);
      
      const ratio = ((compressed.length / data.length) * 100).toFixed(2);
      console.log(`Compression completed successfully`);
      console.log(`Original size: ${data.length} bytes`);
      console.log(`Compressed size: ${compressed.length} bytes`);
      console.log(`Compression ratio: ${ratio}%`);
    } catch (error) {
      console.error('Compression failed:', error.message);
      process.exit(1);
    }
  });

program
  .command('decompress')
  .description('Decompress a file using specified algorithm')
  .option('-a, --algorithm <type>', 'compression algorithm (rle or lz)')
  .argument('<input>', 'input file path')
  .argument('<output>', 'output file path')
  .action(async (input, output, options) => {
    try {
      const data = await fs.readFile(input);
      let decompressed;
      
      if (options.algorithm === 'rle') {
        decompressed = decompressRLE(data);
      } else if (options.algorithm === 'lz') {
        decompressed = decompressLZ(data);
      } else {
        throw new Error('Unknown algorithm');
      }
      
      await fs.writeFile(output, decompressed);
      console.log('Decompression completed successfully');
    } catch (error) {
      console.error('Decompression failed:', error.message);
      process.exit(1);
    }
  });

program.parse();
