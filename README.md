<div align="center">
<img src="admin/public/rhinovault_logo.webp" width="200" height="200"/>

# RhinoVault
### Your Knowledge, Locked In — Never Locked Out

**Offline-First Knowledge & AI, Anywhere**

[![License](https://img.shields.io/badge/License-Apache%202.0-blue)](LICENSE)
[![Fork of Project N.O.M.A.D.](https://img.shields.io/badge/fork%20of-Project%20N.O.M.A.D.-8a8a8a)](https://github.com/Crosstalk-Solutions/project-nomad)

</div>

---

RhinoVault is a self-contained, offline-first knowledge and education server packed with
critical tools, knowledge, and AI to keep you informed and empowered — anytime, anywhere,
no internet connection required once it's set up.

> RhinoVault is a fork of [Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad)
> by Crosstalk Solutions, licensed under Apache-2.0. See [NOTICE](NOTICE) for attribution details.
> RhinoVault is an independent project and is not affiliated with or endorsed by Crosstalk Solutions.

## Installation & Quickstart

RhinoVault can be installed on any Debian-based operating system (Ubuntu recommended).
Installation is completely terminal-based, and all tools are accessed through the browser —
no desktop environment needed if you're running RhinoVault as a headless server.

*Note: sudo/root privileges are required to run the install script*

### Quick Install (Debian-based OS only)

```bash
sudo apt-get update && \
sudo apt-get install -y curl && \
curl -fsSL https://raw.githubusercontent.com/<your-username>/rhinovault/refs/heads/main/install/install_rhinovault.sh \
  -o install_rhinovault.sh && \
sudo bash install_rhinovault.sh
```

Once installed, open a browser and navigate to `http://localhost:8080` (or `http://DEVICE_IP:8080`).

### Advanced Installation

For more control, copy the [Docker Compose template](install/management_compose.yaml) into a
`docker-compose.yml` file, customize it, and run `docker compose up -d`. Recommended for advanced
users familiar with Docker.

## How It Works

RhinoVault is a management UI ("Vault Console") and API that orchestrates a collection of
containerized tools and resources via [Docker](https://www.docker.com/). It handles
installation, configuration, and updates for everything — so you don't have to.

**Built-in capabilities include:**

- **AI Chat with Knowledge Base** — local AI chat powered by [Ollama](https://ollama.com/) or any OpenAI-compatible server, with document upload and semantic search (RAG via [Qdrant](https://qdrant.tech/))
- **Information Library** — offline Wikipedia, medical references, ebooks, and more via [Kiwix](https://kiwix.org/)
- **Education Platform** — Khan Academy courses with progress tracking via [Kolibri](https://learningequality.org/kolibri/)
- **Offline Maps** — downloadable regional maps via [ProtoMaps](https://protomaps.com)
- **Data Tools** — encryption, encoding, and analysis via [CyberChef](https://gchq.github.io/CyberChef/)
- **Notes** — local note-taking via [FlatNotes](https://github.com/dullage/flatnotes)
- **System Benchmark** — hardware scoring with a community leaderboard
- **Supply Depot** — a one-click app catalog, plus the ability to run your own custom Docker containers
- **Automatic Updates** — opt-in, hands-off updates on a schedule you control
- **Easy Setup Wizard** — guided first-time configuration with curated content collections

## What's Included

| Capability | Powered By | What You Get |
|-----------|-----------|-------------|
| Information Library | Kiwix | Offline Wikipedia, medical references, survival guides, ebooks |
| AI Assistant | Ollama + Qdrant | Built-in chat with document upload and semantic search |
| Education Platform | Kolibri | Khan Academy courses, progress tracking, multi-user support |
| Offline Maps | ProtoMaps | Downloadable regional maps for offline viewing and search |
| Data Tools | CyberChef | Encryption, encoding, hashing, and data analysis |
| Notes | FlatNotes | Local note-taking with markdown support |
| System Benchmark | Built-in | Hardware scoring and community leaderboard |
| Supply Depot | Built-in | One-click app catalog + bring-your-own custom Docker containers |

## Device Requirements

#### Minimum Specs
- Processor: 2 GHz dual-core processor or better
- RAM: 4GB system memory
- Storage: At least 5 GB free disk space
- OS: Debian-based (Ubuntu recommended)
- Stable internet connection (required during install only)

#### Optimal Specs (for AI features)
- Processor: AMD Ryzen 7 or Intel Core i7 or better
- RAM: 32 GB system memory
- Graphics: NVIDIA RTX 3060 or AMD equivalent or better (more VRAM = larger models)
- Storage: At least 250 GB free disk space (preferably on SSD)

RhinoVault itself is lightweight — it's the tools and resources you choose to install that
determine the specs required for your unique deployment.

#### Running AI models on a different host
By default, the installer sets up Ollama on the host when the AI Assistant is installed. To
run the model elsewhere, set a URL for an Ollama or OpenAI-compatible API server (e.g. LM Studio)
in the AI assistant settings. If using Ollama remotely, start it with `OLLAMA_HOST=0.0.0.0`.

## About Internet Usage & Privacy

RhinoVault is designed for offline usage. An internet connection is only required during
initial installation and when downloading additional content later. RhinoVault has zero
built-in telemetry.

## About Security

By design, RhinoVault is intended to be open and available without hurdles — it includes no
authentication by default. If you connect your device to a local network, use network-level
controls (firewall/port rules) to manage access. RhinoVault is not designed to be exposed
directly to the internet.

## License & Attribution

RhinoVault is licensed under the [Apache License 2.0](LICENSE). It is a derivative work of
[Project N.O.M.A.D.](https://github.com/Crosstalk-Solutions/project-nomad) by Crosstalk
Solutions, also Apache-2.0 licensed. See [NOTICE](NOTICE) for full attribution.

## Helper Scripts

Once installed, RhinoVault has a few helper scripts for troubleshooting or maintenance, found
in the install directory `/opt/rhinovault`:

```bash
sudo bash /opt/rhinovault/start_rhinovault.sh    # Start all installed containers
sudo bash /opt/rhinovault/stop_rhinovault.sh     # Stop all installed containers
sudo bash /opt/rhinovault/update_rhinovault.sh   # Update Vault Console + dependencies
```

Uninstall (cannot be undone):
```bash
curl -fsSL https://raw.githubusercontent.com/<your-username>/rhinovault/refs/heads/main/install/uninstall_rhinovault.sh -o uninstall_rhinovault.sh && sudo bash uninstall_rhinovault.sh
```
