# Tempo node installation with the script

Step-by-step guide to installing a Tempo (moderato, mainnet) RPC or Validator node using `install-tempo.sh`. The script automates Docker setup, snapshot download, downgrade, and Telegram notifications.

---

## Mandatory: use screen or tmux for snapshot and downgrade

**Before running option 3 (Snapshot) or option 4 (Downgrade)**, always run the script inside a **screen** or **tmux** session.

- Downloading and extracting a snapshot takes **a long time** (tens of minutes or more).
- If your SSH session drops, the process will stop and you will have to start over.
- In a screen/tmux session the script keeps running after you disconnect, and you can reattach later.

**For all other actions** (install without snapshot, view logs, stop/start container, etc.) screen or tmux is not required.

Examples:

```bash
# Option 1: screen
screen -S tempo
# then run the one-line command or ./install-tempo.sh
# Choose 3 or 4. Detach: Ctrl+A, then D. Reattach: screen -r tempo

# Option 2: tmux
tmux new -s tempo
# then run the one-line command or ./install-tempo.sh
# Choose 3 or 4. Detach: Ctrl+B, then D. Reattach: tmux attach -t tempo
```

---

## Telegram notifications

To get a notification when **option 3 (Snapshot)** or **option 4 (Downgrade)** finishes, add to your **.env-tempo** file (in the script directory or in `$TEMPO_HOME`):

- **TG_BOT_TOKEN** — token from a bot created via [@BotFather](https://t.me/BotFather).
- **TG_CHAT_ID** — your chat ID (e.g. from [@userinfobot](https://t.me/userinfobot) or getUpdates after sending a message to the bot).

The script **creates** `.env-tempo` in `$TEMPO_HOME` when you install a node (option 1 or 2). **Edit that file after installation** to add `TG_BOT_TOKEN` and `TG_CHAT_ID`, or to change ports / `TEMPO_HOME`.

Example in `.env-tempo`:

```env
TG_BOT_TOKEN=123456789:ABCdefGHI...
TG_CHAT_ID=123456789
```

When snapshot download/extract or downgrade completes, the script will send a success message to that chat. Without these variables, no notifications are sent.

---

## Running the script

**One-line command** (download from GitHub, set executable, run):

```bash
curl -o install-tempo.sh https://raw.githubusercontent.com/pittpv/tempo-node/main/install-tempo.sh && chmod +x install-tempo.sh && ./install-tempo.sh
```

For subsequent runs:

```bash
cd $HOME && ./install-tempo.sh
```

(or from the directory where you saved the script)

---

## The .env-tempo file: load order and variables

The script loads config in this order: first `SCRIPT_DIR/.env-tempo` (script directory), then `$TEMPO_HOME/.env-tempo` (values in the second file override the first). When you install a node (option 1 or 2), the script **creates** `.env-tempo` in `$TEMPO_HOME` if it does not exist (from `.env.example`). **After installation**, edit that file as needed.

**Common variables** (any node):
- `CHAIN` — network: `moderato` (testnet) or `mainnet`
- `TEMPO_HOME` — node root directory (default `$HOME/tempo`)
- `TEMPO_IMAGE` — Docker image (e.g. `ghcr.io/tempoxyz/tempo:1.1.4`)
- `TG_BOT_TOKEN`, `TG_CHAT_ID` — Telegram notifications when options 3 and 4 complete
- `SCRIPT_URL` — URL of the installer script for update checks (option 8)
- `SNAPSHOTS_API` — snapshots API URL (default is official)

**RPC node only** (option 1): default ports are fine when running a single node.
- `RPC_HTTP_PORT`, `RPC_WS_PORT`, `RPC_P2P_PORT`, `RPC_DISCOVERY_PORT`, `RPC_METRICS_PORT` (defaults 8545, 8546, 30303, 30303, 9000)

**Validator node only** (option 2):
- `VALIDATOR_HTTP_PORT`, `VALIDATOR_WS_PORT`, `VALIDATOR_P2P_PORT`, `VALIDATOR_CONSENSUS_PORT`, `VALIDATOR_DISCOVERY_PORT`, `VALIDATOR_METRICS_PORT` (defaults 8545, 8546, 30303, 8000, 30303, 9000)

**If both RPC and Validator are on the same server**, set **different ports** for the validator in `.env-tempo` to avoid conflicts (e.g. `VALIDATOR_HTTP_PORT=8547`, `VALIDATOR_P2P_PORT=30304`). See the section below on running both nodes on one machine.

---

## RPC and Validator on the same server

**Running RPC and Validator on one server is not recommended**: two nodes increase load on CPU, disk, and memory. The script **allows** installing both on one machine if resources are sufficient.

**When both are installed:**
- RPC lives in `$TEMPO_HOME/rpc`, Validator in `$TEMPO_HOME/validator`; containers are `tempo-rpc` and `tempo-validator`.
- In `.env-tempo` you must set different ports for the Validator (see above), or the second node will fail to bind.
- Options **4** (Downgrade), **6** (Logs), **7** (Remove), **9** (Stop), **10** (Start), **11** (Check sync), **12** (Disk usage) show a **“Which node?”** menu: choose **1) RPC** or **2) Validator**. Each option shows the container status (running / stopped). You can manage each node separately: stop, start, snapshot, or downgrade one node, view its logs, etc.
- **0) Return to main menu** in that menu returns to the main menu without running an action.

