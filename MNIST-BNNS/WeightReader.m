//
//  WeightReader.m
//  MNIST-BNNS
//
//  Created by Aaron Hillegass on 9/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "WeightReader.h"

@implementation WeightReader


// Read a 2-dimensional array into weightVector
// The outer array should have 'outerLen' arrays
// The inner arrays should each contain 'innerLen' floats
// weightVector must be big enough to hold outerLen * innerLen floats
+ (BOOL)fillArray:(float *)weightVector
     fromFilename:(NSString *)weightsPath
      outerLength:(int)outerLen
      innerLength:(int)innerLen
          reverse:(BOOL)isReversed
            error:(NSError **)err
{
    WeightReader *wr = [[WeightReader alloc] init];
    wr.arrayToFill = weightVector;
    wr.outerLen = outerLen;
    wr.innerLen = innerLen;
    wr.isReversed = isReversed;
    
    PyDumpParser *parser = [[PyDumpParser alloc] initWithFilename:weightsPath];
    parser.delegate = wr;
    BOOL success = [parser parse:err];
    return success;
}

// Read a 1-dimensional array into weightVector
// The array should contain len' floats
// weightVector must be big enough to hold outerLen * innerLen floats
+ (BOOL)fillArray:(float *)weightVector
     fromFilename:(NSString *)weightsPath
           length:(int)len
            error:(NSError **)err

{
    WeightReader *wr = [[WeightReader alloc] init];
    wr.arrayToFill = weightVector;
    wr.outerLen = len;
    wr.innerLen = 0;
    
    PyDumpParser *parser = [[PyDumpParser alloc] initWithFilename:weightsPath];
    parser.delegate = wr;
    BOOL success = [parser parse:err];
    return success;
}

- (void)parserBeginArray:(PyDumpParser *)sender
{
    // No op
}
- (void)parserEndArray:(PyDumpParser *)sender
{
    // No op
}
- (void)parser:(PyDumpParser *)sender
   foundDouble:(double)d
   atIndexPath:(NSIndexPath *)idxPath
{
    // Is this one-dimension?
    if (self.innerLen == 0) {
        NSUInteger i = [idxPath indexAtPosition:0];
        //fprintf(stderr, "Bias: {%lu} = %f\n", (unsigned long)i, d);
        self.arrayToFill[i] = (float)d;
    } else { // Must be two-dimensional
        NSUInteger outerIndex = [idxPath indexAtPosition:0];
        NSUInteger innerIndex = [idxPath indexAtPosition:1];
        //fprintf(stderr, "Weight: {%lu,%lu} = %f\n", (unsigned long)outerIndex, (unsigned long)innerIndex, d);
        NSUInteger i;
        if (self.isReversed) {
            i = innerIndex * self.outerLen + outerIndex;
        } else {
            i = outerIndex * self.innerLen + innerIndex;
        }
        self.arrayToFill[i] = d;
    }
}

@end
