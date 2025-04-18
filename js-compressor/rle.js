export function compress(data) {
  const result = [];
  let count = 1;
  let current = data[0];

  // Enhanced RLE compression with better run detection
  for (let i = 1; i < data.length; i++) {
    if (data[i] === current && count < 255) {
      count++;
    } else {
      // Only store run if it's efficient (count > 2)
      if (count > 2) {
        result.push(0xFF); // Run marker
        result.push(current);
        result.push(count);
      } else {
        // Store as literals
        for (let j = 0; j < count; j++) {
          result.push(current);
        }
      }
      current = data[i];
      count = 1;
    }
  }

  // Handle the last run
  if (count > 2) {
    result.push(0xFF);
    result.push(current);
    result.push(count);
  } else {
    for (let j = 0; j < count; j++) {
      result.push(current);
    }
  }

  return Buffer.from(result);
}

export function decompress(data) {
  const result = [];
  let i = 0;
  
  while (i < data.length) {
    if (data[i] === 0xFF) {
      const byte = data[i + 1];
      const count = data[i + 2];
      result.push(...Array(count).fill(byte));
      i += 3;
    } else {
      result.push(data[i]);
      i++;
    }
  }

  return Buffer.from(result);
}
