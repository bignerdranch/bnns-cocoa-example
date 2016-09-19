### Using TensorFlow and BNNS to Add Machine Learning to your Mac or iOS App

With the release of macOS 10.12 and iOS 10, Apple has given users everywhere access to its *Basic Neural Network Subroutines* (BNNS, which we at BNR feel should be pronounced "Bananas"). Google open-sourced *TensorFlow*, its machine learning framework nearly a year ago. Maybe you are thinking it is time to add some artificial intelligence in your Mac or iOS application and you are wondering which to use. The answer, for now at least, is you will probably use both.

[Documentation for BNNS](https://developer.apple.com/reference/accelerate/1912851-bnns)

[TensorFlow website](https://www.tensorflow.org)

A story first: The summer after my first year in college, I had a terrible, terrible job on the night shift at a USAir customer service call center. This job mainly involved talking on the phone with people who hated me -- a soul bruising task. I knew someone who had a great job at the Mitre Corporation's Advanced Signal Processing Lab, and I asked him "What do I need to know to get a job like yours?" And he replied "C programming on Unix." I went back to school and raised a ruckus in the Electrical Engineering department until they gave me access to a Unix machine, and I taught myself C. I got the job at Mitre, and I spent the rest of my summers in college doing machine learning experiments. In particular, I worked on speech recognition problems using neural networks.

Thanks to 25 years of video gamers who were willing to pay top dollar for good GPUs, a lot has changed since 1989. Neural networks involve huge amounts of floating point operations, so in 1989 we could only train and use the simplest networks. In 1989, if you sprung for a MIPS R3010, you would be delighted with 4 million floating point operations per second. Today, the Nvidia GTX 1080 graphics card (just $650) is 2 million times faster: it does 9 trillion floating point operations per second.

And this brings us to one of the challenges of using Google's TensorFlow: The engineers who wrote TensorFlow implemented all the code to move the computation onto the graphics processor using CUDA.  CUDA is an Nvidia-specific technology and most Apple products do not use Nvidia graphics processors. (There is an effort to rewrite those parts using OpenCL, which is supported on all Apple devices, but if you are using TensorFlow today it will not be GPU-accelerated on most Apple devices.).

Most deep learning techniques are based on neural nets. Neural nets are a rough simulation of how biological neurons work.  They are connected in a network and the output of one neuron acts as one input to many other neurons. The network learns by adjusting the weights between the neurons using a technique called *Backpropagation*. (You can get more details from [Bolot's recent blog post.](https://www.bignerdranch.com/blog/neural-networks-in-ios-10-and-macos/) )

This brings us to one of the challenges of using Apple's BNNS: There is no support for backpropagation — the networks don't learn. To use the BNNS, you need to train the network using something else (like TensorFlow) and then import the weights.

Thus, there are two ways to get deep learning into your Mac or iOS application:
* Solution 1: Do all the neural net work on a server using TensorFlow. You must be certain that all your users always have a good internet connection and that the data you are sending/receiving is not too voluminous.

* Solution 2: Train the neural net using TensorFlow and export the weights. Then, when you write the iOS or Mac application, recreate the the neural net using BNNS and import the weights.

Google [would love to talk to you about Solution 1](https://cloud.google.com/ml/), so the rest of this posting will be about Solution 2. As an example, I've used TensorFlow's MNIST example: handwritten digit recognition with just an input and an output layer, fully-connected. The input layer has 784 nodes (one for each pixel) and the output has 10 nodes (one for each digit). Each output node gets a bias added before it is run through the softmax algorithm. Here is the [source](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/examples/tutorials/mnist/mnist_softmax.py), which you will get automatically when you install TensorFlow.

My sample code is [posted on GitHub](https://github.com/bignerdranch/bnns-cocoa-example).

# Getting the weights out of a TensorFlow Python script

If you train your neural net using TensorFlow, you will almost certainly write that code in Python. (There is a C++ interface, but it is very limited and poorly documented.)  You will create a Variable tensor to hold the weights. Here I'm creating a two-dimensional Variable tensor filled with zeros:

	W = tf.Variable(tf.zeros([784, 10]))

You will give the neural net data and train it. Then write out the weights:

	weight_list = W.eval().tolist()
	thefile = open('/tmp/weights.data', 'w')
	thefile.write(str(weight_list))
	thefile.close()

This will result in a text file filled with arrays of floating point numbers. In my example, I get an array containing 784 arrays. The inner arrays each contain 10 floating point numbers:

	[[0.007492697797715664, -0.0013006168883293867, …, -0.006132100708782673], [0.0033850250765681267, …-5.2658630011137575e-05]]

## Using those weights in a Cocoa application with BNNS

This is a easy format to read in Cocoa. The sample code has some routines that will read one- and two- dimensional arrays.

Then, using BNNS, recreate the topology of the neural network that you created in TensorFlow and copy the weights in:

    BNNSVectorDescriptor inVectorDescriptor = 
        { .data_type = BNNSDataTypeFloat32, .size = IN_COUNT };
    
    BNNSVectorDescriptor outVectorDescriptor = 
        {.data_type = BNNSDataTypeFloat32, .size = OUT_COUNT};

    BNNSFullyConnectedLayerParameters parameters = 
        { .in_size = IN_COUNT, .out_size = OUT_COUNT };
    
    float *weightVector = (float *)malloc(sizeof(float) * IN_COUNT * OUT_COUNT);

    // Fill 'weightVector' with data from a file here! 
    
    parameters.weights.data = weightVector;
    parameters.weights.data_type = BNNSDataTypeFloat32;

    float *biasVector = (float *)malloc(sizeof(float) * OUT_COUNT);
  
    // Fill 'biasVector' with data from a file here!
    
    parameters.bias.data = biasVector;
    parameters.bias.data_type = BNNSDataTypeFloat32;
    
    parameters.activation.function = BNNSActivationFunctionIdentity;
    
    // Create the filter
    filter = BNNSFilterCreateFullyConnectedLayer(&inVectorDescriptor,
                                                 &outVectorDescriptor,
                                                 &parameters,NULL);


To use the resulting filter, supply arrays for the input and output:

    float inBuffer[IN_COUNT];

    // Fill inBuffer with input here

    float outBuffer[OUT_COUNT];
    int success = BNNSFilterApply(filter, inBuffer, outBuffer);

Note the big shortcoming here: Once you dump the weights out of TensorFlow, your application won't get any smarter. At this time BNNS doesn't do backpropagation — it doesn't learn. However, it will be GPU accelerated on any iOS or macOS device, which will make it faster and consume less power.

Note that TensorFlow is very extensive and has lots of operations that are not available in BNNS. When you are creating the topology of your neural network, use the operations that are available in both toolkits. If you don't, you will need to implement the operation yourself. In this example, TensorFlow had a built-in `softmax` operation. I had to implement `softmax` to use it on the Mac.

To wrap this up, this is a pretty poor solution, and eventually two things will happen:

* Apple will extend BNNS to include training and backpropagation.
* Google will get TensorFlow to be GPU-accelerated on all OpenCL-enabled devices.

However, for now, you will probably use both if you want to add machine learning to your Mac or iOS app.


