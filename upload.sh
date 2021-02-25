#!/bin/bash

SOURCE=`dirname "$(readlink -f "$0")"`

HWH_FILE=$SOURCE/project/qlearn_architecture/qlearn_architecture.srcs/sources_1/bd/design_1/hw_handoff/design_1.hwh
BIT_FILE=$SOURCE/project/qlearn_architecture/qlearn_architecture.runs/impl_1/design_1_wrapper.bit

echo $HWH_FILE
echo $BIT_FILE

scp $HWH_FILE xilinx@192.168.3.1:/home/xilinx/jupyter_notebooks/qlearning_architecture/design_1_wrapper.hwh

scp $BIT_FILE xilinx@192.168.3.1:/home/xilinx/jupyter_notebooks/qlearning_architecture/design_1_wrapper.bit
