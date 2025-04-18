
pub fn compress(data: &[u8]) -> Vec<u8> {
    let mut compressed = Vec::new();
    let mut count = 1;
    let mut current = data[0];

    for &byte in &data[1..] {
        if byte == current && count < 255 {
            count += 1;
        } else {
            compressed.push(current);
            compressed.push(count);
            current = byte;
            count = 1;
        }
    }
    
    compressed.push(current);
    compressed.push(count);
    compressed
}

pub fn decompress(data: &[u8]) -> Vec<u8> {
    let mut decompressed = Vec::new();
    let mut i = 0;

    while i < data.len() {
        let byte = data[i];
        let count = data[i + 1] as usize;
        decompressed.extend(vec![byte; count]);
        i += 2;
    }

    decompressed
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_rle_roundtrip() {
        let input = b"AAABBBCCCCCDDDDE";
        let compressed = compress(input);
        let decompressed = decompress(&compressed);
        assert_eq!(input.to_vec(), decompressed);
    }
}
