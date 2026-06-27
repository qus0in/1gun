#!/bin/bash
set -euo pipefail

REPO_ARCHIVE="https://github.com/qus0in/1ggun/archive/refs/heads/main.tar.gz"
AGENTS_DIR=".agents"

echo "[1ggun] installing..."

# 1. Download sound_hook.sh and sound/ into .agents/
mkdir -p "${AGENTS_DIR}"
TMP=$(mktemp -d)
trap 'rm -rf "${TMP}"' EXIT

curl -fsSL "${REPO_ARCHIVE}" | tar xz -C "${TMP}"
cp "${TMP}/1ggun-main/.agents/sound_hook.sh" "${AGENTS_DIR}/"
cp -r "${TMP}/1ggun-main/.agents/sound" "${AGENTS_DIR}/"
chmod +x "${AGENTS_DIR}/sound_hook.sh"
echo "downloaded: ${AGENTS_DIR}/"

# ── OS detection ──────────────────────────────────────────────────────────────

is_windows() {
    case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) return 0 ;; esac
    return 1
}

# ── JSON helpers ──────────────────────────────────────────────────────────────

# patch_json PATH PATCH_JSON MERGE_MODE
#   MERGE_MODE "top"   : existing + patch  (top-level shallow merge)
#   MERGE_MODE "hooks" : existing.hooks = existing.hooks + patch.hooks
patch_json() {
    local path="$1" patch="$2" mode="$3"
    local dir; dir="$(dirname "$path")"
    [ "$dir" != "." ] && mkdir -p "$dir"

    if is_windows; then
        _patch_json_windows "$path" "$patch" "$mode"
    else
        _patch_json_jq "$path" "$patch" "$mode"
    fi
}

_patch_json_jq() {
    local path="$1" patch="$2" mode="$3"
    local base; base=$([ -f "$path" ] && cat "$path" || echo '{}')
    if [ "$mode" = "hooks" ]; then
        echo "$base" | jq --argjson p "$patch" '.hooks = ((.hooks // {}) + $p.hooks)' > "${path}.tmp"
    else
        echo "$base" | jq --argjson p "$patch" '. + $p' > "${path}.tmp"
    fi
    mv "${path}.tmp" "$path"
}

_patch_json_python() {
    local path="$1" patch="$2" mode="$3"
    local python_cmd="$4"
    "$python_cmd" - "$path" "$patch" "$mode" <<'PYEOF'
import json, sys

path, patch_str, mode = sys.argv[1], sys.argv[2], sys.argv[3]

try:
    with open(path) as f:
        base = json.load(f)
except Exception:
    base = {}

patch = json.loads(patch_str)

if mode == "hooks":
    base.setdefault("hooks", {}).update(patch.get("hooks", {}))
else:
    base.update(patch)

with open(path, "w") as f:
    json.dump(base, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF
}

_patch_json_windows() {
    local path="$1" patch="$2" mode="$3"

    # Option 1: file doesn't exist — write fresh
    if [ ! -f "$path" ]; then
        echo "$patch" > "$path"
        return 0
    fi

    # Option 2: jq available
    if command -v jq &>/dev/null; then
        _patch_json_jq "$path" "$patch" "$mode"
        return 0
    fi

    # Option 3: python3 or python available
    local python_cmd=""
    if command -v python3 &>/dev/null; then
        python_cmd="python3"
    elif command -v python &>/dev/null; then
        python_cmd="python"
    fi
    if [ -n "$python_cmd" ]; then
        _patch_json_python "$path" "$patch" "$mode" "$python_cmd"
        return 0
    fi

    # Option 4: 수동 확인 — 기존 파일 덮어쓰기 여부
    echo ""
    echo "[경고] jq와 Python을 찾을 수 없습니다."
    echo "  기존 ${path} 의 내용을 덮어쓰면 기존 설정이 사라집니다."
    printf "  계속하시겠습니까? (y/N) "
    read -r answer </dev/tty
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo "$patch" > "$path"
    else
        echo "설치를 취소합니다."
        exit 1
    fi
}

# ── Hook data ─────────────────────────────────────────────────────────────────

cc_hook_entry() {
    printf '[{"hooks":[{"type":"command","command":"bash .agents/sound_hook.sh cc %s","timeout":30}]}]' "$1"
}
codex_hook_entry() {
    printf '[{"hooks":[{"type":"command","command":"bash .agents/sound_hook.sh codex %s","timeout":30}]}]' "$1"
}
agy_hook_entry() {
    printf '[{"type":"command","command":"bash sound_hook.sh agy %s","timeout":30}]' "$1"
}

AGY_PATCH=$(jq -n \
    --argjson pre  "$(agy_hook_entry PreInvocation)" \
    --argjson stop "$(agy_hook_entry Stop)" \
    '{"AGY":{"enabled":true,"PreInvocation":$pre,"Stop":$stop}}')

CC_PATCH=$(jq -n \
    --argjson ss    "$(cc_hook_entry SessionStart)" \
    --argjson ups   "$(cc_hook_entry UserPromptSubmit)" \
    --argjson pr    "$(cc_hook_entry PermissionRequest)" \
    --argjson notif "$(cc_hook_entry Notification)" \
    --argjson stop  "$(cc_hook_entry Stop)" \
    '{"hooks":{"SessionStart":$ss,"UserPromptSubmit":$ups,"PermissionRequest":$pr,"Notification":$notif,"Stop":$stop}}')

CODEX_PATCH=$(jq -n \
    --argjson ss   "$(codex_hook_entry SessionStart)" \
    --argjson ups  "$(codex_hook_entry UserPromptSubmit)" \
    --argjson pr   "$(codex_hook_entry PermissionRequest)" \
    --argjson stop "$(codex_hook_entry Stop)" \
    '{"hooks":{"SessionStart":$ss,"UserPromptSubmit":$ups,"PermissionRequest":$pr,"Stop":$stop}}')

# ── Apply ─────────────────────────────────────────────────────────────────────

patch_json ".agents/hooks.json"    "$AGY_PATCH"   "top"
echo "updated: .agents/hooks.json"

patch_json ".claude/settings.json" "$CC_PATCH"    "hooks"
echo "updated: .claude/settings.json"

patch_json ".codex/hooks.json"     "$CODEX_PATCH" "hooks"
echo "updated: .codex/hooks.json"

echo ""
echo "[1ggun] done"
echo "  .agents/sound_hook.sh  +  .agents/sound/"
echo "  .agents/hooks.json     (Antigravity CLI - 명 일꾼)"
echo "  .claude/settings.json  (Claude Code     - 조선 일꾼)"
echo "  .codex/hooks.json      (Codex           - 일본 일꾼)"
