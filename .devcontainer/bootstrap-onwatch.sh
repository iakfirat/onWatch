#!/usr/bin/env bash
# Codespaces-only trial: install official onWatch release; fall back to building
# the checked-out fork if an independently verified release is unavailable.
set -euo pipefail
umask 077

state="$HOME/.local/share/stacklight-onwatch"
private="$HOME/.config/stacklight-onwatch"
mkdir -p "$state" "$private"
chmod 700 "$state" "$private"

if [[ ! -s "$private/admin-password" ]]; then
  openssl rand -hex 24 > "$private/admin-password"
  chmod 600 "$private/admin-password"
fi

if [[ -x "$state/onwatch" ]]; then
  "$state/onwatch" --version
  exit 0
fi

arch="$(uname -m)"
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) echo "Unsupported CPU architecture: $arch" >&2; exit 1 ;;
esac

tag="$(tr -d '[:space:]' < VERSION)"
[[ "$tag" == v* ]] || tag="v$tag"
asset="onwatch-linux-$arch"
api="https://api.github.com/repos/onllm-dev/onWatch/releases/tags/$tag"
url="https://github.com/onllm-dev/onWatch/releases/download/$tag/$asset"
tmp="$(mktemp "$state/.onwatch.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
echo "Preparing pinned onWatch $tag ($asset) without provider credentials..."

expected=""
if metadata="$(curl --max-time 15 --retry 1 -fsSL -H 'Accept: application/vnd.github+json' "$api" 2>/dev/null)"; then
  expected="$(printf '%s' "$metadata" | python3 -c 'import sys,json; j=json.load(sys.stdin); a=sys.argv[1]; print(next((x.get("digest","") for x in j.get("assets",[]) if x.get("name")==a),""))' "$asset" 2>/dev/null || true)"
fi

verified=false
if [[ "$expected" == sha256:* ]] && curl --max-time 120 --retry 2 -fsSL "$url" -o "$tmp"; then
  actual="$(sha256sum "$tmp" | cut -d ' ' -f1)"
  if [[ "$actual" == "${expected#sha256:}" ]]; then verified=true; fi
fi

if [[ "$verified" == true ]]; then
  install -m 700 "$tmp" "$state/onwatch"
  echo "Downloaded binary SHA-256 verification successful."
else
  echo "Verified release unavailable; building pinned fork source with Go."
  CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=${tag#v}" -o "$tmp" ./cmd/onwatch
  install -m 700 "$tmp" "$state/onwatch"
fi

"$state/onwatch" --version
echo "Private dashboard: port 9211. No provider keys were stored."
echo "Password is available locally in ~/.config/stacklight-onwatch/admin-password"
