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

MARKER_START = "<!-- REFLECTION-SECTION:START -->"
MARKER_END = "<!-- REFLECTION-SECTION:END -->"

sections = {
    "vaultwarden-recovery.html": """
      <!-- REFLECTION-SECTION:START -->
      <section>
        <h2>Lessons learned</h2>
        <ul>
          <li>Persistent application data must be validated independently from container state.</li>
          <li>Creating a backup before recovery changes reduced the risk of turning an outage into data loss.</li>
          <li>A running container is not sufficient evidence of application readiness; endpoint and database checks are both required.</li>
          <li>Recovery procedures are stronger when rollback points, validation commands, and expected results are documented in advance.</li>
        </ul>

        <h2>What I would do differently</h2>
        <p>
          I would automate pre-upgrade backups, SQLite integrity checks, and
          post-deployment HTTP validation in a repeatable maintenance script.
          I would also store the administrative token as an Argon2 hash from
          the beginning and add a monitored backup-verification schedule.
        </p>
      </section>
      <!-- REFLECTION-SECTION:END -->
""",
    "dns-migration.html": """
      <!-- REFLECTION-SECTION:START -->
      <section>
        <h2>Lessons learned</h2>
        <ul>
          <li>Separating authoritative internal DNS from filtering made failures easier to isolate.</li>
          <li>Missing authoritative zones can present as broad application failures even when routing and service health are normal.</li>
          <li>Resolver migrations should be validated one layer at a time using direct queries against each DNS server.</li>
          <li>Client and container resolver settings must be audited together to prevent bypassing the intended DNS path.</li>
        </ul>

        <h2>What I would do differently</h2>
        <p>
          I would build and validate all internal zones before changing client
          DHCP settings, then migrate one VLAN at a time with a documented
          rollback plan. I would also automate zone exports, resolver health
          checks, and configuration backups before future DNS changes.
        </p>
      </section>
      <!-- REFLECTION-SECTION:END -->
""",
    "vlan-deployment.html": """
      <!-- REFLECTION-SECTION:START -->
      <section>
        <h2>Lessons learned</h2>
        <ul>
          <li>Default-deny segmentation works best when required traffic flows are documented before ACL deployment.</li>
          <li>mDNS and Bonjour must be treated as intentional exceptions rather than reasons to weaken segmentation.</li>
          <li>Testing from the actual source VLAN is essential because local tests can hide routing or ACL failures.</li>
          <li>DNS, routing, ACLs, and application readiness should be validated as separate layers.</li>
        </ul>

        <h2>What I would do differently</h2>
        <p>
          I would stage the VLAN rollout in smaller maintenance windows,
          maintain a formal source-to-destination traffic matrix, and validate
          each permit and deny rule with scripted tests. I would also export
          controller configuration before every major ACL or VLAN change.
        </p>
      </section>
      <!-- REFLECTION-SECTION:END -->
""",
    "monitoring-platform.html": """
      <!-- REFLECTION-SECTION:START -->
      <section>
        <h2>Lessons learned</h2>
        <ul>
          <li>No single monitoring tool provides complete visibility across applications, hosts, containers, DNS, and network devices.</li>
          <li>Availability monitoring and infrastructure telemetry answer different operational questions and should be correlated.</li>
          <li>Dashboards are most useful when they prioritize actionable signals instead of every available metric.</li>
          <li>Monitoring evidence should be paired with repeatable validation commands and documented response procedures.</li>
        </ul>

        <h2>What I would do differently</h2>
        <p>
          I would define service-level indicators and alert thresholds before
          building dashboards, then centralize notifications and logs earlier
          in the deployment. I would also automate configuration backups and
          create runbooks that map each alert to specific diagnostic steps.
        </p>
      </section>
      <!-- REFLECTION-SECTION:END -->
""",
}

def remove_existing(html: str) -> str:
    pattern = re.compile(
        re.escape(MARKER_START) + r".*?" + re.escape(MARKER_END),
        re.DOTALL,
    )
    return pattern.sub("", html)

def insert_before_skills(html: str, block: str, filename: str) -> str:
    patterns = [
        r'(?=\s*<section>\s*<h2>Skills demonstrated</h2>)',
        r'(?=\s*<section[^>]*>\s*<h2[^>]*>Skills demonstrated</h2>)',
    ]

    for pattern in patterns:
        updated, count = re.subn(
            pattern,
            "\n" + block.strip("\n") + "\n\n",
            html,
            count=1,
            flags=re.IGNORECASE | re.DOTALL,
        )
        if count == 1:
            return updated

    raise SystemExit(
        f"ERROR: Could not locate the 'Skills demonstrated' section in {filename}."
    )

for filename, block in sections.items():
    path = Path(filename)
    html = path.read_text(encoding="utf-8")
    html = remove_existing(html)
    html = insert_before_skills(html, block, filename)
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
echo "Reflection sections added to all four case studies."
echo
git diff --stat -- "${FILES[@]}"

echo
echo "Verify with:"
echo "  grep -n -A 18 -B 3 'What I would do differently' \\"
echo "    vaultwarden-recovery.html dns-migration.html \\"
echo "    vlan-deployment.html monitoring-platform.html"
