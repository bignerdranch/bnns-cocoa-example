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
#import "PythonFileUtils.h"

#define BIASES_COUNT (10)
#define WEIGHTS_COUNT (784)

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
    
    NSString *biasesPath = [[NSBundle mainBundle] pathForResource:@"biases"
                                                           ofType:@"data"];
    biases = createFloatArrayFromPythonFile(biasesPath, BIASES_COUNT);
   
    // Logging just for fun
    fprintf(stderr, "biases = ");
    for (int i = 0; i < BIASES_COUNT; i++ ) {
        fprintf(stderr, "%f,", biases[i]);
    }
    fprintf(stderr, "\n");
    
    
    NSString *weightsPath = [[NSBundle mainBundle] pathForResource:@"weights"
                                                           ofType:@"data"];
    
    weights = createFloatMatrixFromPytonFile(weightsPath, BIASES_COUNT, WEIGHTS_COUNT);
    
    // Logging just for fun
    fprintf(stderr, "weights = ");
    for (int i = 0; i < WEIGHTS_COUNT; i++ ) {
        float *subArray = weights[i];
        fprintf(stderr, "[");
        for (int j = 0; j < BIASES_COUNT; j++) {
            fprintf(stderr, "%f,", subArray[j]);
        }
        fprintf(stderr, "]\n");
    }
    fprintf(stderr, "\n");

    // FIXME: Bolot, create the BNNS network here and load it with the floats read above
    // Do I need to implement softmax myself?
}


- (void)getGuesses:(float *)guesses
          forImage:(const unsigned char *)im
{
    int pixelCount = dataSet.columns * dataSet.rows;
    
    // FIXME: Bolot, feed the image in and get the result

    for (int i = 0; i < 10; i++) {
        guesses[i] = 0.5;
    }
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
