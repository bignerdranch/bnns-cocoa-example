//
//  PyDumpParser.h
//  MNIST-BNNS
//
//  Created by Aaron Hillegass on 9/18/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//
// This is a pretty lax parser -- I should put in more checks for correctness.

#import <Foundation/Foundation.h>

@protocol PyDumpParserDelegate;


@interface PyDumpParser : NSObject

@property (weak) id<PyDumpParserDelegate> delegate;

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
