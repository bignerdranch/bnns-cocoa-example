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
    float ebuffer[size];
    float esum = 0;
    for (int i = 0; i < size; i++) {
        float ed = expf(in[i]);
        esum += ed;
        ebuffer[i] = ed;
    }
    for (int i = 0; i < size; i++) {
        out[i] = ebuffer[i]/esum;
    }
    
}
