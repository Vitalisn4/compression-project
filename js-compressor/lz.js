const WINDOW_SIZE = 20;
const MIN_MATCH_LENGTH = 3;

export function compress(data) {
  const result = [];
  let pos = 0;

  while (pos < data.length) {
    const windowStart = Math.max(0, pos - WINDOW_SIZE);
    let bestLength = 0;
    let bestOffset = 0;

    // Look for matches in the sliding window
    for (let i = windowStart; i < pos; i++) {
      let length = 0;
      while (pos + length < data.length 
             && length < 255 
             && i + length < pos 
             && data[i + length] === data[pos + length]) {
        length++;
      }

      if (length >= MIN_MATCH_LENGTH && length > bestLength) {
        bestLength = length;
        bestOffset = pos - i;
      }
    }

    if (bestLength >= MIN_MATCH_LENGTH) {
      result.push(0x01); // Match marker
      result.push(bestOffset);
      result.push(bestLength);
      pos += bestLength;
    } else {
      result.push(0x00); // Literal marker
      result.push(data[pos]);
      pos++;
    }
  }

  return Buffer.from(result);
}

export function decompress(data) {
  const result = [];
  let i = 0;

  while (i < data.length) {
    if (data[i] === 0x00) {
      // Literal
      result.push(data[i + 1]);
      i += 2;
    } else if (data[i] === 0x01) {
      // Match
      const offset = data[i + 1];
      const length = data[i + 2];
      const start = result.length - offset;
      for (let j = 0; j < length; j++) {
        result.push(result[start + j]);
      }
      i += 3;
    } else {
      throw new Error('Invalid compression marker');
    }
  }

  return Buffer.from(result);
}
