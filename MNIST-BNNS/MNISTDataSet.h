//
//  MNISTDataSet.h
//  MNIST
//
//  Created by Aaron Hillegass on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MNISTDataSet : NSObject
{    
    unsigned char **images;
    unsigned char *labels;
}

@property (readonly) unsigned int rows;
@property (readonly) unsigned int columns;
@property (readonly) unsigned int imageCount;
- (unsigned char)labelForIndex:(unsigned int)k;
- (unsigned char *)imageDataForIndex:(unsigned int)k;

@end
