const WINDOW_SIZE: usize = 20;
const MIN_MATCH_LENGTH: usize = 3;

pub fn compress(data: &[u8]) -> Vec<u8> {
    let mut compressed = Vec::new();
    let mut pos = 0;

    while pos < data.len() {
        let window_start = pos.saturating_sub(WINDOW_SIZE);
        let mut best_length = 0;
        let mut best_offset = 0;

        // Look for matches in the sliding window
        for i in window_start..pos {
            let mut length = 0;
            while pos + length < data.len() 
                && length < 255 
                && i + length < pos 
                && data[i + length] == data[pos + length] {
                length += 1;
            }

            if length >= MIN_MATCH_LENGTH && length > best_length {
                best_length = length;
                best_offset = pos - i;
            }
        }

        if best_length >= MIN_MATCH_LENGTH {
            compressed.push(0x01); // Match marker
            compressed.push(best_offset as u8);
            compressed.push(best_length as u8);
            pos += best_length;
        } else {
            compressed.push(0x00); // Literal marker
            compressed.push(data[pos]);
            pos += 1;
        }
    }

    compressed
}

pub fn decompress(data: &[u8]) -> Vec<u8> {
    let mut decompressed = Vec::new();
    let mut i = 0;

    while i < data.len() {
        match data[i] {
            0x00 => {
                // Literal
                decompressed.push(data[i + 1]);
                i += 2;
            }
            0x01 => {
                // Match
                let offset = data[i + 1] as usize;
                let length = data[i + 2] as usize;
                let start = decompressed.len() - offset;
                for j in 0..length {
                    decompressed.push(decompressed[start + j]);
                }
                i += 3;
            }
            _ => panic!("Invalid compression marker"),
        }
    }

    decompressed
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_lz_roundtrip() {
        let input = b"ABABABABABAB";
        let compressed = compress(input);
        let decompressed = decompress(&compressed);
        assert_eq!(input.to_vec(), decompressed);
    }
}
