//
//  MNISTDataSet.m
//  MNIST
//
//  Created by Aaron Hillegass on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "MNISTDataSet.h"

@implementation MNISTDataSet

- (void)readLabels
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"t10k-labels-idx1-ubyte"
                                                          ofType:nil];
    FILE *imageFile = fopen([imagePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    uint32_t readInt;
    
    // Read magic number
    fread(&readInt, sizeof(int32_t), 1, imageFile);
    
    // Read number of images
    fread(&readInt, sizeof(int32_t), 1, imageFile);
    _imageCount = CFSwapInt32(readInt);
    
    // Read the labels
    labels = malloc(sizeof(unsigned char) * _imageCount);
    fread(labels, sizeof(unsigned char), _imageCount, imageFile);
}


- (void)finalize
{
    free(labels);
    for (int i = 0; i < self.imageCount; i++ ){
        free(images[i]);
    }
    free(images);
}

- (void)readImages {
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"t10k-images-idx3-ubyte"
                                                          ofType:nil];
    FILE *imageFile = fopen([imagePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
    uint32_t readInt;
    
    // Read magic number
    fread(&readInt, sizeof(int32_t), 1, imageFile);
    
    // Read number of images
    fread(&readInt, sizeof(int32_t), 1, imageFile);
    _imageCount = CFSwapInt32(readInt);
    
    // Read number of rows
    fread(&readInt, sizeof(int32_t), 1, imageFile);
    _rows = CFSwapInt32(readInt);

    // Read number of columns
    fread(&readInt, sizeof(int32_t), 1, imageFile);
    _columns = CFSwapInt32(readInt);

    images = malloc(sizeof(void *) * _imageCount);

    // Read each of the images
    for (int i = 0; i < _imageCount; i++ ){
        unsigned int pixelCount = self.rows * self.columns;
        unsigned char * newImage = malloc(pixelCount * sizeof(unsigned char));
        fread(newImage, sizeof(unsigned char), pixelCount, imageFile);
        images[i] = newImage;
    }
}

- (instancetype)init
{
    self = [super init];
    [self readLabels];
    [self readImages];
    return self;
}

- (unsigned char)labelForIndex:(unsigned int)k
{
    return labels[k];
}

- (unsigned char *)imageDataForIndex:(unsigned int)k
{
    return images[k];
}

@end
