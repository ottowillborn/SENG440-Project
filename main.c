#include <stdio.h>
#include <stdint.h>
#include <time.h>  // Include for timing

#define BIAS 33

uint8_t ulaw_compress(int16_t sample) {
    uint8_t sign;
    uint16_t magnitude;
    uint8_t chord, step;
    uint8_t codeword;

    sign = (sample < 0) ? 0 : 1;
    magnitude = (sample < 0) ? -sample : sample;
    magnitude += BIAS;

    // Find the highest set bit position (0..15)
    int highest_bit = 31 - __builtin_clz((uint32_t)magnitude);

    // Chord is based on bits 6–12, so offset by 5
    chord = (highest_bit >= 6) ? (highest_bit - 5) : 0;

    // Step is the next 4 bits below the chord bit
    step = (magnitude >> (chord + 3)) & 0x0F;
    

    codeword = (sign << 7) | (chord << 4) | step;
    return ~codeword;
}


// µ-law decompression
int16_t ulaw_decompress(uint8_t ulaw_byte) {
    ulaw_byte = ~ulaw_byte;

    uint8_t sign   = (ulaw_byte >> 7) & 0x01;
    uint8_t chord  = (ulaw_byte >> 4) & 0x07;
    uint8_t step   = ulaw_byte & 0x0F;

    uint16_t magnitude = ((0x10 | step) << (chord + 3)) - BIAS;
    return sign ? magnitude : -magnitude;
}


#define BLOCK_SIZE 4096

int main() {
    FILE *fin = fopen("audio_sample.wav", "rb");
    FILE *fout = fopen("compressed_output.ulaw", "wb");
    FILE *frec = fopen("decompressed.pcm", "wb");
    if (!fin || !fout || !frec) { perror("File error"); return 1; }

    fseek(fin, 44, SEEK_SET); // Skip WAV header

    int16_t in_buffer[BLOCK_SIZE];
    uint8_t compressed_buffer[BLOCK_SIZE];
    int16_t out_buffer[BLOCK_SIZE];

    clock_t start = clock();  // Start timer

    size_t read_count;
    while ((read_count = fread(in_buffer, sizeof(int16_t), BLOCK_SIZE, fin)) > 0) {
        for (size_t i = 0; i < read_count; ++i) {
            compressed_buffer[i] = ulaw_compress(in_buffer[i]);
            out_buffer[i] = ulaw_decompress(compressed_buffer[i]);
        }
        fwrite(compressed_buffer, sizeof(uint8_t), read_count, fout);
        fwrite(out_buffer, sizeof(int16_t), read_count, frec);
    }

    clock_t end = clock();  // End timer

    fclose(fin); fclose(fout); fclose(frec);

    double elapsed_secs = (double)(end - start) / CLOCKS_PER_SEC;
    printf("Done compressing and decompressing\n");
    printf("Elapsed time: %.6f seconds\n", elapsed_secs);

    return 0;
}