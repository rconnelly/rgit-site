#!/usr/bin/env bash
# Install the rgit-site virtual host into Caddy without replacing other sites.
#
#   sudo ./configure-caddy.sh
#
# Env:
#   SITE_DOMAIN       hostname (default docs.rgit.rs, or last value in site.env)
#   SITE_OVERWRITE    1 takes --domain from another sites-enabled snippet
#   SITE_CADDY_DIR    Caddy config dir (default /etc/caddy)
#   SITE_WEBROOT      published tree (default /var/www/rgit-site)
#   SITE_ENV_FILE     health-check env file (default /etc/rgit-site/site.env)
#   CADDY_EMAIL       optional ACME contact; written only when this script creates Caddyfile
set -euo pipefail

SCRIPT_DIR=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi
if [[ -z "$SCRIPT_DIR" || ! -f "${SCRIPT_DIR}/rgit-site.caddy" ]]; then
  echo "configure-caddy.sh must sit next to rgit-site.caddy" >&2
  exit 1
fi

CADDY_DIR="${SITE_CADDY_DIR:-/etc/caddy}"
WEBROOT="${SITE_WEBROOT:-/var/www/rgit-site}"
SITE_ENV="${SITE_ENV_FILE:-/etc/rgit-site/site.env}"
SNIPPET="${CADDY_DIR}/sites-enabled/rgit-site.caddy"
CADDYFILE="${CADDY_DIR}/Caddyfile"
IMPORT_LINE="import ${CADDY_DIR}/sites-enabled/*"
RESTORES=()

load_site_env() {
  if [[ -f "$SITE_ENV" ]]; then
    # shellcheck disable=SC1090
    source "$SITE_ENV"
  fi
}

resolve_domain() {
  if [[ -n "${SITE_DOMAIN:-}" ]]; then
    printf '%s' "$SITE_DOMAIN"
    return
  fi
  load_site_env
  if [[ -n "${SITE_HEALTH_HOST:-}" ]]; then
    printf '%s' "$SITE_HEALTH_HOST"
    return
  fi
  if [[ "${SITE_HEALTH_URL:-}" == *":8080"* ]]; then
    printf '%s' ":8080"
    return
  fi
  printf '%s' "docs.rgit.rs"
}

apex_for() {
  local domain="$1"
  if [[ "$domain" == www.* ]]; then
    printf '%s' "${domain#www.}"
  fi
}

snippet_claims_domain() {
  local file="$1"
  local domain="$2"
  awk -v d="$domain" '
    function count_char(s, c,    n, i) {
      n = 0
      for (i = 1; i <= length(s); i++) if (substr(s, i, 1) == c) n++
      return n
    }
    /^[[:space:]]*#/ { next }
    {
      if (depth == 0 && $0 ~ /\{/) {
        header = $0
        sub(/[[:space:]]*\{.*/, "", header)
        n = split(header, a, ",")
        for (i = 1; i <= n; i++) {
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i])
          if (a[i] == d) { found = 1; exit }
        }
      }
      depth += count_char($0, "{") - count_char($0, "}")
    }
    END { exit found ? 0 : 1 }
  ' "$file"
}

