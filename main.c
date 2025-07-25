#include <stdio.h>
#include <stdint.h>
#include <time.h>  // Include for timing

#define BIAS 33

// µ-law compression
uint8_t ulaw_compress(int16_t sample) {
    uint8_t sign;
    uint16_t magnitude;
    uint8_t chord, step;
    uint8_t codeword;

    sign = (sample < 0) ? 0 : 1;
    magnitude = (sample < 0) ? -sample : sample;
    magnitude += BIAS;

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

