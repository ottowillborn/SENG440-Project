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

int main() {
    FILE *fin = fopen("audio_sample.wav", "rb");
    FILE *fout = fopen("compressed_output.ulaw", "wb");
    FILE *frec = fopen("decompressed.pcm", "wb");
    if (!fin || !fout || !frec) { perror("File error"); return 1; }

    fseek(fin, 44, SEEK_SET); // Skip WAV header

    clock_t start = clock();  // Start timer

    int16_t sample;
    while (fread(&sample, sizeof sample, 1, fin) == 1) {
        uint8_t compressed = ulaw_compress(sample);
        fwrite(&compressed, sizeof compressed, 1, fout);

        int16_t restored = ulaw_decompress(compressed);
        fwrite(&restored, sizeof restored, 1, frec);
    }

    clock_t end = clock();    // End timer
    double elapsed_secs = (double)(end - start) / CLOCKS_PER_SEC;

    fclose(fin); fclose(fout); fclose(frec);

    printf("Done compressing and decompressing\n");
    printf("Elapsed time: %.6f seconds\n", elapsed_secs);
    return 0;
}