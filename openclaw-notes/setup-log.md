# OpenClaw in Docker + Ollama + Discord — setup log

Test log for the homebrewserver article (target: `openclaw docker` 1,300/KD 33; `openclaw discord` 880/KD 14).
Every step is written down as it is done, with the exact command or click, what happened, and any error.

## Test machine

- Fedora 44, kernel 7.2.13, Docker 29.9.2 with nvidia-container-runtime
- GPU: RTX 3090 24 GB; RAM 62 GB
- Ollama 0.30.10 already running as Docker container `ollama` on port 11434
  - Models: qwen3.5:9b (6.6 GB), qwen3-embedding:4b, qwen3-embedding:0.6b

## 1. Get OpenClaw (2026-11-08)

```bash
mkdir -p ~/homelab-tests && cd ~/homelab-tests
git clone --depth 1 --branch v2026.11.1 https://github.com/openclaw/openclaw.git
docker pull ghcr.io/openclaw/openclaw:2026.11.1
```

- Latest release on 2026-11-08: v2026.11.1 (published 2026-11-05).
- The repo has `scripts/docker/setup.sh` and `docker-compose.yml`.
- Compose maps `host.docker.internal:host-gateway`, so the container can reach Ollama on the host on Linux.
- By default config goes to `~/.openclaw` on the host; we point it at a separate folder instead.

## 2. Create the Discord bot (Developer Portal)

1. Open https://discord.com/developers/applications while logged in to Discord.
2. First visit shows "What brings you to the Developer Portal?" — clicked **Skip**.
3. Applications page → **New Application** (top right).
4. "Create a new app" dialog: Name = `OpenClaw Homelab Test`; tick the box agreeing to the Developer Terms of Service and Developer Policy; **Create**.
5. App created; the portal opens **General Information** with the Application ID and Public Key (screenshot `02-app-created.jpg`). The Application ID is public; it is used in the invite link.
6. Left sidebar → **Bot**.
   - Gotcha: Chrome autofill put an email address into the bot **Username** field as soon as the page loaded ("Careful — you have unsaved changes!"). Clicked **Reset** so it was not saved. Check this field before saving.
7. Under **Privileged Gateway Intents** turned on:
   - **Message Content Intent** — required, or the bot cannot read normal server messages.
   - **Server Members Intent** — recommended by the OpenClaw docs (role allowlists, name-to-ID matching).
   - Presence Intent left off (only needed for presence updates).
   (screenshot `03-privileged-intents.jpg`)
8. Tried to turn **Public Bot** off at the same time (so only the owner can add the bot to servers). Save failed:
   > Validation errors: Private application cannot have a default authorization link. Please check that the default authorization link is set to None in the installation tab.
   Fix: save the intents with Public Bot still on, then set **Installation → Install Link** to **None**, then come back and turn Public Bot off.
9. Saved with Public Bot on: intents saved, no error.
10. **Installation** → **Install Link**: changed "Discord Provided Link" → **None** → Save ("All your edits have been carefully recorded").
11. Back to **Bot** → turned **Public Bot** off → Save → "Bot successfully updated!". Autofill had again put the email into Username on page load; reset it first.
12. Invite URL. Scopes `bot` + `applications.commands`; permissions from the OpenClaw docs baseline:
    View Channels (1024), Send Messages (2048), Embed Links (16384), Attach Files (32768), Read Message History (65536), Add Reactions (64), Send Messages in Threads (274877906944) → permissions integer **274878024768**.
    ```
    https://discord.com/oauth2/authorize?client_id=<APPLICATION_ID>&permissions=274878024768&integration_type=0&scope=bot+applications.commands
    ```
    (Same result as ticking those boxes in **OAuth2 → URL Generator**.)
