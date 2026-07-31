#!/usr/bin/env bash
set -Eeuo pipefail

REPO_DIR="${1:-$PWD}"
cd "$REPO_DIR"

for file in index.html styles.css script.js; do
  if [[ ! -f "$file" ]]; then
    printf 'ERROR: %s was not found in %s\n' "$file" "$PWD" >&2
    printf 'Run this from the repository root, or pass the repository path:\n' >&2
    printf '  %s ~/MadHub2024-homelab-infrastructure-portfolio\n' "$0" >&2
    exit 1
  fi
done

if [[ ! -d assets/images ]]; then
  printf 'ERROR: assets/images/ was not found in %s\n' "$PWD" >&2
  exit 1
fi

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir=".lightbox-backups/$timestamp"
mkdir -p "$backup_dir"
cp -a index.html styles.css script.js "$backup_dir/"
printf 'Backups created in %s\n' "$backup_dir"

python3 <<'PY'
from pathlib import Path
import html
import re

INDEX = Path("index.html")
CSS = Path("styles.css")
JS = Path("script.js")

HTML_START = "<!-- IMAGE LIGHTBOX: START -->"
HTML_END = "<!-- IMAGE LIGHTBOX: END -->"
CSS_START = "/* IMAGE LIGHTBOX: START */"
CSS_END = "/* IMAGE LIGHTBOX: END */"
JS_START = "/* IMAGE LIGHTBOX: START */"
JS_END = "/* IMAGE LIGHTBOX: END */"

index_text = INDEX.read_text(encoding="utf-8")
css_text = CSS.read_text(encoding="utf-8")
js_text = JS.read_text(encoding="utf-8")

img_pattern = re.compile(
    r'''<img\b(?=[^>]*\bsrc\s*=\s*["'](?:\./)?assets/images/[^"']+\.(?:png|jpe?g|webp|gif)["'])[^>]*>''',
    re.IGNORECASE | re.DOTALL,
)

anchor_with_img_pattern = re.compile(
    r'''<a\b(?P<attrs>[^>]*)>(?P<inner>\s*''' + img_pattern.pattern + r'''\s*)</a>''',
    re.IGNORECASE | re.DOTALL,
)

src_pattern = re.compile(
    r'''\bsrc\s*=\s*["'](?P<src>(?:\./)?assets/images/[^"']+\.(?:png|jpe?g|webp|gif))["']''',
    re.IGNORECASE,
)

def get_src(img_tag):
    match = src_pattern.search(img_tag)
    if not match:
        raise RuntimeError(f"Could not determine image source from: {img_tag[:120]}")
    return match.group("src")

def add_or_merge_class(attrs, class_name):
    class_match = re.search(r'''\bclass\s*=\s*(["'])(.*?)\1''', attrs, re.I | re.S)
    if class_match:
        classes = class_match.group(2).split()
        if class_name not in classes:
            classes.append(class_name)
        replacement = f'class={class_match.group(1)}{" ".join(classes)}{class_match.group(1)}'
        return attrs[:class_match.start()] + replacement + attrs[class_match.end():]
    return attrs.rstrip() + f' class="{class_name}"'

def ensure_attr(attrs, name, value):
    if re.search(rf'''\b{re.escape(name)}\s*=''', attrs, re.I):
        return attrs
    return attrs.rstrip() + f' {name}="{html.escape(value, quote=True)}"'

protected = []

def protect_existing_anchor(match):
    attrs = match.group("attrs")
    inner = match.group("inner")
    img_match = img_pattern.search(inner)
    if not img_match:
        return match.group(0)

    src = get_src(img_match.group(0))
    attrs = add_or_merge_class(attrs, "lightbox-trigger")
    attrs = ensure_attr(attrs, "data-lightbox-src", src)

    if not re.search(r'''\bhref\s*=''', attrs, re.I):
        attrs = ensure_attr(attrs, "href", src)

    token = f"___LIGHTBOX_PROTECTED_ANCHOR_{len(protected)}___"
    protected.append(f"<a{attrs}>{inner}</a>")
    return token

updated_index = anchor_with_img_pattern.sub(protect_existing_anchor, index_text)

wrapped_count = 0

