//
//  PyDumpParser.m
//  MNIST-BNNS
//
//  Created by Aaron Hillegass on 9/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "PyDumpParser.h"
#include <ctype.h>

@implementation PyDumpParser

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    _filename = filename;
    
    // After the first [, the depth will be 0.
    depth = -1;
    
    // Number of characters scanned into 'numberBuffer'
    numberLength = 0;
    return self;

}

// Converts the buffer to a double and sends it to the
// delegate. Also resets 'numberLength' for next number
- (void)sendNumber
{
    if (numberLength == 0) {
        NSLog(@"Odd...a zero-length number?");
        return;
    }
    numberBuffer[numberLength] = '\0';
    double result = atof(numberBuffer);
    numberLength = 0;
    NSIndexPath *ip = [NSIndexPath indexPathWithIndexes:indices
                                                 length:depth + 1];
    [self.delegate parser:self
              foundDouble:result
              atIndexPath:ip];
}

- (BOOL)parse:(NSError **)err
{
    // Using ANSI standard file I/O
    fileHandle = fopen([self.filename cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (!fileHandle) {
        if (err) {
            *err = [NSError errorWithDomain:NSPOSIXErrorDomain
                                       code:errno
                                   userInfo:@{NSLocalizedDescriptionKey: @"Unable to open file"}];
        }
        return NO;
    }
    
    // Read every character in the file
    while (!feof(fileHandle)) {
        char c = fgetc(fileHandle);
        
        // Is it the start of a new array?
        if (c == '[') {
            depth++;
            indices[depth] = 0;
            [self.delegate parserBeginArray:self];
            continue;
        }
        
        // Is it the close of the old array?
        if (c == ']') {
            if (state == READING_NUMBER) {
                [self sendNumber];
                state = NOT_READING_NUMBER;
            }
            depth--;
            [self.delegate parserEndArray:self];
            continue;
        }
        
        // The comma is a separator of numbers and arrays
        if (c == ',') {
            if (state == READING_NUMBER) {
                [self sendNumber];
                state = NOT_READING_NUMBER;
            }
            indices[depth] = indices[depth] + 1;
            continue;
        }
        
        // Who cares about whitespace?
        if (isspace(c)) {
            continue;
        }
        
        // The character must be part of a number
        // (a digit, a decimal, a dash)
        state = READING_NUMBER;
        numberBuffer[numberLength] = c;
        numberLength++;
    }
    
    fclose(fileHandle);
    return YES;
}



@end
