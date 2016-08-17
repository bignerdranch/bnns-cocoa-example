//
//  PythonFileUtils.h
//  MNIST-BNNS
//
//  Created by Aaron Hillegass on 8/17/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

// Creates a float array containing 'n' floats read from a python list
// Returns NULL if anything goes wrong
extern float * createFloatArrayFromPythonFile(NSString *filePath, int n);

// Creates an m-array of a n-float arrays
// Return NULL if anything goes wrong
extern float ** createFloatMatrixFromPytonFile(NSString *filePath, int n, int m);