#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="$SCRIPT_DIR"
TEMPLATE="$WORKDIR/dataeyes-provider.json"
if [[ ! -f "$TEMPLATE" ]]; then
  TEMPLATE="$SCRIPT_DIR/../templates/dataeyes-provider.json"
fi
CFG="$HOME/.openclaw/openclaw.json"
DATAEYES_API_KEY="${DATAEYES_API_KEY:-${1:-}}"

if [[ -z "$DATAEYES_API_KEY" ]]; then
  echo "Usage: DATAEYES_API_KEY=xxx $0"
  echo "or: $0 <api-key>"
  exit 1
fi

mkdir -p "$(dirname "$CFG")"

python3 - "$CFG" "$TEMPLATE" "$DATAEYES_API_KEY" <<'PY'
import json, sys, os
cfg_path, tpl_path, api_key = sys.argv[1:4]
if os.path.exists(cfg_path):
    with open(cfg_path,'r',encoding='utf-8') as f:
        cfg=json.load(f)
else:
    cfg={}
with open(tpl_path,'r',encoding='utf-8') as f:
    tpl=json.load(f)
if 'models' not in cfg:
    cfg['models']={}
cfg['models']['mode']='merge'
if 'providers' not in cfg['models']:
    cfg['models']['providers']={}
dataeyes=tpl['models']['providers']['dataeyes']
dataeyes['apiKey']=api_key
cfg['models']['providers']['dataeyes']=dataeyes
cfg.setdefault('agents', {}).setdefault('defaults', {})['model']=tpl['agents']['defaults']['model']
cfg.setdefault('gateway', {})['mode']='local'
with open(cfg_path,'w',encoding='utf-8') as f:
    json.dump(cfg,f,ensure_ascii=False,indent=2)
    f.write('\n')
print('Injected provider: dataeyes')
print('Default model:', cfg['agents']['defaults']['model'])
PY

chmod 600 "$CFG" || true
echo "DataEyes setup done: $CFG"