13. Opened the invite URL: "Add to server" dropdown showed **"No items to show"** — the account owns no server it can manage (needs Manage Server). A test server has to be created first.
14. Created a private test server: Discord home → **Add a Server** (+) → **Create My Own** → **For me and my friends** → name `OpenClaw Test` → **Create**. Server has `#general` text channel.
15. Opened the invite URL again → Add to server: **OpenClaw Test** → **Continue** → permissions screen lists View Channels, Send Messages, Send Messages in Threads, Embed Links, Attach Files, Read Message History, Add Reactions (screenshot `04-authorize-permissions.jpg`) → **Authorize**.
16. Discord showed an hCaptcha ("Wait! Are you human?") after Authorize — solved by hand.
17. After the captcha: "Success! OpenClaw Homelab Test has been authorized and added to OpenClaw Test."
18. Bot token: **Bot → Reset Token** (shown once; copy it). Token kept out of chat and out of the config file: written by the owner to `~/homelab-tests/openclaw-discord.env` (mode 600) as `DISCORD_BOT_TOKEN=...`.

## 3. OpenClaw Docker setup

```bash
cd ~/homelab-tests/openclaw
mkdir -p ~/homelab-tests/openclaw-data/workspace
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.11.1 \
OPENCLAW_CONFIG_DIR=$HOME/homelab-tests/openclaw-data \
OPENCLAW_WORKSPACE_DIR=$HOME/homelab-tests/openclaw-data/workspace \
OPENCLAW_AUTH_PROFILE_SECRET_DIR=$HOME/homelab-tests/openclaw-data/auth-secrets \
OPENCLAW_SKIP_ONBOARDING=1 OPENCLAW_TZ=Asia/Karachi \
./scripts/docker/setup.sh
```

- Onboarding in setup.sh is interactive; skipped it here and ran onboarding non-interactively afterwards (next step).
- Output: "Pinned gateway.mode=local and gateway.bind=lan for Docker setup." and "Set gateway.controlUi.allowedOrigins to [http://localhost:18789, http://127.0.0.1:18789]". Gateway container `openclaw-openclaw-gateway-1` started. Gateway token is generated and stored in `.env`, not printed.
- Sandbox left off (`OPENCLAW_SANDBOX` unset). Turning it on mounts `/var/run/docker.sock` into the gateway container, which gives the container control of the host's Docker. Without it, agent tools run inside the gateway container, which only sees `openclaw-data`.
- Checked Ollama from inside the gateway container: `curl http://host.docker.internal:11434/api/version` → `{"version":"0.30.10"}`. Works on Fedora with Ollama published on 0.0.0.0:11434; no firewall change needed.
- `qwen3.5:9b` capabilities from `/api/show`: completion, vision, tools, thinking; context 262,144.

## 4. Lock ports to localhost + pass the Discord token

`docker-compose.override.yml` (Compose loads it automatically):

```yaml
services:
  openclaw-gateway:
    env_file:
      - path: .env
        required: false
      - path: ../openclaw-discord.env
        required: true
    ports: !override
      - "127.0.0.1:18789:18789"
      - "127.0.0.1:18790:18790"
```

- Default compose publishes 18789, 18790 and 3978 (Teams) on 0.0.0.0, i.e. the whole LAN. `!override` replaces the list instead of appending.
- Token file: `~/homelab-tests/openclaw-discord.env`, mode 600, one line `DISCORD_BOT_TOKEN=...`. Verified with `GET /api/v10/users/@me` → bot "OpenClaw Homelab Test"; `/users/@me/guilds` → OpenClaw Test.

## 5. Onboard with Ollama (non-interactive)

Gotchas hit, in order:
1. `docker compose run --rm openclaw-cli onboard ...` → "The CLI command failed." `openclaw doctor` explains: "cannot verify Gateway ownership from this process (different PID namespace) ... wait up to 90 seconds after its last heartbeat."
2. `docker compose exec openclaw-gateway node dist/index.js onboard ...` → "OpenClaw state ... is undergoing offline maintenance; retry when it finishes."
3. Fix: stop the gateway, wait ~90 s for the heartbeat to go stale, then run onboarding in a one-off container (same as setup.sh does):

```bash
docker compose stop openclaw-gateway
sleep 90
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js onboard \
  --non-interactive --accept-risk --mode local --no-install-daemon \
  --gateway-auth token --gateway-token-ref-env OPENCLAW_GATEWAY_TOKEN \
  --skip-ui --suppress-gateway-token-output --skip-channels --skip-search --skip-health \
  --auth-choice ollama --custom-base-url "http://host.docker.internal:11434" --custom-model-id "qwen3.5:9b"
```

