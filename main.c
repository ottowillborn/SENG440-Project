#include <stdio.h>
#include <stdint.h>
#include <time.h>  // Include for timing
#define BIAS 33

uint8_t compress_lut[65536]; // Input range: [-32768, 32767]
int16_t decompress_lut[256]; // All 256 possible µ-law codes

// Precompute chord and step manually
void init_ulaw_luts() {
    for (int i = -32768; i <= 32767; ++i) {
        int16_t sample = (int16_t)i;
        uint8_t sign = (sample < 0) ? 0 : 1;
        uint16_t magnitude = (sample < 0) ? -sample : sample;
        magnitude += BIAS;

        uint8_t chord, step;

        if (magnitude & (1 << 12)) {
            chord = 7;
            step  = (magnitude >> 8) & 0x0F;
        } else if (magnitude & (1 << 11)) {
            chord = 6;
            step  = (magnitude >> 7) & 0x0F;
        } else if (magnitude & (1 << 10)) {
            chord = 5;
            step  = (magnitude >> 6) & 0x0F;
        } else if (magnitude & (1 << 9)) {
            chord = 4;
            step  = (magnitude >> 5) & 0x0F;
        } else if (magnitude & (1 << 8)) {
            chord = 3;
            step  = (magnitude >> 4) & 0x0F;
        } else if (magnitude & (1 << 7)) {
            chord = 2;
            step  = (magnitude >> 3) & 0x0F;
        } else if (magnitude & (1 << 6)) {
            chord = 1;
            step  = (magnitude >> 2) & 0x0F;
        } else {
            chord = 0;
            step  = (magnitude >> 1) & 0x0F;
        }

        uint8_t codeword = (sign << 7) | (chord << 4) | step;
        compress_lut[i + 32768] = ~codeword;
    }

    for (int i = 0; i < 256; ++i) {
        uint8_t ulaw_byte = ~i;
        uint8_t sign   = (ulaw_byte >> 7) & 0x01;
        uint8_t chord  = (ulaw_byte >> 4) & 0x07;
        uint8_t step   = ulaw_byte & 0x0F;
        uint16_t magnitude = ((0x10 | step) << (chord + 3)) - BIAS;
        decompress_lut[i] = sign ? magnitude : -magnitude;
    }
}


int main() {
    FILE *fin = fopen("audio_sample.wav", "rb");
    FILE *fout = fopen("compressed_output.ulaw", "wb");
    FILE *frec = fopen("decompressed.pcm", "wb");
    if (!fin || !fout || !frec) { perror("File error"); return 1; }
    
    fseek(fin, 44, SEEK_SET); // Skip WAV header

    clock_t start = clock();  // Start timer
    init_ulaw_luts(); // Precompute all mappings
    int16_t sample;
    while (fread(&sample, sizeof sample, 1, fin) == 1) {
        uint8_t compressed = compress_lut[(uint16_t)(sample + 32768)];
        fwrite(&compressed, sizeof compressed, 1, fout);

        int16_t restored = decompress_lut[compressed];
        fwrite(&restored, sizeof restored, 1, frec);
    }

    clock_t end = clock();    // End timer
    double elapsed_secs = (double)(end - start) / CLOCKS_PER_SEC;

    fclose(fin); fclose(fout); fclose(frec);

    printf("Done compressing and decompressing\n");
    printf("Elapsed time: %.6f seconds\n", elapsed_secs);
    return 0;
}

