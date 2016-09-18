//
//  SoftMax.c
//  MNIST-BNNS
//
//  Created by Administrator on 9/1/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#include "softmax.h"
#include <math.h>

void softmax(const float *in, float *out, int size)
{
    // Temporary buffer
    float ebuffer[size];
    
    // Sum of exponentials
    float esum = 0;
    
    // Step through the in array, take the exponential of it.
    // Put it in 'ebuffer' and keep a running sum
    for (int i = 0; i < size; i++) {
        float ed = expf(in[i]);
        esum += ed;
        ebuffer[i] = ed;
    }
    
    // The output is the exponentials scaled so they
    // sum to 1.0
    for (int i = 0; i < size; i++) {
        out[i] = ebuffer[i]/esum;
    }
    
}