---

## Initial setup

1. The script checks for Docker and Docker Compose and will prompt to install if needed. Accept when appropriate (`y`).

2. In the main menu, choose the language if prompted.

3. To install a node:
   - **Option 1** — **RPC Node**: chain sync and API only; no validator key or whitelist. Runs with `--follow`.
   - **Option 2** — **Validator Node**: consensus and block production; requires consensus signing key and whitelist. The script will ask for **FEE_RECIPIENT** (EVM address for rewards) and will generate the signing key on first install if it does not exist.

---

## Installing RPC Node (option 1)

1. Choose **1** (Install Tempo RPC Node) in the menu.
2. The script checks RPC ports: HTTP (8545), WebSocket (8546), P2P (30303), metrics (9000). If any are in use, set `RPC_HTTP_PORT`, `RPC_WS_PORT`, `RPC_P2P_PORT`, `RPC_METRICS_PORT` in `.env-tempo` and run again.
3. It creates `$TEMPO_HOME/rpc` (default `$HOME/tempo/rpc`) with `data`, `keys`, `docker-compose.yml`, and a node-type marker. **No consensus key is created** for RPC (it runs with `--follow`, no block signing).
4. The script creates `.env-tempo` in `$TEMPO_HOME` if missing, pulls the image, and starts the `tempo-rpc` container.
5. You can use the node as-is (sync from genesis) or run **option 3** (Snapshot) in **screen/tmux** to speed up sync.

After installation, RPC is available at e.g. `http://0.0.0.0:8545` (or the ports in `.env-tempo`).

---

## Installing Validator Node (option 2)

1. Choose **2** (Install Tempo Validator Node) in the menu.
2. The script asks for **FEE_RECIPIENT** — EVM address (with 0x) for rewards. It then checks validator ports: HTTP, WebSocket, P2P, Consensus (8000), metrics. If any are in use, set `VALIDATOR_HTTP_PORT`, `VALIDATOR_P2P_PORT`, `VALIDATOR_CONSENSUS_PORT`, etc. in `.env-tempo` and run again.
3. It creates `$TEMPO_HOME/validator` with `data` and `keys`. If `keys/signing.key` does not exist, the script **generates** the consensus signing key (`consensus generate-private-key`).
4. It creates `docker-compose.yml` for the `tempo-validator` container, mounts data and keys, and creates `.env-tempo` in `$TEMPO_HOME` if missing.
5. Running **option 3** (Snapshot) in **screen/tmux** before the first full run is recommended to speed up sync.

---

## Snapshot (option 3) — run in screen or tmux

1. **Start the script in screen or tmux** (see section above).
2. In the main menu choose **3** (Snapshot).
3. Select the node (RPC or Validator) if both are installed.
4. Choose snapshot source:
   - **0** or Enter — latest from API;
   - **u** — enter snapshot URL manually;
   - **e** — path to local `.tar.lz4` file;
   - A number from the list — pick by index.
5. The script stops the container, downloads and extracts the snapshot, then restarts the node.
6. If **TG_BOT_TOKEN** and **TG_CHAT_ID** are set in .env-tempo, you will get a Telegram notification when done.

---

## Downgrade (option 4) — recommended in screen or tmux

1. Prefer running the script in **screen** or **tmux**.
2. In the main menu choose **4** (Downgrade).
3. Select the node (RPC or Validator).
4. Pick a version from the list or enter a custom tag (e.g. `1.1.0`).
5. The script stops the container, updates the image if needed, and restarts. With Telegram configured you get a completion notification.

---

## Other options

- **5** — show node/image version (for selected RPC or Validator).
- **6** — view logs of the selected node (exit with Ctrl+C).
- **7** — remove node: container only (data and keys kept) or full removal including data and keys.
- **8** — **Check for updates**: shows the installer script version; if **SCRIPT_URL** is set in `.env-tempo` (URL of the script on GitHub or elsewhere), it checks for a newer installer version. It also shows the latest Tempo node version from GitHub and compares it with your installed node (if a newer version exists, it suggests running option 4 Downgrade to update the node). Updating the installer itself is done separately (e.g. `./install-tempo.sh -U` when SCRIPT_URL is set).
- **9 / 10** — stop or start the selected node’s container; the “Which node?” menu shows each container’s status (running / stopped).
- **11** — check sync and blocks (selected node’s RPC: peers, block height, eth_syncing, etc.).
- **12** — check disk usage (selected node’s data and keys).

---

## Summary

| Action | Screen/tmux | Telegram in .env-tempo |
|--------|--------------|------------------------|
| Install RPC/Validator (1, 2) | Not required | Optional (edit file after install) |
| Snapshot (3) | **Required** | Recommended (completion notification) |
| Downgrade (4) | **Recommended** | Recommended (completion notification) |
| Other options | Not required | Not needed |

Good luck with your node.

> **If you have questions about the script**, ask in the Telegram support chat: [https://t.me/+DLsyG6ol3SFjM2Vk](https://t.me/+DLsyG6ol3SFjM2Vk)
