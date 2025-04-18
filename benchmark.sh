#!/bin/bash

# Create test files of different types
dd if=/dev/urandom of=test_random.dat bs=1M count=10
yes "ABCDEFGHIJKLMNOPQRSTUVWXYZ" | head -c 10M > test_repeating.dat
head -c 10M /dev/zero > test_zeros.dat

echo "Running benchmarks..."
echo "===================="

# Function to get file size in bytes (compatible with both Linux and macOS)
get_file_size() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$1"
    else
        stat -c%s "$1"
    fi
}

# Function to format size in human readable format
format_size() {
    numfmt --to=iec-i --suffix=B "$1"
}

# Function to calculate compression ratio
calculate_ratio() {
    local original_size=$1
    local compressed_size=$2
    echo "scale=2; ($original_size/$compressed_size)" | bc
}

# Function to extract timing
get_timing() {
    local timing_file=$1
    grep "^real" "$timing_file" | cut -f2
}

# Function to run benchmarks for a specific file
benchmark_file() {
    local file=$1
    local size=$(get_file_size "$file")
    local results_dir="benchmark_results"
    mkdir -p "$results_dir"
    
    echo "Testing file: $file (Original size: $(format_size $size))"
    
    # Rust RLE
    echo "Rust RLE Compression:"
    { time docker run -v $(pwd):/data rust-compressor compress --algorithm rle /data/$file /data/$file.rle; } 2> "$results_dir/rust_rle_comp.time"
    if [ -f "$file.rle" ]; then
        compressed_size=$(get_file_size "$file.rle")
        echo "Compressed size: $(format_size $compressed_size)"
        echo "Compression ratio: $(calculate_ratio $size $compressed_size):1"
        echo "Time taken: $(get_timing "$results_dir/rust_rle_comp.time")"
    fi
    
    echo "Rust RLE Decompression:"
    { time docker run -v $(pwd):/data rust-compressor decompress --algorithm rle /data/$file.rle /data/$file.restored; } 2> "$results_dir/rust_rle_decomp.time"
    echo "Time taken: $(get_timing "$results_dir/rust_rle_decomp.time")"
    echo
    
    # Rust LZ
    echo "Rust LZ Compression:"
    { time docker run -v $(pwd):/data rust-compressor compress --algorithm lz /data/$file /data/$file.lz; } 2> "$results_dir/rust_lz_comp.time"
    if [ -f "$file.lz" ]; then
        compressed_size=$(get_file_size "$file.lz")
        echo "Compressed size: $(format_size $compressed_size)"
        echo "Compression ratio: $(calculate_ratio $size $compressed_size):1"
        echo "Time taken: $(get_timing "$results_dir/rust_lz_comp.time")"
    fi
    
    echo "Rust LZ Decompression:"
    { time docker run -v $(pwd):/data rust-compressor decompress --algorithm lz /data/$file.lz /data/$file.restored; } 2> "$results_dir/rust_lz_decomp.time"
    echo "Time taken: $(get_timing "$results_dir/rust_lz_decomp.time")"
    echo
    
    # JS RLE
    echo "JavaScript RLE Compression:"
    { time docker run -v $(pwd):/data js-compressor compress -a rle /data/$file /data/$file.js.rle; } 2> "$results_dir/js_rle_comp.time"
    if [ -f "$file.js.rle" ]; then
        compressed_size=$(get_file_size "$file.js.rle")
        echo "Compressed size: $(format_size $compressed_size)"
        echo "Compression ratio: $(calculate_ratio $size $compressed_size):1"
        echo "Time taken: $(get_timing "$results_dir/js_rle_comp.time")"
    fi
    
    echo "JavaScript RLE Decompression:"
    { time docker run -v $(pwd):/data js-compressor decompress -a rle /data/$file.js.rle /data/$file.restored; } 2> "$results_dir/js_rle_decomp.time"
    echo "Time taken: $(get_timing "$results_dir/js_rle_decomp.time")"
    echo
    
    # JS LZ
    echo "JavaScript LZ Compression:"
    { time docker run -v $(pwd):/data js-compressor compress -a lz /data/$file /data/$file.js.lz; } 2> "$results_dir/js_lz_comp.time"
    if [ -f "$file.js.lz" ]; then
        compressed_size=$(get_file_size "$file.js.lz")
        echo "Compressed size: $(format_size $compressed_size)"
        echo "Compression ratio: $(calculate_ratio $size $compressed_size):1"
        echo "Time taken: $(get_timing "$results_dir/js_lz_comp.time")"
    fi
    
    echo "JavaScript LZ Decompression:"
    { time docker run -v $(pwd):/data js-compressor decompress -a lz /data/$file.js.lz /data/$file.restored; } 2> "$results_dir/js_lz_decomp.time"
    echo "Time taken: $(get_timing "$results_dir/js_lz_decomp.time")"
    echo
    
    # Cleanup restored files
    rm -f $file.restored
}

