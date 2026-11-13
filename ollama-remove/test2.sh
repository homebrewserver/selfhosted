#!/bin/bash
# Run 2: install without/with GPU, list via CLI/API, ps, stop model, delete via API, port clash,
# stop/start/restart container, update by recreating on a newer image, Compose. Own container/volume only.
C=ollama-rmtest2; V=ollama-rmtest2; P=11535
x(){ echo; echo "\$ $*"; "$@" 2>&1 | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' | tr '\r' '\n' | grep -v -E '^\s*$|pulling manifest|[0-9]+%|^\s*[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏]'; }
o(){ x docker exec $C ollama "$@"; }
date -Is; nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
echo "=== install, CPU only (no --gpus)"
x sh -c "time docker run -d --name $C -p 127.0.0.1:$P:11434 -v $V:/root/.ollama ollama/ollama:0.40.15"
sleep 5
o --version
x sh -c "docker logs $C 2>&1 | grep -i -E 'inference compute|no compatible|gpu' | head -5"
x sh -c "time docker exec $C ollama pull qwen3:0.6b"
o pull smollm2:135m
x sh -c "docker exec $C ollama run qwen3:0.6b 'Reply with one word: ok' --think=false --verbose 2>&1 | grep -E 'eval rate|^ok|Ok|OK'"
o ps
echo "=== list: CLI and API"
o list
x sh -c "curl -s http://127.0.0.1:$P/api/tags | python3 -c 'import json,sys;[print(m[\"name\"],m[\"size\"]) for m in json.load(sys.stdin)[\"models\"]]'"
x sh -c "curl -s http://127.0.0.1:$P/api/ps | python3 -c 'import json,sys;[print(m[\"name\"],m.get(\"size_vram\"),m.get(\"expires_at\")) for m in json.load(sys.stdin)[\"models\"]]'"
echo "=== unload a model"
o stop qwen3:0.6b
o ps
echo "=== second server in the same container"
o serve
echo "=== recreate with the GPU, same volume"
x docker rm -f $C
x docker run -d --gpus=all --name $C -p 127.0.0.1:$P:11434 -v $V:/root/.ollama ollama/ollama:0.40.15
sleep 6
x sh -c "docker logs $C 2>&1 | grep -i -E 'inference compute' | head -3"
o list
x sh -c "docker exec $C ollama run qwen3:0.6b 'Reply with one word: ok' --think=false --verbose 2>&1 | grep -E 'eval rate'"
o ps
echo "=== delete via API"
x curl -s -w '\nHTTP %{http_code}\n' -X DELETE http://127.0.0.1:$P/api/delete -d '{"model":"qwen3:0.6b"}'
x curl -s -w '\nHTTP %{http_code}\n' -X DELETE http://127.0.0.1:$P/api/delete -d '{"model":"qwen3:0.6b"}'
o list
echo "=== port already used on the host"
x docker run --rm -d --name ${C}-clash -p 127.0.0.1:$P:11434 ollama/ollama:0.40.15
echo "=== stop, start, restart"
x sh -c "time docker stop $C"
x curl -s -m 3 http://127.0.0.1:$P/api/version
x docker start $C; sleep 4
x curl -s http://127.0.0.1:$P/api/version
x sh -c "time docker restart $C"
echo "=== update: recreate on a newer image, same volume"
x docker inspect ollama/ollama:latest --format '{{.Created}} {{index .Config.Labels "org.opencontainers.image.version"}}'
x docker rm -f $C
x docker run -d --gpus=all --name $C -p 127.0.0.1:$P:11434 -v $V:/root/.ollama ollama/ollama:latest
sleep 6
o --version
o list
x docker rm -f $C
echo "=== Compose"
mkdir -p /tmp/ollama-compose-test && cat > /tmp/ollama-compose-test/compose.yaml <<YAML
services:
  ollama:
    image: ollama/ollama:0.40.15
    container_name: ollama-composetest
    ports:
      - "127.0.0.1:$P:11434"
    volumes:
      - $V:/root/.ollama
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
volumes:
  $V:
    external: true
YAML
x docker compose -f /tmp/ollama-compose-test/compose.yaml up -d
sleep 6
x docker exec ollama-composetest ollama list
x sh -c "docker logs ollama-composetest 2>&1 | grep -i 'inference compute' | head -2"
x docker compose -f /tmp/ollama-compose-test/compose.yaml down
echo "=== clean up"
x sh -c "docker system df -v 2>/dev/null | grep -E '^VOLUME NAME|$V'"
x docker volume rm $V
x docker images ollama/ollama --format '{{.Repository}}:{{.Tag}} {{.Size}}'
rm -rf /tmp/ollama-compose-test
date -Is
