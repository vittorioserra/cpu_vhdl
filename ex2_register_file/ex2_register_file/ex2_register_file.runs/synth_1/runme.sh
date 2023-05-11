#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/tools.remote/xilinx/Vitis/2021.2/bin:/tools.remote/xilinx/Vivado/2021.2/ids_lite/ISE/bin/lin64:/tools.remote/xilinx/Vivado/2021.2/bin
else
  PATH=/tools.remote/xilinx/Vitis/2021.2/bin:/tools.remote/xilinx/Vivado/2021.2/ids_lite/ISE/bin/lin64:/tools.remote/xilinx/Vivado/2021.2/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/rzlin/ko92vuzu/cpu_vhdl/ex2_register_file/ex2_register_file/ex2_register_file.runs/synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log regfile.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source regfile.tcl
