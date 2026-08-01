#!/usr/bin/env bash
set -Eeuo pipefail

REPO="$HOME/MadHub2024-homelab-infrastructure-portfolio"
STAMP="$(date +%Y%m%d-%H%M%S)"

cd "$REPO"

FILES=(
  "vaultwarden-recovery.html"
  "dns-migration.html"
  "vlan-deployment.html"
  "monitoring-platform.html"
)

for file in "${FILES[@]}"; do
  [[ -f "$file" ]] || {
    echo "ERROR: Missing required file: $file"
    exit 1
  }

  cp -a "$file" "${file}.backup-${STAMP}"
done

python3 <<'PY'
from pathlib import Path
import re

START = "<!-- PROJECT-CONTEXT:START -->"
END = "<!-- PROJECT-CONTEXT:END -->"

blocks = {
    "vaultwarden-recovery.html": """
      <!-- PROJECT-CONTEXT:START -->
      <section>
        <h2>Project metadata</h2>
        <dl class="incident-facts">
          <div><dt>Role</dt><dd>Sole Infrastructure Engineer</dd></div>
          <div><dt>Environment</dt><dd>Self-hosted Docker infrastructure</dd></div>
          <div><dt>Systems</dt><dd>Linux, Docker Compose, Vaultwarden, SQLite, Caddy</dd></div>
          <div><dt>Project type</dt><dd>Incident recovery and service hardening</dd></div>
          <div><dt>Duration</dt><dd>Same-day recovery and validation</dd></div>
          <div><dt>Outcome</dt><dd>Service restored, database validated, and recovery workflow improved</dd></div>
        </dl>
      </section>

      <section>
        <h2>Business problem</h2>
        <p>
          Vaultwarden stored administrative credentials used across the
          homelab. The missing application container made those credentials
          temporarily unavailable, creating an operational dependency that had
          to be restored without damaging the persistent encrypted database.
        </p>
      </section>

      <section>
        <h2>Success criteria</h2>
        <ul>
          <li>Protect the existing Vaultwarden data before making changes.</li>
          <li>Verify that the SQLite database was structurally sound.</li>
          <li>Recreate the application without replacing the persistent vault.</li>
          <li>Confirm container health and an HTTP 200 application response.</li>
          <li>Document a repeatable backup, recovery, and validation process.</li>
        </ul>
      </section>
      <!-- PROJECT-CONTEXT:END -->
""",
    "dns-migration.html": """
      <!-- PROJECT-CONTEXT:START -->
      <section>
        <h2>Project metadata</h2>
        <dl class="incident-facts">
          <div><dt>Role</dt><dd>Sole Infrastructure Engineer</dd></div>
          <div><dt>Environment</dt><dd>Multi-server Linux infrastructure</dd></div>
          <div><dt>Systems</dt><dd>Technitium DNS, AdGuard Home, Docker, Linux, encrypted upstream DNS</dd></div>
          <div><dt>Project type</dt><dd>DNS architecture migration</dd></div>
          <div><dt>Duration</dt><dd>Multi-phase migration and troubleshooting</dd></div>
          <div><dt>Outcome</dt><dd>Centralized layered DNS with validated internal and external resolution</dd></div>
        </dl>
      </section>

      <section>
        <h2>Business problem</h2>
        <p>
          The environment had outgrown a single filtering resolver. Multiple
          internal namespaces, VLANs, Linux hosts, and Docker workloads required
          authoritative local DNS, consistent forwarding, and a clear way to
          isolate resolution failures from filtering or application problems.
        </p>
      </section>

      <section>
        <h2>Success criteria</h2>
        <ul>
          <li>Make Technitium DNS the standard first resolver for clients and servers.</li>
          <li>Preserve AdGuard Home filtering and encrypted upstream resolution.</li>
          <li>Provide authoritative answers for three internal DNS zones.</li>
          <li>Eliminate SERVFAIL errors caused by missing internal zones or records.</li>
          <li>Validate each stage independently with direct DNS queries.</li>
        </ul>
      </section>
      <!-- PROJECT-CONTEXT:END -->
""",
    "vlan-deployment.html": """
      <!-- PROJECT-CONTEXT:START -->
      <section>
        <h2>Project metadata</h2>
        <dl class="incident-facts">
          <div><dt>Role</dt><dd>Sole Network Administrator</dd></div>
          <div><dt>Environment</dt><dd>Enterprise-style segmented homelab</dd></div>
          <div><dt>Systems</dt><dd>TP-Link Omada, ER7412, SX3008F, OC300, Linux servers</dd></div>
          <div><dt>Project type</dt><dd>Network design, segmentation, and access control</dd></div>
          <div><dt>Duration</dt><dd>Multi-stage deployment and policy validation</dd></div>
          <div><dt>Outcome</dt><dd>7+ segmented networks with controlled routing, ACLs, DNS, and mDNS</dd></div>
        </dl>
      </section>

      <section>
        <h2>Business problem</h2>
        <p>
          Infrastructure, management systems, workstations, IoT devices,
          media clients, printers, guests, and lab systems required different
          trust levels. The network needed stronger isolation without breaking
          DNS, administration, printing, media discovery, or automation.
        </p>
      </section>

      <section>
        <h2>Success criteria</h2>
        <ul>
          <li>Separate device classes into dedicated VLANs and subnets.</li>
          <li>Use default-deny inter-VLAN policy with narrow documented exceptions.</li>
          <li>Keep centralized DNS available from every approved client network.</li>
          <li>Preserve required AirPrint, AirPlay, HomeKit, Hubitat, and management workflows.</li>
          <li>Verify both allowed traffic and expected denials from the actual source VLAN.</li>
        </ul>
      </section>
      <!-- PROJECT-CONTEXT:END -->
""",
    "monitoring-platform.html": """
      <!-- PROJECT-CONTEXT:START -->
      <section>
        <h2>Project metadata</h2>
        <dl class="incident-facts">
          <div><dt>Role</dt><dd>Sole Infrastructure Engineer</dd></div>
          <div><dt>Environment</dt><dd>Hybrid native and Docker infrastructure</dd></div>
          <div><dt>Systems</dt><dd>Grafana, Prometheus, LibreNMS, Uptime Kuma, Node Exporter, cAdvisor</dd></div>
          <div><dt>Project type</dt><dd>Monitoring and observability implementation</dd></div>
          <div><dt>Duration</dt><dd>Incremental multi-platform deployment</dd></div>
          <div><dt>Outcome</dt><dd>Layered visibility across hosts, containers, services, DNS, and network devices</dd></div>
        </dl>
      </section>

      <section>
        <h2>Business problem</h2>
        <p>
          Service availability alone did not explain host pressure, container
          behavior, DNS failures, or network-device health. The environment
          needed correlated visibility across multiple operational layers so
          incidents could be scoped and diagnosed with evidence.
        </p>
      </section>

      <section>
        <h2>Success criteria</h2>
        <ul>
          <li>Monitor critical application endpoints and response behavior.</li>
          <li>Collect Linux host and Docker container resource metrics.</li>
          <li>Add network-device and SNMP-oriented visibility.</li>
          <li>Correlate DNS, host, container, and application evidence during troubleshooting.</li>
          <li>Publish sanitized dashboard evidence without exposing sensitive infrastructure details.</li>
        </ul>
      </section>
      <!-- PROJECT-CONTEXT:END -->
""",
}

