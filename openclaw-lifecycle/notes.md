# OpenClaw lifecycle tests, 2026-11-08
## Docker (Fedora 44, Docker 29.9.2, Ollama 0.30.10 qwen3.5:9b on RTX 3090)
- setup.sh with ghcr.io/openclaw/openclaw:2026.10.10: 13 s. setup.sh uses `-f docker-compose.yml`, so docker-compose.override.yml is NOT applied: ports came up 0.0.0.0 incl 3978. `docker compose up -d openclaw-gateway` afterwards applied the override (127.0.0.1 only).
- Onboard (stop, sleep 90, run --rm onboard --auth-choice ollama, http://host.docker.internal:11434): ok.
- healthy ~20 s after start. agent turn writing file: 13 s.
- docker compose stop: 1 s. start -> healthy 52 s. docker compose restart -> healthy 23 s.
- `openclaw gateway restart` inside container: "restart request sent to foreground process"; log "in-process restart (container: use in-process restart to keep PID 1 alive)", ready 6 s later; container stays up.
- `openclaw update` in container: "update skipped: container-image-install ... Pull or build the target Docker/container image, then redeploy it with the same state/config mounts."
- Update: OPENCLAW_IMAGE tag -> 2026.11.1; pull, stop, up -d: healthy 56 s after pull start (image already local). Doctor ran on start. File + default model kept. Agent turn 9 s.
- Removal: compose down removed container + network oc_default; no named volumes (bind mounts). image rm 2026.10.10 freed 2.6 GB (docker system df 177.5 -> 174.9). Repo clone (depth 1) 954 MB, data 4.4 MB.
## Native (Ubuntu 26.04.1 cloud image, QEMU/KVM, 4 vCPU, 6 GB RAM)
- install.sh --no-onboard --version 2026.10.10: 164 s. Installed build tools (make g++ cmake python3), NodeSource repo (/etc/apt/sources.list.d/nodesource.sources), nodejs 24.22.2 (npm 11.19.1). npm prefix /usr not writable -> ~/.npm-global, ~/.npmrc prefix=, PATH line added at top of ~/.bashrc and ~/.profile; warned PATH missing for current shell. ~/.npm-global 648 MB.
- onboard --install-daemon (ollama 10.0.2.2:11434): 16 s. "Installed systemd service: ~/.config/systemd/user/openclaw-gateway.service", "Enabled systemd lingering for tester." bind loopback 127.0.0.1:18789.
- gateway status: CLI/Gateway version, Runtime running pid, Connectivity check ok, Listening 127.0.0.1:18789, Dashboard http://127.0.0.1:18789/.
- `openclaw gateway stop` from non-TTY (ssh cmd or piped): refuses: "This stops the operator's running gateway service... re-run with --force". Code: isTerminalInteractive = stdin.isTTY && stdout.isTTY. With TTY: stopped 3 s; start 12 s. restart (non-TTY works): 12 s, "Restarted systemd service: openclaw-gateway.service".
- Gateway RSS ~2.0 GB (1,996,576 KB) + 2 spawn-broker workers ~110 MB each.
- Reboot: service active after boot without login (Linger=yes).
- update status: "Update available (npm 2026.11.2)". npm latest 2026.11.2 published 2026-11-08 09:48 UTC; GitHub latest release still v2026.11.1.
- `openclaw update --yes`: 315 s total; phases requested 75 s, validating 81 s, activating 62 s, restarting 5 s, verifying 78 s; "Gateway downtime: 87.55s". Refreshed service unit, left ~/.config/systemd/user/openclaw-gateway.service.reconcile-*.bak + .receipt.bak. Data kept. Warning: openclaw.json contains plaintext secret-bearing config fields.
- After update: ~/.npm-global 1.3 GB (648 MB package + 624 MB lib/openclaw-update-runtime-*), ~/.npm cache 441 MB, ~/.openclaw.update-captures 3.8 MB.
- `openclaw uninstall --all --dry-run` without --yes prompts; with --yes lists: remove gateway service, ~/.openclaw, ~/.openclaw/workspace.
- `openclaw uninstall --all --yes --non-interactive`: 2 s. Service inactive, unit removed, ~/.openclaw removed. Left: CLI (still runs), unit .bak files, ~/.openclaw.update-captures, ~/.npm-global incl update runtime, ~/.npm, linger=yes, .npmrc, PATH lines, Node.
- `npm rm -g openclaw`: removed 508 packages. Left 624 MB runtime + 441 MB cache.
- Cleanup: rm runtime, captures, unit .bak; npm cache clean --force; sudo loginctl disable-linger. Remove nodejs (apt), nodesource.sources, PATH lines, .npmrc, ~/.npm-global. Disk used: 4,574 MB before uninstall -> 3,912 after uninstall+npm rm -> 2,845 after cleanup -> 2,598 after Node removal (fresh VM 2.0 GB).
- Reinstall latest (install.sh --no-onboard): 105 s, 2026.11.2.
- `npm rm -g openclaw` alone with service running: gateway keeps running & listening. After systemctl --user restart: fails "Cannot find module ...", Restart=always RestartSec=5 -> restart loop (NRestarts 3 within seconds). Manual: systemctl --user disable --now; rm unit; daemon-reload -> inactive.
