//
//  PyDumpParser.h
//  MNIST-BNNS
//
//  Created by Aaron Hillegass on 9/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MAX_DIGITS (128)
#define MAX_DEPTH (128)
#define READING_NUMBER (1)
#define NOT_READING_NUMBER (0)

@protocol PyDumpParserDelegate;

@interface PyDumpParser : NSObject
{
    FILE *fileHandle;
    char numberBuffer[MAX_DIGITS];
    NSUInteger numberLength;
    NSUInteger indices[MAX_DEPTH];
    int depth;
    int state;
}

@property (weak) id<PyDumpParserDelegate> delegate;
@property (readonly) NSString *filename;

- (instancetype)initWithFilename:(NSString *)filename;
- (BOOL)parse:(NSError **)err;

@end

@protocol PyDumpParserDelegate <NSObject>

- (void)parserBeginArray:(PyDumpParser *)sender;
- (void)parserEndArray:(PyDumpParser *)sender;
- (void)parser:(PyDumpParser *)sender
   foundDouble:(double)d
   atIndexPath:(NSIndexPath *)idxPath;

@end