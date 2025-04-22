#  Compression Project

A high-performance file compression tool implementing Run-Length Encoding (RLE) and LZ77 algorithms in both Rust and JavaScript, with intelligent algorithm selection and detailed performance metrics.

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

To try out this project to test it functionalities, do;

```
git clone <repo-url>
```

Then,

```
cd <repo-name>
```

To pull the rust and js-compressor images, run the two commands below;

```
docker pull ghcr.io/vitalisn4/rust-compressor:a30ab70811d30abf470e018ae825052ee70eb80d
```

```
docker pull ghcr.io/vitalisn4/js-compressor:a30ab70811d30abf470e018ae825052ee70eb80d
```

To create aliases for easier use in the compression process, do;

- alias rust-compress="docker run -v $(pwd):/data rust-compressor"
- alias js-compress="docker run -v $(pwd):/data js-compressor"


After cloning the project, to test the rust-compressor functionality, do;

```
cd rust-compressor
```

Then,

```
cargo build --release && cargo test
```

To test the js-compressor functionality, do;

```
cd js-compressor
```

Then,

```
npm install &&  npm test
```


To test automatic algorithm selection, do;

- rust-compress compress input.txt output.compressed
- js-compress compress input.txt output.compressed


To test specific algorithm selection, do;
- rust-compress compress --algorithm rle input.txt output.rle
- js-compress compress -a lz input.txt output.lz


To decompress the files, do;

- rust-compress decompress input.compressed output.txt
- js-compress decompress input.compressed output.txt


### Benchmarking

To run the benchmark script to observe the results in an auto-generated report labeled within the directory `benchmark.md`, do:

```
chmod +x build-and-run.sh
```

Then after,

```
./build-and-run.sh
```

The `benchmark.sh` script provides comprehensive performance metrics:

- Compression ratios for different file types
- Execution time for compression/decompression
- Memory usage statistics
- Analysis between Rust and JS implementations