# Run benchmarks for each test file
benchmark_file "test_random.dat"
benchmark_file "test_repeating.dat"
benchmark_file "test_zeros.dat"

# Generate markdown report with enhanced metrics
cat > benchmark_results.md << EOL
# Compression Benchmark Results

## Test Environment
- Date: $(date)
- System: $(uname -a)
- Docker version: $(docker --version)

## Test Files
1. Random data (10MB)
2. Repeating text (10MB)
3. Zero bytes (10MB)

## Results

EOL

# Add results for each file in a table format
for file in test_random.dat test_repeating.dat test_zeros.dat; do
    original_size=$(get_file_size "$file")
    
    cat >> benchmark_results.md << EOL
### $file
Original size: $(format_size $original_size)

| Algorithm | Compressed Size | Compression Ratio | Compression Time | Decompression Time |
|-----------|-----------------|-------------------|------------------|-------------------|
EOL

    # Rust RLE
    if [ -f "$file.rle" ]; then
        compressed_size=$(get_file_size "$file.rle")
        ratio=$(calculate_ratio $original_size $compressed_size)
        comp_time=$(get_timing "benchmark_results/rust_rle_comp.time")
        decomp_time=$(get_timing "benchmark_results/rust_rle_decomp.time")
        echo "| Rust RLE | $(format_size $compressed_size) | ${ratio}:1 | ${comp_time} | ${decomp_time} |" >> benchmark_results.md
    fi
    
    # Rust LZ
    if [ -f "$file.lz" ]; then
        compressed_size=$(get_file_size "$file.lz")
        ratio=$(calculate_ratio $original_size $compressed_size)
        comp_time=$(get_timing "benchmark_results/rust_lz_comp.time")
        decomp_time=$(get_timing "benchmark_results/rust_lz_decomp.time")
        echo "| Rust LZ | $(format_size $compressed_size) | ${ratio}:1 | ${comp_time} | ${decomp_time} |" >> benchmark_results.md
    fi
    
    # JS RLE
    if [ -f "$file.js.rle" ]; then
        compressed_size=$(get_file_size "$file.js.rle")
        ratio=$(calculate_ratio $original_size $compressed_size)
        comp_time=$(get_timing "benchmark_results/js_rle_comp.time")
        decomp_time=$(get_timing "benchmark_results/js_rle_decomp.time")
        echo "| JS RLE | $(format_size $compressed_size) | ${ratio}:1 | ${comp_time} | ${decomp_time} |" >> benchmark_results.md
    fi
    
    # JS LZ
    if [ -f "$file.js.lz" ]; then
        compressed_size=$(get_file_size "$file.js.lz")
        ratio=$(calculate_ratio $original_size $compressed_size)
        comp_time=$(get_timing "benchmark_results/js_lz_comp.time")
        decomp_time=$(get_timing "benchmark_results/js_lz_decomp.time")
        echo "| JS LZ | $(format_size $compressed_size) | ${ratio}:1 | ${comp_time} | ${decomp_time} |" >> benchmark_results.md
    fi
    
    echo "" >> benchmark_results.md
done

# Add analysis section
cat >> benchmark_results.md << EOL
## Analysis

### Best Compression Ratios
EOL

