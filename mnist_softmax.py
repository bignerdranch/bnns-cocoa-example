# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

"""A very simple MNIST classifier.

See extensive documentation at
http://tensorflow.org/tutorials/mnist/beginners/index.md
"""
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

# Import data
from tensorflow.examples.tutorials.mnist import input_data

import tensorflow as tf
import freeze_graph

flags = tf.app.flags
FLAGS = flags.FLAGS
flags.DEFINE_string('data_dir', '/tmp/data/', 'Directory for storing data')

mnist = input_data.read_data_sets(FLAGS.data_dir, one_hot=True)

sess = tf.InteractiveSession()

# Create the model
x = tf.placeholder(tf.float32, [None, 784], name='pix_in')

W = tf.Variable(tf.zeros([784, 10], name='zeroing_weights'), name='weights')
b = tf.Variable(tf.zeros([10], name='zeroing_baises'), name='biases')
y = tf.nn.softmax(tf.add(tf.matmul(x, W, name='convoluting'), b, name='biasing'), name='normalized_guesses')


# Define loss and optimizer
y_ = tf.placeholder(tf.float32, [None, 10], name='correct_answers')
# error = tf.reduce_sum(tf.square(tf.sub(y_,y)), name='error')
error = tf.reduce_mean(-tf.reduce_sum(y_ * tf.log(y), reduction_indices=[1]))


train_step = tf.train.GradientDescentOptimizer(0.5).minimize(error)

# Create saver to save and restore all the variables
saver = tf.train.Saver([W, b])


# Train
init_op = tf.initialize_all_variables()

sess.run(init_op)

for i in range(1000):
  batch_xs, batch_ys = mnist.train.next_batch(1000)
  train_step.run({x: batch_xs, y_: batch_ys})

save_path = saver.save(sess, "/tmp/parameters.pb")
print("Parameters in file: %s" % save_path)

graph_def = tf.get_default_graph().as_graph_def()
tf.train.write_graph(graph_def, '/tmp', 'graphdef.pb', False)
print("Model in file: /tmp/graphdef.pb")

weight_list = W.eval().tolist()
thefile = open('/tmp/weights.data', 'w')
thefile.write(str(weight_list))
thefile.close()

bias_list = b.eval().tolist()
thefile = open('/tmp/biases.data', 'w')
thefile.write(str(bias_list))
thefile.close()

# Test trained model
correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, tf.float32))
print(accuracy.eval({x: mnist.test.images, y_: mnist.test.labels}))



