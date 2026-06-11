#!/usr/bin/env bash
# LiteStartup Skills — Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/litestartup-com/litestartup-skills/main/install.sh | bash
#   curl -fsSL ... | bash -s -- --skill publish
#   curl -fsSL ... | bash -s -- --editor windsurf
#   curl -fsSL ... | bash -s -- --skill publish --editor cursor

set -euo pipefail

REPO_URL="https://github.com/litestartup-com/litestartup-skills.git"
INSTALL_DIR="litestartup-skills"
SKILL=""
EDITOR=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skill) SKILL="$2"; shift 2 ;;
        --editor) EDITOR="$2"; shift 2 ;;
        --dir) INSTALL_DIR="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

echo "🚀 Installing LiteStartup Skills..."

# --- Clone ---
if [ -n "$SKILL" ]; then
    echo "📦 Installing skill: $SKILL (sparse checkout)"
    git clone --filter=blob:none --sparse "$REPO_URL" "$INSTALL_DIR" 2>/dev/null
    cd "$INSTALL_DIR"
    git sparse-checkout set "shared" "$SKILL" "adapters" "README.md" "RULE.md" "install.sh"
    echo "✅ Installed: shared/ + $SKILL/ + adapters/"
else
    echo "📦 Installing all skills"
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" 2>/dev/null
    cd "$INSTALL_DIR"
    echo "✅ Installed all skills"
fi

# --- Copy adapter file ---
if [ -n "$EDITOR" ]; then
    case "$EDITOR" in
        windsurf)
            if [ -f "adapters/windsurf/.windsurfrules" ]; then
                cp "adapters/windsurf/.windsurfrules" "../.windsurfrules"
                echo "📋 Copied .windsurfrules to workspace root"
            fi
            ;;
        cursor)
            mkdir -p "../.cursor/rules"
            if [ -f "adapters/cursor/litestartup.mdc" ]; then
                cp "adapters/cursor/litestartup.mdc" "../.cursor/rules/litestartup.mdc"
                echo "📋 Copied litestartup.mdc to .cursor/rules/"
            fi
            ;;
        claude)
            if [ -f "adapters/claude/CLAUDE.md" ]; then
                cp "adapters/claude/CLAUDE.md" "../CLAUDE.md"
                echo "📋 Copied CLAUDE.md to workspace root"
            fi
            ;;
        codex)
            if [ -f "adapters/codex/AGENTS.md" ]; then
                cp "adapters/codex/AGENTS.md" "../AGENTS.md"
                echo "📋 Copied AGENTS.md to workspace root"
            fi
            ;;
        *)
            echo "⚠️  Unknown editor: $EDITOR (windsurf|cursor|claude|codex)"
            ;;
    esac
fi

echo ""
echo "🎉 Done! Next steps:"
echo "   1. Get your API key from https://app.litestartup.com → Settings → API Keys"
echo "   2. Ask your AI agent: 'Bind this repo to my LiteStartup account'"
echo ""
