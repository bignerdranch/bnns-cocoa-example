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
    depth = -1;
    numberLength = 0;
    return self;

}

- (void)sendNumber
{
    if (numberLength == 0) {
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
    fileHandle = fopen([self.filename cStringUsingEncoding:NSUTF8StringEncoding], "r");
    if (!fileHandle) {
        if (err) {
            *err = [NSError errorWithDomain:NSPOSIXErrorDomain
                                       code:errno
                                   userInfo:@{NSLocalizedDescriptionKey: @"Unable to open file"}];
        }
        return NO;
    }
    
    while (!feof(fileHandle)) {
        char c = fgetc(fileHandle);
        
        if (c == '[') {
            depth++;
            indices[depth] = 0;
            [self.delegate parserBeginArray:self];
            continue;
        }
        
        if (c == ']') {
            if (state == READING_NUMBER) {
                [self sendNumber];
                state = NOT_READING_NUMBER;
            }
            depth--;
            [self.delegate parserEndArray:self];
            continue;
        }
        
        if (c == ',') {
            if (state == READING_NUMBER) {
                [self sendNumber];
                state = NOT_READING_NUMBER;
            }
            indices[depth] = indices[depth] + 1;
            continue;
        }
        
        if (isspace(c)) {
            continue;
        }
        
        // Must be part of a number
        state = READING_NUMBER;
        numberBuffer[numberLength] = c;
        numberLength++;
    }
    
    fclose(fileHandle);
    return YES;
}



@end
