//
//  PixelView.m
//  MNIST
//
//  Created by Aaron Hillegass on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "PixelView.h"

@implementation PixelView


- (void)copyBuffer:(unsigned char *)d
{
    int bytes = self.width * self.height * sizeof(unsigned char);
    if (!data) {
        data = malloc(bytes);
    }
    memcpy(data, d, bytes);
    [self setNeedsDisplay:YES];
}

- (void)dealloc
{
    free(data);
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    // Turn off anti-aliasing
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setShouldAntialias:NO];
    
    
    // Fill the bounds with white
    NSRect bounds = [self bounds];
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:bounds];
    
    // Step through the pixels, drawing non-white ones at rectangles
    NSRect blockToPaint;
    blockToPaint.size.width = bounds.size.width / self.width;
    blockToPaint.size.height = bounds.size.height / self.height;
    
    for (int vStep = 0; vStep < self.height; vStep++) {
        for (int hStep = 0; hStep < self.width; hStep++) {
            unsigned char dataForPixel = data[vStep * self.width + hStep];
            
            // Is it non-white?
            if (dataForPixel != 0) {
                
                // What color?
                float inkness = dataForPixel/255.0;
                float whiteness = 1.0 - inkness;
                NSColor *c = [NSColor colorWithWhite:whiteness
                                               alpha:1.0];
                [c setFill];
                
                // Where?
                blockToPaint.origin.y = bounds.origin.y + blockToPaint.size.height * vStep;
                blockToPaint.origin.x = bounds.origin.x + blockToPaint.size.width * hStep;

                // Draw it
                [NSBezierPath fillRect:blockToPaint];
            }
        }
    }
    
    // Draw a nice crisp border
    [NSBezierPath setDefaultLineWidth:1.0];
    [[NSColor darkGrayColor] setStroke];
    [NSBezierPath strokeRect:NSInsetRect(bounds, 1, 1)];

    // Turn anti-aliasing back on
    [NSGraphicsContext restoreGraphicsState];
}

@end
