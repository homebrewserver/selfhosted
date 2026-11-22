#!/bin/bash
cd "$(dirname "$0")"/repo
t1=$(date +%s)
docker compose run --rm prepare > ../prepare2.log 2>&1; rc=$?
echo "- prepare rerun (resume download + requantize): $(( $(date +%s)-t1 )) s, exit $rc; models dir $(du -sh $HOME/hyperqwen-models | cut -f1)" >> ../setup-log.md
echo done-$rc > ../prepare.done