def wrap_img(match):
    global wrapped_count
    img_tag = match.group(0)
    src = get_src(img_tag)
    wrapped_count += 1
    escaped = html.escape(src, quote=True)
    return (
        f'<a href="{escaped}" class="lightbox-trigger" '
        f'data-lightbox-src="{escaped}">{img_tag}</a>'
    )

updated_index = img_pattern.sub(wrap_img, updated_index)

for i, anchor in enumerate(protected):
    updated_index = updated_index.replace(
        f"___LIGHTBOX_PROTECTED_ANCHOR_{i}___", anchor
    )

modal_html = f'''
  {HTML_START}
  <div
    id="imageLightbox"
    class="image-lightbox"
    role="dialog"
    aria-modal="true"
    aria-label="Expanded image viewer"
    hidden
  >
    <button
      id="imageLightboxClose"
      class="image-lightbox__close"
      type="button"
      aria-label="Close expanded image"
    >&times;</button>

    <button
      id="imageLightboxBackdrop"
      class="image-lightbox__backdrop"
      type="button"
      tabindex="-1"
      aria-label="Close expanded image"
    ></button>

    <figure class="image-lightbox__figure">
      <img id="imageLightboxImage" class="image-lightbox__image" alt="" />
      <figcaption id="imageLightboxCaption" class="image-lightbox__caption"></figcaption>
    </figure>
  </div>
  {HTML_END}
'''

if HTML_START not in updated_index:
    if re.search(r"</body\s*>", updated_index, re.I):
        updated_index = re.sub(
            r"</body\s*>",
            modal_html + "\n</body>",
            updated_index,
            count=1,
            flags=re.I,
        )
    else:
        raise RuntimeError("index.html has no closing </body> tag.")

script_tag_pattern = re.compile(
    r'''<script\b[^>]*\bsrc\s*=\s*["'](?:\./)?script\.js["'][^>]*>\s*</script>''',
    re.IGNORECASE | re.DOTALL,
)

if not script_tag_pattern.search(updated_index):
    updated_index = re.sub(
        r"</body\s*>",
        '  <script src="script.js" defer></script>\n</body>',
        updated_index,
        count=1,
        flags=re.I,
    )

css_block = f'''

{CSS_START}
.lightbox-trigger {{
  display: inline-block;
  cursor: zoom-in;
}}

.lightbox-trigger img {{
  display: block;
}}

.image-lightbox[hidden] {{
  display: none;
}}

.image-lightbox {{
  position: fixed;
  inset: 0;
  z-index: 10000;
  display: grid;
  place-items: center;
  padding: clamp(1rem, 3vw, 2.5rem);
}}

.image-lightbox__backdrop {{
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  border: 0;
  background: rgba(0, 0, 0, 0.88);
  cursor: zoom-out;
}}

.image-lightbox__figure {{
  position: relative;
  z-index: 1;
  max-width: min(96vw, 1600px);
  max-height: 92vh;
  margin: 0;
  display: grid;
  gap: 0.75rem;
  justify-items: center;
}}

.image-lightbox__image {{
  display: block;
  max-width: 100%;
  max-height: 84vh;
  width: auto;
  height: auto;
  object-fit: contain;
  border-radius: 0.5rem;
  box-shadow: 0 1rem 3rem rgba(0, 0, 0, 0.45);
  background: #fff;
}}

.image-lightbox__caption {{
  max-width: 80ch;
  color: #fff;
  text-align: center;
  font-size: 0.95rem;
}}

.image-lightbox__caption:empty {{
  display: none;
}}

.image-lightbox__close {{
  position: fixed;
  top: max(0.75rem, env(safe-area-inset-top));
  right: max(0.75rem, env(safe-area-inset-right));
  z-index: 2;
  width: 3rem;
  height: 3rem;
  border: 1px solid rgba(255, 255, 255, 0.55);
  border-radius: 999px;
  background: rgba(0, 0, 0, 0.72);
  color: #fff;
  font: inherit;
  font-size: 2rem;
  line-height: 1;
  cursor: pointer;
}}

.image-lightbox__close:hover,
.image-lightbox__close:focus-visible {{
  background: #000;
}}

body.lightbox-open {{
  overflow: hidden;
}}

@media (prefers-reduced-motion: no-preference) {{
  .image-lightbox__image {{
    animation: image-lightbox-enter 160ms ease-out;
  }}

  @keyframes image-lightbox-enter {{
    from {{
      opacity: 0;
      transform: scale(0.97);
    }}
    to {{
      opacity: 1;
      transform: scale(1);
    }}
  }}
}}
{CSS_END}
'''

