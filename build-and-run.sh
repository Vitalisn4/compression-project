#!/bin/bash

echo "Building Docker images..."

# Build Rust compressor
echo "Building Rust compressor..."
docker build -t rust-compressor ./rust-compressor

# Build JS compressor
echo "Building JavaScript compressor..."
docker build -t js-compressor ./js-compressor

echo "Docker images built successfully!"
echo "Running benchmarks..."

# Run the benchmark script
./benchmark.sh
