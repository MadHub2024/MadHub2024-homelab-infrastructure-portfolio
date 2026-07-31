#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(git -C "$SCRIPT_DIR/.." rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: Could not locate the Git repository."
  exit 1
}

cd "$REPO"

INDEX="index.html"
PAGE="dns-migration.html"
STAMP="$(date +%Y%m%d-%H%M%S)"

[[ -f "$INDEX" ]] || {
  echo "ERROR: Missing index.html"
  exit 1
}

cp -a "$INDEX" "${INDEX}.backup-${STAMP}"
[[ ! -f "$PAGE" ]] || cp -a "$PAGE" "${PAGE}.backup-${STAMP}"

cat > "$PAGE" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Layered DNS Migration Case Study | Denny Brathwaite</title>
  <meta
    name="description"
    content="Case study documenting the migration to a layered Technitium DNS and AdGuard Home architecture."
  >
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <a class="skip-link" href="#main">Skip to case study</a>

  <header class="site-header">
    <div class="container incident-nav">
      <a class="incident-brand" href="index.html">
        <span aria-hidden="true">DB</span>
        <span>Denny Brathwaite</span>
      </a>
      <nav aria-label="Case study navigation">
        <a href="index.html#case-studies">All case studies</a>
      </nav>
    </div>
  </header>

  <main id="main">
    <section class="incident-hero">
      <div class="container incident-container">
        <p class="incident-eyebrow">Case Study 02 · DNS Architecture</p>
        <h1>Migration to a Layered DNS Architecture</h1>
        <p class="incident-lead">
          Moving the homelab from a single filtering resolver to a two-stage
          DNS design using Technitium DNS for authoritative internal resolution
          and AdGuard Home for filtering and encrypted upstream forwarding.
        </p>

        <div class="incident-tags" aria-label="Technologies used">
          <span>Technitium DNS</span>
          <span>AdGuard Home</span>
          <span>Linux</span>
          <span>Docker</span>
          <span>DNS zones</span>
          <span>dig</span>
          <span>DoH</span>
        </div>
      </div>
    </section>

    <article class="container incident-container incident-report">
      <section>
        <h2>Executive summary</h2>
        <p>
          The original DNS design relied primarily on AdGuard Home for local
          resolution, filtering, and upstream forwarding. As the environment
          grew across multiple VLANs and internal namespaces, DNS management
          became harder to scale and troubleshoot.
        </p>

        <p>
          Technitium DNS was introduced as the first resolver for all clients.
          It became responsible for internal zones, authoritative records,
          caching, and query handling. AdGuard Home remained downstream as the
          filtering and encrypted-upstream layer.
        </p>

        <div class="incident-callout">
          <strong>Final path:</strong>
          Clients → Technitium DNS → AdGuard Home → encrypted upstream DNS.
        </div>
      </section>

      <section>
        <h2>Environment</h2>
        <dl class="incident-facts">
          <div><dt>Primary resolver</dt><dd>Technitium DNS</dd></div>
          <div><dt>Primary resolver IP</dt><dd><code>10.10.40.4</code></dd></div>
          <div><dt>Filtering resolver</dt><dd>AdGuard Home</dd></div>
          <div><dt>Filtering resolver IP</dt><dd><code>10.10.40.2</code></dd></div>
          <div><dt>Internal zones</dt><dd><code>home</code>, <code>dbservices</code>, <code>dbservicessolutions.org</code></dd></div>
          <div><dt>Client networks</dt><dd>Multiple routed VLANs</dd></div>
          <div><dt>Validation tools</dt><dd><code>dig</code>, <code>curl</code>, DNS logs</dd></div>
          <div><dt>Upstream security</dt><dd>Encrypted DNS through AdGuard</dd></div>
        </dl>
      </section>

      <section>
        <h2>Problem</h2>
        <ul>
          <li>Local service names depended on a growing set of rewrites.</li>
          <li>Multiple internal namespaces needed consistent authoritative answers.</li>
          <li>Some queries returned <strong>SERVFAIL</strong> during the transition.</li>
          <li>Container and host DNS behavior was not consistently aligned.</li>
          <li>Troubleshooting required clear separation between resolution and filtering.</li>
        </ul>
      </section>

      <section>
        <h2>Design decision</h2>
        <p>
          The DNS responsibilities were separated by function:
        </p>

        <ol class="incident-timeline">
          <li>
            <strong>Technitium DNS</strong>
            <span>
              Receives client queries, hosts internal zones, returns local
              records, caches responses, and forwards unresolved queries.
            </span>
          </li>
          <li>
            <strong>AdGuard Home</strong>
            <span>
              Applies filtering policy and forwards external requests through
              encrypted upstream DNS.
            </span>
          </li>
          <li>
            <strong>Clients and containers</strong>
            <span>
              Use Technitium first so every query follows the same controlled path.
            </span>
          </li>
        </ol>
      </section>

      <section>
        <h2>Migration timeline</h2>
        <ol class="incident-timeline">
          <li><strong>Baseline testing</strong><span>Verified direct resolution through AdGuard Home and documented current behavior.</span></li>
          <li><strong>Technitium deployment</strong><span>Added Technitium DNS on the DellServer and configured forwarding to AdGuard Home.</span></li>
          <li><strong>Client migration</strong><span>Changed LAN clients and server resolver settings to use <code>10.10.40.4</code>.</span></li>
          <li><strong>Zone creation</strong><span>Created the <code>home</code>, <code>dbservices</code>, and <code>dbservicessolutions.org</code> zones.</span></li>
          <li><strong>SERVFAIL investigation</strong><span>Reviewed query behavior and identified missing authoritative zones as the cause of failed internal lookups.</span></li>
          <li><strong>Record validation</strong><span>Added service records and tested each namespace with <code>dig</code>.</span></li>
          <li><strong>Path confirmation</strong><span>Confirmed external queries flowed from Technitium to AdGuard Home and then upstream.</span></li>
        </ol>
      </section>

      <section>
        <h2>Diagnosis and evidence</h2>

        <h3>Direct resolver testing</h3>
        <pre><code>dig @10.10.40.4 dashboard.dbservices