if CSS_START not in css_text:
    css_text = css_text.rstrip() + css_block + "\n"

js_block = r'''

/* IMAGE LIGHTBOX: START */
(() => {
  "use strict";

  const lightbox = document.getElementById("imageLightbox");
  const lightboxImage = document.getElementById("imageLightboxImage");
  const lightboxCaption = document.getElementById("imageLightboxCaption");
  const closeButton = document.getElementById("imageLightboxClose");
  const backdrop = document.getElementById("imageLightboxBackdrop");

  if (!lightbox || !lightboxImage || !lightboxCaption || !closeButton || !backdrop) {
    return;
  }

  let previouslyFocused = null;

  const closeLightbox = () => {
    if (lightbox.hidden) return;

    lightbox.hidden = true;
    lightboxImage.removeAttribute("src");
    lightboxImage.alt = "";
    lightboxCaption.textContent = "";
    document.body.classList.remove("lightbox-open");

    if (previouslyFocused instanceof HTMLElement) {
      previouslyFocused.focus();
    }

    previouslyFocused = null;
  };

  const openLightbox = (trigger) => {
    const thumbnail = trigger.querySelector("img");
    const source =
      trigger.dataset.lightboxSrc ||
      trigger.getAttribute("href") ||
      thumbnail?.currentSrc ||
      thumbnail?.src;

    if (!source) return;

    previouslyFocused = document.activeElement;
    lightboxImage.src = source;

    const description =
      thumbnail?.getAttribute("alt")?.trim() ||
      trigger.getAttribute("aria-label")?.trim() ||
      "";

    lightboxImage.alt = description;
    lightboxCaption.textContent = description;
    lightbox.hidden = false;
    document.body.classList.add("lightbox-open");
    closeButton.focus();
  };

  document.addEventListener("click", (event) => {
    const trigger = event.target.closest(".lightbox-trigger");
    if (!trigger) return;

    event.preventDefault();
    openLightbox(trigger);
  });

  closeButton.addEventListener("click", closeLightbox);
  backdrop.addEventListener("click", closeLightbox);

  document.addEventListener("keydown", (event) => {
    if (lightbox.hidden) return;

    if (event.key === "Escape") {
      event.preventDefault();
      closeLightbox();
      return;
    }

    if (event.key === "Tab") {
      event.preventDefault();
      closeButton.focus();
    }
  });
})();
/* IMAGE LIGHTBOX: END */
'''

if JS_START not in js_text:
    js_text = js_text.rstrip() + js_block + "\n"

INDEX.write_text(updated_index, encoding="utf-8")
CSS.write_text(css_text, encoding="utf-8")
JS.write_text(js_text, encoding="utf-8")

print(f"Target images found: {len(img_pattern.findall(index_text))}")
print(f"Existing image links enhanced: {len(protected)}")
print(f"Standalone images wrapped: {wrapped_count}")
print("Lightbox HTML/CSS/JavaScript installed.")
PY

printf '\nValidation:\n'
grep -q '<!-- IMAGE LIGHTBOX: START -->' index.html
grep -q '/\* IMAGE LIGHTBOX: START \*/' styles.css
grep -q '/\* IMAGE LIGHTBOX: START \*/' script.js

printf '  [OK] index.html lightbox markup\n'
printf '  [OK] styles.css lightbox styles\n'
printf '  [OK] script.js lightbox behavior\n'

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git diff --check
  printf '\nChanged files:\n'
  git status --short -- index.html styles.css script.js

  printf '\nReview:\n'
  printf '  git diff -- index.html styles.css script.js\n'
  printf '\nAfter testing:\n'
  printf '  git add index.html styles.css script.js\n'
  printf '  git commit -m "Restore click-to-enlarge portfolio images"\n'
  printf '  git push origin main\n'
fi

printf '\nDone. Open index.html and click an image from assets/images/.\n'
printf 'Press Escape, click the backdrop, or use the close button to exit.\n'
