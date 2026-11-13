#!/bin/bash
# Hands-on test: list, delete and remove Ollama models in Docker. Uses its own container and volume.
C=ollama-rmtest; V=ollama-rmtest; IMG=ollama/ollama:0.40.15
x(){ echo; echo "\$ $*"; "$@" 2>&1; }
o(){ echo; echo "\$ ollama $*"; docker exec $C ollama "$@" 2>&1; }
sz(){ echo "[disk] models dir: $(docker exec $C du -sb /root/.ollama/models | cut -f1) bytes ($(docker exec $C du -sh /root/.ollama/models | cut -f1)); blobs: $(docker exec $C sh -c 'ls /root/.ollama/models/blobs | wc -l')"; }
date -Is; docker --version
x docker run -d --name $C -v $V:/root/.ollama $IMG
sleep 5; o --version
sz
o pull smollm2:135m
o pull smollm2:360m
o pull qwen3:0.6b
sz
o list
x docker exec $C ls -la /root/.ollama/models/manifests/registry.ollama.ai/library/
o cp smollm2:135m my-smollm
o list
sz
echo "--- rm the copy: shared blobs stay"
o rm my-smollm
sz
echo "--- rm a model while it is loaded"
o run smollm2:360m "Say hi in three words."
o ps
o rm smollm2:360m
o ps
o list
sz
echo "--- API delete"
x docker exec $C curl -s -o /dev/null -w '%{http_code}\n' -X DELETE http://localhost:11434/api/delete -d '{"model":"qwen3:0.6b"}'
x docker exec $C curl -s -o /dev/null -w '%{http_code}\n' -X DELETE http://localhost:11434/api/delete -d '{"model":"qwen3:0.6b"}'
o rm qwen3:0.6b
o list
sz
echo "--- interrupted pull leaves partial files"
docker exec $C ollama pull qwen3:1.7b >/dev/null 2>&1 & P=$!; sleep 12; docker exec $C pkill -f 'ollama pull' ; kill $P 2>/dev/null; sleep 2
x docker exec $C sh -c 'ls -la /root/.ollama/models/blobs | grep -i partial | head'
sz
o list
o rm qwen3:1.7b
x docker exec $C sh -c 'ls /root/.ollama/models/blobs | grep -c partial'
echo "--- restart the container: does the server prune?"
x docker restart $C; sleep 8
x docker exec $C sh -c 'ls /root/.ollama/models/blobs | grep -c partial'
sz
x sh -c "docker logs $C 2>&1 | grep -i -E 'prun|partial' | head"
echo "--- multiple names in one rm"
o pull smollm2:360m
o cp smollm2:360m extra-a
o rm extra-a smollm2:360m
o list
sz
echo "--- remove everything"
x docker volume inspect $V --format '{{.Mountpoint}}'
x docker system df -v --format '{{json .Volumes}}'
x docker rm -f $C
x docker volume ls -q --filter name=$V
x docker volume rm $V
x docker volume ls -q --filter name=$V
date -Is
