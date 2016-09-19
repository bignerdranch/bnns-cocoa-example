//
//  AppDelegate.m
//  MNIST
//
//  Created by Aaron Hillegass on 7/7/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "AppDelegate.h"
#import "PixelView.h"
#import "MNISTDataSet.h"
#import "softmax.h"
#import "WeightReader.h"

#define OUT_COUNT (10)
#define IN_COUNT (784)

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet PixelView *pixelView;
@property (weak) IBOutlet NSButton *previousButton;
@property (weak) IBOutlet NSButton *nextButton;
@property (weak) IBOutlet NSTextField *infoField;
@end


@implementation AppDelegate

- (instancetype)init
{
    self = [super init];
    dataSet = [[MNISTDataSet alloc] init];
    [self createModel];
    return self;
}

- (void)createModel
{
    // The input layer has 784 nodes that will be fed floats
    BNNSVectorDescriptor inVectorDescriptor = { .data_type = BNNSDataTypeFloat32, .size = IN_COUNT };
    
    // The output layer has 10 nodes that will yield floats
    BNNSVectorDescriptor outVectorDescriptor = {.data_type = BNNSDataTypeFloat32, .size = OUT_COUNT};

    // The input and output layers are fully connected
    BNNSFullyConnectedLayerParameters parameters = { .in_size = IN_COUNT, .out_size = OUT_COUNT };
    
    
    // Read in the weights
    NSString *weightsPath = [[NSBundle mainBundle] pathForResource:@"weights"
                                                            ofType:@"data"];

    float *weightVector = (float *)malloc(sizeof(float) * IN_COUNT * OUT_COUNT);
    NSError *error;
    BOOL success = [WeightReader fillArray:weightVector
                              fromFilename:weightsPath
                               outerLength:IN_COUNT
                               innerLength:OUT_COUNT
                                  reverse:YES
                                     error:&error];
    
    if (!success) {
        NSLog(@"failed to read weights: %@", error);
    }
    
    parameters.weights.data = weightVector;
    parameters.weights.data_type = BNNSDataTypeFloat32;

    // Read in the biases
    NSString *biasesPath = [[NSBundle mainBundle] pathForResource:@"biases"
                                                           ofType:@"data"];

    float *biasVector = (float *)malloc(sizeof(float) * OUT_COUNT);
    success = [WeightReader fillArray:biasVector
                         fromFilename:biasesPath
                               length:OUT_COUNT
                                error:&error];

    
    if (!success) {
        NSLog(@"failed to read weights: %@", error);
    }

    parameters.bias.data = biasVector;
    parameters.bias.data_type = BNNSDataTypeFloat32;
    
    // TensorFlow has the trivial activation function (before it is softmax'ed)
    parameters.activation.function = BNNSActivationFunctionIdentity;
    
    // Create the filter
    filter = BNNSFilterCreateFullyConnectedLayer(&inVectorDescriptor,
                                                 &outVectorDescriptor,
                                                 &parameters,NULL);

    if (!filter) {
        NSLog(@"BNNSFilterCreateFullyConnectedLayer failed");
    }

}


- (void)getGuesses:(float *)guesses
          forImage:(const unsigned char *)im
{
    float buffer[IN_COUNT];
    
    // Convert intput to floats
    for (int i = 0; i < IN_COUNT; i++ ){
        buffer[i] = im[i] / 255.0;
    }
    float output[OUT_COUNT];
    
    // Run the data through the net
    int success = BNNSFilterApply(filter, buffer, output);
    if (success != 0) {
        NSLog(@"FilterApply failed!");
    }

    // Apply a softmax function
    softmax(output, guesses, OUT_COUNT);
    
}

- (void)showSelectedImage
{
    // Enable/disable previous button
    [self.previousButton setEnabled:(selectedImage != 0)];
    
    // Enable/disable next button
    unsigned imageCount = dataSet.imageCount;
    [self.nextButton setEnabled:(selectedImage != imageCount - 1)];
    
    // Which image?
    unsigned char *image = [dataSet imageDataForIndex:selectedImage];
    
    // Show it
    [self.pixelView copyBuffer:image];
    
    // Use tensorflow to get guesses
    float guesses[10];
    [self getGuesses:guesses
            forImage:image];
    
    // Put info in a string
    unsigned char label = [dataSet labelForIndex:selectedImage];
    NSMutableString *infoString = [NSMutableString stringWithFormat:@"Image %d is %d.\nGuesses: ", selectedImage, label];

    // Step through the guesses, appending significant ones
    BOOL writtenFirstGuess = NO;
    for (int i = 0; i < 10; i++ ) {
        
        // Is it more than noise?
        if (guesses[i] > 0.007) {
            
            // Comma separate the guesses
            if (writtenFirstGuess) {
                [infoString appendString:@", "];
            } else {
                writtenFirstGuess = YES;
            }
            
            // Put it in the string
            [infoString appendFormat:@"%d=%.0f%%", i, guesses[i] * 100.0];
        }
    }

    // Display the string
    [self.infoField setStringValue:infoString];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self.pixelView setWidth:dataSet.columns];
    [self.pixelView setHeight:dataSet.rows];
    [self showSelectedImage];
}

- (IBAction)showNext:(id)sender
{
    if (selectedImage < dataSet.imageCount - 1) {
        selectedImage++;
    }
    [self showSelectedImage];
}

- (IBAction)showPrevious:(id)sender
{
    if (selectedImage > 0) {
        selectedImage--;
    }
    [self showSelectedImage];
}

@end