dig @10.10.40.4 dashboard.dbservicessolutions.org
dig @10.10.40.2 google.com</code></pre>

        <h3>Client path verification</h3>
        <pre><code>dig google.com

;; SERVER: 10.10.40.4#53</code></pre>

        <p>
          This confirmed that the client was querying Technitium rather than
          bypassing it and going directly to AdGuard Home.
        </p>

        <h3>SERVFAIL root cause</h3>
        <p>
          Internal names failed when Technitium did not yet host authoritative
          zones for every namespace in use. Adding the missing zones and records
          corrected the failures without enabling DNSSEC, which was not part of
          the active design.
        </p>
      </section>

      <section>
        <h2>Implementation</h2>
        <ul>
          <li>Set Technitium DNS as the primary resolver for LAN clients.</li>
          <li>Configured Technitium to forward unresolved queries to AdGuard Home.</li>
          <li>Created three internal DNS zones.</li>
          <li>Added A records for hosted services across all required namespaces.</li>
          <li>Aligned host and Docker DNS settings with the new resolver path.</li>
          <li>Retained AdGuard Home for filtering and encrypted upstream resolution.</li>
        </ul>
      </section>

      <section>
        <h2>Measured results</h2>
        <div class="incident-results">
          <article><strong>3</strong><span>internal DNS zones</span></article>
          <article><strong>2</strong><span>resolver stages</span></article>
          <article><strong>1</strong><span>standard client DNS path</span></article>
          <article><strong>0</strong><span>DNSSEC dependency</span></article>
        </div>
      </section>

      <section>
        <h2>Operational improvements</h2>
        <ul>
          <li>Documented the resolver chain and ownership of each DNS function.</li>
          <li>Standardized service records across three namespaces.</li>
          <li>Separated internal authority from filtering policy.</li>
          <li>Improved troubleshooting by testing each resolver independently.</li>
          <li>Reduced the risk of clients bypassing the intended DNS path.</li>
        </ul>
      </section>

      <section>
        <h2>Skills demonstrated</h2>
        <ul class="incident-skills">
          <li>DNS architecture</li>
          <li>Authoritative zone management</li>
          <li>Forwarding and caching</li>
          <li>Linux resolver configuration</li>
          <li>Network troubleshooting</li>
          <li>Service validation with dig</li>
          <li>Layered security design</li>
          <li>Technical documentation</li>
        </ul>
      </section>

      <nav class="incident-footer-nav" aria-label="Case study navigation">
        <a href="index.html#case-studies">← Back to portfolio</a>
        <a href="vaultwarden-recovery.html">Next: Vaultwarden recovery →</a>
      </nav>
    </article>
  </main>
</body>
</html>
HTML

python3 <<'PY'
from pathlib import Path
import re

path = Path("index.html")
html = path.read_text(encoding="utf-8")

pattern = re.compile(
    r'(<article class="case">(?:(?!</article>).)*?'
    r'<h3>Layered DNS architecture</h3>'
    r'(?:(?!</article>).)*?</article>)',
    re.DOTALL,
)

match = pattern.search(html)

if not match:
    raise SystemExit("ERROR: Could not locate the Layered DNS architecture card.")

card = match.group(1)

updated_card, count = re.subn(
    r'<a class="read-link" href="[^"]*">.*?</a>',
    '<a class="read-link" href="dns-migration.html">'
    'Read full case study →</a>',
    card,
    count=1,
    flags=re.DOTALL,
)

if count != 1:
    raise SystemExit("ERROR: Could not locate the DNS card link.")

html = html[:match.start()] + updated_card + html[match.end():]
path.write_text(html.rstrip() + "\n", encoding="utf-8")
PY

echo
echo "Running validation..."

if [[ -x tools/validate.sh ]]; then
  tools/validate.sh
else
  git diff --check
fi

echo
echo "DNS migration case study added."
echo
git status --short
echo
git diff --stat -- index.html dns-migration.html
