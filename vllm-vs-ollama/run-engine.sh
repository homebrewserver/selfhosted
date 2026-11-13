#!/bin/bash
# Usage: run-engine.sh <engine> <url> <model> <label-prefix>
E=$1; U=$2; M=$3; L=$4
python3 bench.py $E --url $U --model $M --prompt short -n 512 -k 1 --rounds 5 --label $L-k1-short
python3 bench.py $E --url $U --model $M --prompt long -n 256 -k 1 --rounds 5 --label $L-k1-long
for k in 4 8 16 32; do python3 bench.py $E --url $U --model $M --prompt short -n 256 -k $k --rounds 3 --label $L-k$k-short; done
python3 bench.py $E --url $U --model $M --prompt long -n 256 -k 8 --rounds 3 --label $L-k8-long
