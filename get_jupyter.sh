#!/bin/bash

SOURCE=`dirname "$(readlink -f "$0")"`

TARGET=$SOURCE/QLearningArchitectureTest.ipynb

scp xilinx@192.168.3.1:/home/xilinx/jupyter_notebooks/qlearning_architecture/QLearningArchitectureTest.ipynb $TARGET
