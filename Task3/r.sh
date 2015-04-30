#!/bin/sh
make clean
make 
gdb -tui ./tester
