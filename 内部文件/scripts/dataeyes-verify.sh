#!/usr/bin/env bash
set -euo pipefail

REPORT_DIR="${1:-$HOME/.openclaw/verify-output}"
mkdir -p "$REPORT_DIR"
TS="$(date +%Y%m%d-%H%M%S)"
TXT="$REPORT_DIR/dataeyes-verify-$TS.txt"
JSON="$REPORT_DIR/dataeyes-verify-$TS.json"
CFG="$HOME/.openclaw/openclaw.json"

OPENCLAW_BIN="$(command -v openclaw || true)"
OPENCLAW_VERSION="$({ openclaw --version; } 2>/dev/null || true)"
STATUS_OUT="$({ openclaw status; } 2>/dev/null || true)"
HAS_CFG="no"
HAS_DATAEYES="no"
DEFAULT_MODEL=""
if [[ -f "$CFG" ]]; then
  HAS_CFG="yes"
  PY_OUT="$(python3 - "$CFG" <<'PY'
import json,sys
cfg=json.load(open(sys.argv[1]))
providers=((cfg.get('models') or {}).get('providers') or {})
print('yes' if 'dataeyes' in providers else 'no')
print((((cfg.get('agents') or {}).get('defaults') or {}).get('model')) or '')
PY
)"
  HAS_DATAEYES="$(printf '%s' "$PY_OUT" | sed -n '1p')"
  DEFAULT_MODEL="$(printf '%s' "$PY_OUT" | sed -n '2p')"
fi

cat > "$TXT" <<EOF
openclaw_bin=$OPENCLAW_BIN
openclaw_version=$OPENCLAW_VERSION
has_config=$HAS_CFG
has_dataeyes_provider=$HAS_DATAEYES
default_model=$DEFAULT_MODEL

[openclaw status]
$STATUS_OUT
EOF

python3 - "$OPENCLAW_BIN" "$OPENCLAW_VERSION" "$HAS_CFG" "$HAS_DATAEYES" "$DEFAULT_MODEL" <<'PY' > "$JSON"
import json, sys
print(json.dumps({
  'openclaw_bin': sys.argv[1],
  'openclaw_version': sys.argv[2],
  'has_config': sys.argv[3],
  'has_dataeyes_provider': sys.argv[4],
  'default_model': sys.argv[5]
}, ensure_ascii=False, indent=2))
PY

echo "Wrote: $TXT"
echo "Wrote: $JSON"
