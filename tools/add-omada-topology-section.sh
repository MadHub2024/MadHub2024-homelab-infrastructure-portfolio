#!/usr/bin/env bash
set -Eeuo pipefail

REPO="$HOME/MadHub2024-homelab-infrastructure-portfolio"
cd "$REPO"

IMAGE="assets/images/OmadaTopology.png"

[[ -f index.html ]] || {
  echo "ERROR: index.html not found."
  exit 1
}

[[ -f "$IMAGE" ]] || {
  echo "ERROR: $IMAGE not found."
  exit 1
}

if grep -q 'assets/images/OmadaTopology.png' index.html; then
  echo "Omada topology section is already present."
  exit 0
fi

cp -a index.html "index.html.backup-$(date +%Y%m%d-%H%M%S)"

python3 <<'PY'
from pathlib import Path

path = Path("index.html")
html = path.read_text(encoding="utf-8")

marker = "      <!-- MONITORING-OBSERVABILITY-COLLAGE:START -->"

block = '''      <h3>Live Omada SDN Topology</h3>

      <figure class="dashboard-card">
        <a
          href="assets/images/OmadaTopology.png"
          class="dashboard-trigger"
          target="_blank"
          rel="noopener noreferrer">
          <img
            src="assets/images/OmadaTopology.png"
            alt="Live TP-Link Omada SDN topology showing the gateway, backbone switch, managed switches, access points, controller, and connected infrastructure"
            class="dashboard-image"
            loading="lazy"
            decoding="async">
        </a>

        <figcaption>
          <strong>Live TP-Link Omada SDN Topology.</strong>
          Current network topology showing the ER7412 gateway, SX3008F
          backbone switch, managed switches, wireless access points, Omada
          controller, and connected infrastructure. Used to verify physical
          connectivity, uplink status, device placement, and network health.
          Select the image to open the full-resolution version.
        </figcaption>
      </figure>

'''

if marker not in html:
    raise SystemExit("ERROR: Monitoring collage marker not found.")

html = html.replace(marker, block + marker, 1)
path.write_text(html, encoding="utf-8")
print("Live Omada topology section added.")
PY

if [[ -x tools/validate.sh ]]; then
  tools/validate.sh
else
  git diff --check
fi

echo
grep -n -A 28 -B 5 "Live Omada SDN Topology" index.html