def remove_managed_block(html: str) -> str:
    pattern = re.compile(
        re.escape(START) + r".*?" + re.escape(END),
        re.DOTALL,
    )
    return pattern.sub("", html)

def insert_after_executive_summary(html: str, block: str, filename: str) -> str:
    executive = re.search(
        r'(<section[^>]*>\s*<h2[^>]*>\s*Executive summary\s*</h2>.*?</section>)',
        html,
        flags=re.IGNORECASE | re.DOTALL,
    )

    if not executive:
        raise SystemExit(
            f"ERROR: Could not locate Executive summary section in {filename}."
        )

    insertion = executive.group(1) + "\n\n" + block.strip("\n")
    return html[:executive.start()] + insertion + html[executive.end():]

for filename, block in blocks.items():
    path = Path(filename)
    html = path.read_text(encoding="utf-8")
    html = remove_managed_block(html)
    html = insert_after_executive_summary(html, block, filename)
    path.write_text(html.rstrip() + "\n", encoding="utf-8")
    print(f"Updated: {filename}")
PY

echo
echo "Running validation..."

if [[ -x tools/validate.sh ]]; then
  ./tools/validate.sh
else
  git diff --check
fi

echo
echo "Project metadata, business problem, and success criteria added."
echo
git diff --stat -- "${FILES[@]}"

echo
echo "Verify with:"
echo "  grep -n -A 45 -B 3 'Project metadata' \\"
echo "    vaultwarden-recovery.html dns-migration.html \\"
echo "    vlan-deployment.html monitoring-platform.html"
