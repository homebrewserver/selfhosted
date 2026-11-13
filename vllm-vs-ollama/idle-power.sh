#!/bin/bash
# Usage: idle-power.sh <label>: sample GPU power/clock/temp every 10 s for 6 min after the last request
L=$1
for t in $(seq 0 10 360); do echo "$L idle+${t}s $(nvidia-smi --query-gpu=power.draw,clocks.sm,temperature.gpu,memory.used --format=csv,noheader)"; sleep 10; done | tee -a idle-power.log