Output: "Default Ollama model: qwen3.5:9b", "Updated config: .../openclaw.json".

## 6. Discord channel config

Server owner ID read with the bot token: `GET /api/v10/guilds/<server_id>` → `owner_id` (saves turning on Developer Mode).

`openclaw-data/discord.patch.json5`:

```json5
{
  channels: {
    discord: {
      enabled: true,
      token: { source: "env", provider: "default", id: "DISCORD_BOT_TOKEN" },
      applicationId: "<APPLICATION_ID>",
      groupPolicy: "allowlist",
      guilds: {
        "<SERVER_ID>": { requireMention: true, users: ["<YOUR_USER_ID>"] },
      },
    },
  },
}
```

```bash
docker compose run --rm --no-deps --entrypoint node openclaw-gateway dist/index.js config patch --file /home/node/.openclaw/discord.patch.json5
# "Applied 6 config update(s)."
docker compose up -d openclaw-gateway
```

Gateway log after start (~10 s to listening, healthy at ~1 min):
- `agent model: ollama/qwen3.5:9b (thinking=off, fast=off)`
- `Discord bot check resolved @OpenClaw Homelab Test`
- `Discord Message Content Intent is limited; bots under 100 servers can use it without verification.`
- Warning shown even with ports on 127.0.0.1: "Gateway is binding to a non-loopback address" — that is the bind *inside* the container (lan); the host publish is loopback only.

## 7. End-to-end test 1: mention in #general (cold model)

Message (10:32): `@OpenClaw Homelab Test Hi! Which model are you running on, and what is 17 * 23?`
- Bot reacted 👀 within ~1 s, showed "is typing…".
- Reply (10:33): "I'm running on **ollama/qwen3.5:9b**. And 17 * 23 = **391**." — correct. (screenshot `05-first-discord-reply.jpg`)
- Mention in the composer: typing `@OpenClaw Homelab` gave no autocomplete in the web client; raw `<@APPLICATION_ID>` works and renders as a mention.

Timings (Ollama log):
- `/api/chat` total **1 m 10 s** (cold): model was not loaded; qwen3.5:9b loaded at 05:33:06, ~59 s after the request arrived.
- Prompt: **18,415 tokens** for a one-line question (OpenClaw system prompt + tools + workspace files). Prefill 10.0 s at **1,838 tok/s**.
- Generation: 33 tokens at **91 tok/s**.
- OpenClaw also called `/api/embed` twice (memory indexing) — it picked up `qwen3-embedding:4b` already on the Ollama host.
- Gateway log: `context-pressure-diagnostic ... estimatedPromptTokens=24608 promptBudgetBeforeReserve=24576` — the default context budget for this model is almost fully used by the base prompt. Ollama loaded the model with ctx 32768.
- VRAM with qwen3.5:9b (6.3 GB) + qwen3-embedding:4b (5.1 GB) loaded: 14.7 GB of 24 GB on the GPU.

## 8. End-to-end test 2: tool call (warm model)

Message (10:34): `@OpenClaw Homelab Test Create a file called homelab-test.md in your workspace with three bullet points about why someone would self-host an AI assistant, then tell me the file path.`
- Reply (10:34): "Done! The file is here: /home/node/.openclaw/workspace/homelab-test.md ✅" (screenshot `06-tool-call-file.jpg`)
- On the host: `~/homelab-tests/openclaw-data/workspace/homelab-test.md`, 875 bytes, three bullets (privacy, cost, customization). Container path `/home/node/.openclaw/workspace` = host bind mount.
- Quality note: the 9B model slipped one Chinese word ("忍受") into an English sentence. Small local models do this; worth mentioning.
- Timings: two `/api/chat` calls (tool call, then final answer). Prompt cache reused the 18k-token prefix, so prefill was only 524 + 253 tokens. Calls took **2.8 s + 0.7 s**; generation **95 tok/s**.
- Workspace also holds the files OpenClaw created at onboarding: AGENTS.md, BOOTSTRAP.md, IDENTITY.md, SOUL.md, USER.md (mode 600).

