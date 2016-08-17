//
//  PythonFileUtils.m
//  MNIST-BNNS
//
//  Created by Aaron Hillegass on 8/17/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "PythonFileUtils.h"

// Returns YES if target is found before the end of the file
BOOL consumePast(FILE *f, char target)
{
    int i = 1;
    while (!feof(f)) {
        char c = fgetc(f);
        if (c == target) {
            return YES;
        }
        i++;
    }
    return NO;
}

// Returns bytes consumed
BOOL readPythonFloatArray(FILE *file, float *buffer, int n)
{
    BOOL success = consumePast(file, '[');
    if (!success) {
        return NO;
    }
    for (int i = 0; i < n; i++) {
        float inFloat;
        int scanned = fscanf(file, "%f", &inFloat);
        if (scanned < 1) {
            fprintf(stderr, "Parse error: Not a floating point number in %d\n", i);
            return NO;
        }
        buffer[i] = inFloat;
        if (i < n-1) {
            consumePast(file, ',');
        }
    }
    consumePast(file, ']');
    return YES;
}

float *createFloatArrayFromPythonFile(NSString *filePath, int n)
{
    FILE *inFile = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (!inFile) {
        return NULL;
    }
    
    float *buffer = (float *)malloc(n * sizeof(float));

    BOOL success = readPythonFloatArray(inFile, buffer, n);
    fclose(inFile);
    
    if (!success) {
        free(buffer);
        return NULL;
    }
    return buffer;
}

// Creates an m-array of a n-float arrays
// Return NULL if anything goes wrong
float ** createFloatMatrixFromPytonFile(NSString *filePath, int n, int m)
{
    FILE *inFile = fopen([filePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (!inFile) {
        return NULL;
    }
    
    BOOL success = consumePast(inFile, '[');
    if (!success) {
        return NO;
    }
    
    float **buffer = (float **)malloc(m * sizeof(float *));
    
    for (int i = 0; i < m; i++) {
        float *subbuffer = (float *)malloc(n * sizeof(float));
        BOOL success = readPythonFloatArray(inFile, subbuffer, n);
        if (!success) {
            fprintf(stderr, "Failed to read subarray %d\n", i);
            // FIXME: should free created subarrays
            free(buffer);
            return NO;
        }
        buffer[i] = subbuffer;
        if (i < m-1) {
            consumePast(inFile, ',');
        }
    }
    
    fclose(inFile);
    
    return buffer;

}