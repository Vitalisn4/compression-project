#  Compression Project

A high-performance file compression tool implementing Run-Length Encoding (RLE) and LZ77 algorithms in both Rust and JavaScript, with intelligent algorithm selection and detailed performance metrics.

## Features

- **Smart Compression**
  - Automatic algorithm selection based on file content analysis
  - RLE optimization for repetitive sequences
  - LZ77 for general-purpose compression
  - Detailed compression statistics and reporting

- **Dual Implementation**
  - Rust implementation for maximum performance
  - JavaScript implementation for web compatibility
  - Identical compression ratios across both implementations

- **Performance Metrics**
  - Real-time compression ratio reporting
  - Speed benchmarking for compression/decompression
  - Detailed benchmark reports with comparative analysis

## Installation

### Using Docker (Recommended)

```bash
# Pull the images
docker pull ghcr.io/[owner]/rust-compressor:latest
docker pull ghcr.io/[owner]/js-compressor:latest

# Create aliases for easier use
alias rust-compress="docker run -v $(pwd):/data rust-compressor"
alias js-compress="docker run -v $(pwd):/data js-compressor"
```

### Building from Source

#### Rust Compressor
```bash
cd rust-compressor
cargo build --release
```

#### JavaScript Compressor
```bash
cd js-compressor
npm install
```

## Usage

### Basic Commands

```bash
# Automatic algorithm selection (recommended)
rust-compress compress input.txt output.compressed
js-compress compress input.txt output.compressed

# Specific algorithm selection
rust-compress compress --algorithm rle input.txt output.rle
js-compress compress -a lz input.txt output.lz

# Decompression
rust-compress decompress input.compressed output.txt
js-compress decompress input.compressed output.txt
```

## Benchmarking

The `benchmark.sh` script provides comprehensive performance metrics:

- Compression ratios for different file types
- Execution time for compression/decompression
- Memory usage statistics
- Analysis between Rust and JS implementations


## Project Structure

```
compression-project/
├── rust-compressor/
│   ├── src/
│   │   ├── main.rs
│   │   ├── rle.rs
│   │   └── lz.rs
│   ├── Cargo.toml
│   └── Dockerfile
├── js-compressor/
│   ├── index.js
│   ├── rle.js
│   ├── lz.js
│   └── package.json
    ├── test/
│   └── Dockerfile
├── benchmark.sh
└── build-and-run.sh
└── README.md
```