## To do after testing

- **Reset the Discord bot token** (it was pasted into a chat transcript). Bot → Reset Token, then update `openclaw-discord.env` and `docker compose up -d openclaw-gateway`.

## 9. Restart test

```bash
docker compose down && docker compose up -d
```
- Healthy again after **57 s**; Discord reconnected; model still `ollama/qwen3.5:9b`.
- Gotcha: plain `docker compose up -d` also starts the `openclaw-cli` service as a long-running container. Use `docker compose up -d openclaw-gateway` (the CLI is meant for `run --rm`).
- Message: "I just restarted you. What file did you create for me earlier...?" → reply claimed "I've lost our previous session's memory", yet named `homelab-test.md` from the session history and offered to recreate it (screenshot `07-after-restart-claims-lost.jpg`). Wrong: nothing was lost. Reply took 1.9 s (prompt 2,412 tokens, 96 tok/s).
- Follow-up: "Use your read tool to open homelab-test.md ..." → read the file and listed all three points correctly (screenshot `08-after-restart-reads-file.jpg`).
- Conclusion: config, Discord link, session history and workspace files all persist in `openclaw-data`. The 9B model does not always think to use its tools; asking for the tool by name fixes it.

## 10. DM pairing test

- Opened a DM from the bot's profile card (member list → OpenClaw Homelab Test → "Message @OpenClaw Homelab Test"). The new server allowed DMs from members by default; no Privacy Settings change needed.
- DM "Hi, this is a direct message test." → bot: "OpenClaw: access not configured. Your Discord user id: … Pairing code: ADCLMMCL. Ask the bot owner to approve with: openclaw pairing approve discord ADCLMMCL" (screenshot `09-dm-pairing-code.jpg`). The model is not called for unpaired users.
- Approve on the server (works with `exec` while the gateway runs, unlike onboarding):
  ```bash
  docker compose exec openclaw-gateway node dist/index.js pairing list discord
  docker compose exec openclaw-gateway node dist/index.js pairing approve discord <CODE>
  ```
  Output: "Approved discord sender <id>." and "Command owner configured discord:<id> (commands.ownerAllowFrom was empty)." — the first approved user also becomes the command owner.
- Next DM "Paired now? ... what time zone are you set to?" → "Asia/Karahi (GMT+5)." (screenshot `10-dm-after-pairing.jpg`). Paired and working; `OPENCLAW_TZ=Asia/Karachi` reached the agent. The model misspelled Karachi.

## 11. Control UI (web chat)

- `http://127.0.0.1:18789/` → "This Gateway expects its token". Hint on the page: `openclaw gateway auth-token --show`. With the Docker setup the token is `OPENCLAW_GATEWAY_TOKEN` in the repo's `.env` (64 chars). Pasted it into **Gateway secret** → **Connect**.
- The UI lists the Discord sessions (#general group, DM), shows the model (qwen3.5:9b), context use (68–69 %), and one automation: **heartbeat-main, every 30 min** (the agent wakes on a schedule, so the model gets called even when nobody chats).
- New session: "List the files in your workspace folder, one per line." → AGENTS.md, SOUL.md, IDENTITY.md, USER.md; "23 output tokens · Done in 5 seconds" (screenshot `11-control-ui-chat.jpg`).
  - Incomplete: the folder also had `homelab-test.md` and a `memory/` folder. The model answered from the files injected into its prompt instead of listing the folder. BOOTSTRAP.md was deleted by OpenClaw after the first run.

## 12. Exposure and resource check

- `curl http://<LAN-IP>:18789/` → connection refused; `curl http://127.0.0.1:18789/` → 200. Only this machine can reach the gateway.
- Gateway container idle: CPU 0.2 %, RAM 2.4 GB.
- `openclaw-data` on disk: 131 MB. Image: 2.93 GB.
- GPU: 15.1 GB used with qwen3.5:9b + qwen3-embedding:4b loaded (plus desktop apps).