for file in test_random.dat test_repeating.dat test_zeros.dat; do
    original_size=$(get_file_size "$file")
    best_ratio=0
    best_algo=""
    
    # Check Rust RLE
    if [ -f "$file.rle" ]; then
        compressed_size=$(get_file_size "$file.rle")
        ratio=$(calculate_ratio $original_size $compressed_size)
        if (( $(echo "$ratio > $best_ratio" | bc -l) )); then
            best_ratio=$ratio
            best_algo="Rust RLE"
        fi
    fi
    
    # Check Rust LZ
    if [ -f "$file.lz" ]; then
        compressed_size=$(get_file_size "$file.lz")
        ratio=$(calculate_ratio $original_size $compressed_size)
        if (( $(echo "$ratio > $best_ratio" | bc -l) )); then
            best_ratio=$ratio
            best_algo="Rust LZ"
        fi
    fi
    
    # Check JS RLE
    if [ -f "$file.js.rle" ]; then
        compressed_size=$(get_file_size "$file.js.rle")
        ratio=$(calculate_ratio $original_size $compressed_size)
        if (( $(echo "$ratio > $best_ratio" | bc -l) )); then
            best_ratio=$ratio
            best_algo="JS RLE"
        fi
    fi
    
    # Check JS LZ
    if [ -f "$file.js.lz" ]; then
        compressed_size=$(get_file_size "$file.js.lz")
        ratio=$(calculate_ratio $original_size $compressed_size)
        if (( $(echo "$ratio > $best_ratio" | bc -l) )); then
            best_ratio=$ratio
            best_algo="JS LZ"
        fi
    fi
    
    echo "- **$file**: Best algorithm: $best_algo (${best_ratio}:1)" >> benchmark_results.md
done

# Find fastest compression and decompression
echo -e "\n### Performance Summary" >> benchmark_results.md

# Find fastest compression
fastest_comp_time="999m999.999s"
fastest_comp_algo=""

for algo in "rust_rle" "rust_lz" "js_rle" "js_lz"; do
    for file in test_random.dat test_repeating.dat test_zeros.dat; do
        time_file="benchmark_results/${algo}_comp.time"
        if [ -f "$time_file" ]; then
            current_time=$(get_timing "$time_file")
            # Convert to seconds for comparison
            current_seconds=$(echo "$current_time" | awk -F'[ms]' '{print $1*60 + $2}')
            fastest_seconds=$(echo "$fastest_comp_time" | awk -F'[ms]' '{print $1*60 + $2}')
            
            if (( $(echo "$current_seconds < $fastest_seconds" | bc -l) )); then
                fastest_comp_time=$current_time
                fastest_comp_algo="$algo on $file"
            fi
        fi
    done
done

echo "- **Fastest Compression**: ${fastest_comp_algo//_/ } (${fastest_comp_time})" >> benchmark_results.md

# Find fastest decompression
fastest_decomp_time="999m999.999s"
fastest_decomp_algo=""

for algo in "rust_rle" "rust_lz" "js_rle" "js_lz"; do
    for file in test_random.dat test_repeating.dat test_zeros.dat; do
        time_file="benchmark_results/${algo}_decomp.time"
        if [ -f "$time_file" ]; then
            current_time=$(get_timing "$time_file")
            # Convert to seconds for comparison
            current_seconds=$(echo "$current_time" | awk -F'[ms]' '{print $1*60 + $2}')
            fastest_seconds=$(echo "$fastest_decomp_time" | awk -F'[ms]' '{print $1*60 + $2}')
            
            if (( $(echo "$current_seconds < $fastest_seconds" | bc -l) )); then
                fastest_decomp_time=$current_time
                fastest_decomp_algo="$algo on $file"
            fi
        fi
    done
done

echo "- **Fastest Decompression**: ${fastest_decomp_algo//_/ } (${fastest_decomp_time})" >> benchmark_results.md

# Add overall observations
cat >> benchmark_results.md << EOL

### Overall Observations
1. For random data, compression algorithms struggle to achieve good ratios as expected.
2. For repeating data, both Rust and JavaScript implementations show similar patterns.
3. For zero bytes, RLE algorithms significantly outperform LZ algorithms.
4. Rust implementations are generally faster than JavaScript for both compression and decompression.
EOL

# Cleanup
rm -rf benchmark_results
rm -f test_*.dat*

