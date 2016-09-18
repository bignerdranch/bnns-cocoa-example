//
//  softmax.h
//  MNIST-BNNS
//
//  Created by Administrator on 9/1/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#ifndef softmax_h
#define softmax_h

// Here is a function that comes with TensorFlow, but doesn't exist in BNNS.
// I had to implement it myself. :(

extern void softmax(const float *in, float *out, int size);

#endif /* softmax_h */
