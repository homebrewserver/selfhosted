#!/bin/bash
# Pull the pinned HyperQwen image and run the one-time model preparation; log timings.
cd "$(dirname "$0")"
L=setup-log.md
echo "## setup $(date '+%F %T'), repo commit $(git -C repo rev-parse --short HEAD)" >> $L
t0=$(date +%s)
docker pull ghcr.io/syv-ai/hyperqwen:sha-3d6c954 > pull.log 2>&1 || { echo "pull failed" >> $L; exit 1; }
docker tag ghcr.io/syv-ai/hyperqwen:sha-3d6c954 ghcr.io/syv-ai/hyperqwen:latest
echo "- image pull: $(( $(date +%s)-t0 )) s; size $(docker image inspect ghcr.io/syv-ai/hyperqwen:sha-3d6c954 --format '{{.Size}}' | awk '{printf "%.2f GB", $1/1e9}')" >> $L
t1=$(date +%s)
cd repo && docker compose run --rm prepare > ../prepare.log 2>&1; rc=$?; cd ..
echo "- prepare (download + requantize): $(( $(date +%s)-t1 )) s, exit $rc; models dir $(du -sh $HOME/hyperqwen-models | cut -f1)" >> $L