snippet_addresses() {
  local file="$1"
  awk '
    function count_char(s, c,    n, i) {
      n = 0
      for (i = 1; i <= length(s); i++) if (substr(s, i, 1) == c) n++
      return n
    }
    /^[[:space:]]*#/ { next }
    {
      if (depth == 0 && $0 ~ /\{/) {
        header = $0
        sub(/[[:space:]]*\{.*/, "", header)
        n = split(header, a, ",")
        for (i = 1; i <= n; i++) {
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", a[i])
          if (a[i] != "") print a[i]
        }
      }
      depth += count_char($0, "{") - count_char($0, "}")
    }
  ' "$file"
}

overwrite_wanted() {
  local v="${SITE_OVERWRITE:-}"
  v="${v,,}"
  [[ "$v" == "1" || "$v" == "true" || "$v" == "yes" ]]
}

colliding_snippets() {
  local domain="$1"
  local f
  shopt -s nullglob
  for f in "${CADDY_DIR}/sites-enabled/"*; do
    [[ -f "$f" ]] || continue
    [[ "$f" == "$SNIPPET" ]] && continue
    if snippet_claims_domain "$f" "$domain"; then
      printf '%s\n' "$f"
    fi
  done
}

backup_path_for() {
  local f="$1"
  local bak="${f}.bak-rgit-site"
  local n=1
  while [[ -e "$bak" ]]; do
    bak="${f}.bak-rgit-site.${n}"
    n=$((n + 1))
  done
  printf '%s' "$bak"
}

restore_taken_snippets() {
  local pair bak dest
  if [[ ${#RESTORES[@]} -eq 0 ]]; then
    return
  fi
  for pair in "${RESTORES[@]}"; do
    bak="${pair%%|*}"
    dest="${pair#*|}"
    if [[ -f "$bak" ]]; then
      mv "$bak" "$dest"
    fi
  done
}

take_over_colliding_snippets() {
  local domain="$1"
  local f bak addr extras
  while IFS= read -r f; do
    [[ -n "$f" ]] || continue
    extras=""
    while IFS= read -r addr; do
      [[ -z "$addr" || "$addr" == "$domain" ]] && continue
      extras="${extras} ${addr}"
    done < <(snippet_addresses "$f")
    if [[ -n "$extras" ]]; then
      echo "note: ${f} also listed${extras}; those vhosts go away with --overwrite" >&2
    fi
    bak="$(backup_path_for "$f")"
    cp -a "$f" "$bak"
    rm -f "$f"
    RESTORES+=("${bak}|${f}")
    echo "took over ${domain} from ${f} (backup ${bak})"
  done < <(colliding_snippets "$domain")
}

caddyfile_is_replaceable() {
  local f="$1"
  if [[ ! -s "$f" ]]; then
    return 0
  fi
  if grep -qF "$IMPORT_LINE" "$f"; then
    return 1
  fi
  if grep -qF 'root * /usr/share/caddy' "$f"; then
    return 0
  fi
  return 1
}

write_snippet() {
  local domain="$1"
  local apex
  apex="$(apex_for "$domain")"
  install -d -m 0755 "${CADDY_DIR}/sites-enabled"
  if [[ "$domain" == :* ]]; then
    cat >"$SNIPPET" <<EOF
${domain} {
	root * ${WEBROOT}
	encode gzip zstd
	try_files {path} {path}/ /404.html
	file_server
}
EOF
  elif [[ -n "$apex" ]]; then
    sed -e "s#placeholder\\.example\\.com#${domain}#g" \
      -e "s#apex\\.example\\.com#${apex}#g" \
      "${SCRIPT_DIR}/rgit-site.caddy" >"$SNIPPET"
  else
    sed -e "s#placeholder\\.example\\.com#${domain}#g" \
      -e '/^apex.example.com {/,/^}$/d' \
      "${SCRIPT_DIR}/rgit-site.caddy" >"$SNIPPET"
  fi
  chmod 0644 "$SNIPPET"
}

write_site_env() {
  local domain="$1"
  install -d -m 0755 "$(dirname "$SITE_ENV")"
  if [[ "$domain" == :* ]]; then
    printf 'SITE_HEALTH_URL=http://127.0.0.1%s/\n' "$domain" >"$SITE_ENV"
  else
    printf 'SITE_HEALTH_URL=http://127.0.0.1/\nSITE_HEALTH_HOST=%s\n' "$domain" >"$SITE_ENV"
  fi
  chmod 0644 "$SITE_ENV"
}

ensure_caddyfile_import() {
  if [[ -f "$CADDYFILE" ]] && grep -qF "$IMPORT_LINE" "$CADDYFILE"; then
    return
  fi
  if caddyfile_is_replaceable "$CADDYFILE"; then
    if [[ -s "$CADDYFILE" ]]; then
      cp "$CADDYFILE" "${CADDYFILE}.bak-rgit-site"
    fi
    {
      if [[ -n "${CADDY_EMAIL:-}" ]]; then
        printf '{\n\temail %s\n}\n' "$CADDY_EMAIL"
      fi
      printf '%s\n' "$IMPORT_LINE"
    } >"$CADDYFILE"
  else
    printf '\n%s\n' "$IMPORT_LINE" >>"$CADDYFILE"
  fi
  chmod 0644 "$CADDYFILE"
}

DOMAIN="$(resolve_domain)"
if [[ -f "$CADDYFILE" ]] && snippet_claims_domain "$CADDYFILE" "$DOMAIN"; then
  echo "Caddyfile itself serves ${DOMAIN}." >&2
  echo "Remove that site block from ${CADDYFILE}, then re-run with --overwrite." >&2
  exit 1
fi
others="$(colliding_snippets "$DOMAIN")"
if [[ -n "$others" ]]; then
  if overwrite_wanted; then
    take_over_colliding_snippets "$DOMAIN"
  else
    echo "Caddy already serves ${DOMAIN} from:" >&2
    printf '%s\n' "$others" >&2
    echo "Pass --overwrite to take that hostname for rgit-site, or a unique --domain." >&2
    exit 1
  fi
fi

if id caddy >/dev/null 2>&1; then
  install -d -m 0755 -o caddy -g caddy "$WEBROOT"
else
  install -d -m 0755 "$WEBROOT"
fi
prev=""
if [[ -f "$SNIPPET" ]]; then
  prev="$(mktemp)"
  cp "$SNIPPET" "$prev"
fi
write_snippet "$DOMAIN"
ensure_caddyfile_import
write_site_env "$DOMAIN"

if command -v caddy >/dev/null 2>&1; then
  if ! caddy validate --config "$CADDYFILE" >/dev/null 2>&1; then
    echo "Caddyfile is invalid after writing ${SNIPPET}; rolled back" >&2
    caddy validate --config "$CADDYFILE" >&2 || true
    restore_taken_snippets
    if [[ -n "$prev" ]]; then
      mv "$prev" "$SNIPPET"
    else
      rm -f "$SNIPPET"
    fi
    exit 1
  fi
fi
if [[ -n "$prev" ]]; then
  rm -f "$prev"
fi

echo "Caddy virtual host ${DOMAIN} → ${WEBROOT} (${SNIPPET})"
