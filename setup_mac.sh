#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# LumaLock Studio Suite — macOS Workspace Bootstrap Script
# ------------------------------------------------------------------------------
# Clones or updates all 3 repositories inside ./apps/, installs frontend
# dependencies, and installs custom Antigravity skills into ~/.gemini/config/skills/
# ==============================================================================

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APPS_DIR="$ROOT_DIR/apps"
SKILLS_DEST="$HOME/.gemini/config/skills"

echo "============================================================"
echo "  LumaLock Studio Suite — macOS Environment Setup"
echo "============================================================"
echo "Workspace Root: $ROOT_DIR"
echo ""

# 1. Tooling checks
for cmd in git node npm cargo rustc; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "❌ Required tool missing: $cmd"
    echo "   Please install $cmd before continuing."
    exit 1
  fi
done

echo "✅ Git:  $(git --version)"
echo "✅ Node: $(node --version) / npm $(npm --version)"
echo "✅ Rust: $(rustc --version)"
if command -v gh >/dev/null 2>&1; then
  echo "✅ gh:   $(gh --version | head -n 1)"
else
  echo "⚠️  GitHub CLI (gh) not found. Install via 'brew install gh' if you plan to create/push new repos."
fi
echo ""

# 2. Clone or update the 3 app repositories
mkdir -p "$APPS_DIR"

clone_or_pull() {
  local dir_name="$1"
  local repo_url="$2"
  local target="$APPS_DIR/$dir_name"
  if [ -d "$target/.git" ]; then
    echo "🔄 Updating $dir_name..."
    git -C "$target" pull --ff-only || echo "⚠️  Skipped fast-forward pull for $dir_name (local changes present)."
  else
    echo "📥 Cloning $dir_name from $repo_url..."
    git clone "$repo_url" "$target"
  fi
}

clone_or_pull "lumalock-pro" "https://github.com/mixography-max/lumalock-pro.git"
clone_or_pull "kantan-image-compression" "https://github.com/mixography-max/kantan-image-compression.git"
clone_or_pull "KantanZIP" "https://github.com/mixography-max/KantanZIP.git"

echo ""

# 3. Install npm dependencies for Tauri apps
for app in lumalock-pro kantan-image-compression; do
  if [ -f "$APPS_DIR/$app/package.json" ]; then
    echo "📦 Installing npm dependencies in apps/$app..."
    (cd "$APPS_DIR/$app" && npm install)
  fi
done

echo ""

# 4. Restore custom Antigravity skills
if [ -d "$ROOT_DIR/skills" ]; then
  mkdir -p "$SKILLS_DEST"
  cp -R "$ROOT_DIR/skills/"* "$SKILLS_DEST/"
  echo "🧠 Installed custom Antigravity skills to $SKILLS_DEST"
fi

echo ""
echo "============================================================"
echo "  Setup Complete!"
echo "============================================================"
echo "Next steps:"
echo "  1. Open Antigravity IDE."
echo "  2. Open folder: $ROOT_DIR"
echo "     (or File -> Open Workspace from File... -> LumaLock_Suite.code-workspace)"
echo "  3. Read HANDOVER_MANUAL.md and paste the Starter Prompt into Antigravity."
