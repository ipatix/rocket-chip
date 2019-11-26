#!/bin/bash

set -eu

echo $(pwd)

if ! [[ $(pwd) = */rocket-chip/vivado ]]; then
    echo "Please execute script from within the vivado directory only!"
    exit 1
fi

renice -n 10 $$
make -j `nproc` -C ../vsim verilog CONFIG=ZedboardConfig
rm -rf .Xil rocket_board_design rocket_ip_core
vivado -mode batch -source "all.tcl" -nojournal -nolog
