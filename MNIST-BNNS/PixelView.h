//
//  PixelView.h
//  MNIST
//
//  Created by Aaron Hillegass on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PixelView : NSView
{
    unsigned char *data;
}

@property (nonatomic) int width;
@property (nonatomic) int height;

- (void)copyBuffer:(unsigned char *)d;

@end
