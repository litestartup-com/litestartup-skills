#!/usr/bin/env bash
# LiteStartup Skills — Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/litestartup-com/litestartup-skills/main/install.sh | bash
#   curl -fsSL ... | bash -s -- --skill litestartup-publish
#   curl -fsSL ... | bash -s -- --editor windsurf
#   curl -fsSL ... | bash -s -- --skill litestartup-publish --editor cursor
#   curl -fsSL ... | bash -s -- --update [--skill litestartup-publish] [--dir litestartup-skills]

set -euo pipefail

REPO_URL="https://github.com/litestartup-com/litestartup-skills.git"
INSTALL_DIR="litestartup-skills"
SKILL=""
EDITOR=""
UPDATE=""

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skill) SKILL="$2"; shift 2 ;;
        --editor) EDITOR="$2"; shift 2 ;;
        --dir) INSTALL_DIR="$2"; shift 2 ;;
        --update) UPDATE=1; shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -n "$UPDATE" ]; then
    echo "🔄 Updating LiteStartup Skills..."
else
    echo "🚀 Installing LiteStartup Skills..."
fi

# --- Clone or update ---
if [ -n "$UPDATE" ]; then
    if [ ! -d "$INSTALL_DIR/.git" ]; then
        echo "❌ No existing install at $INSTALL_DIR. Run without --update first."
        exit 1
    fi
    cd "$INSTALL_DIR"
    if [ -n "$SKILL" ]; then
        echo "📦 Ensuring sparse checkout includes: $SKILL"
        git sparse-checkout set "skills/$SKILL" "adapters" "README.md" "RULE.md" "AGENT_SKILLS_SPEC.md" "install.sh"
    fi
    git fetch --depth 1 origin main
    git reset --hard FETCH_HEAD
    echo "✅ Updated to $(git log -1 --format='%h %s')"
elif [ -n "$SKILL" ]; then
    echo "📦 Installing skill: $SKILL (sparse checkout)"
    git clone --filter=blob:none --sparse "$REPO_URL" "$INSTALL_DIR" 2>/dev/null
    cd "$INSTALL_DIR"
    git sparse-checkout set "skills/$SKILL" "adapters" "README.md" "RULE.md" "AGENT_SKILLS_SPEC.md" "install.sh"
    echo "✅ Installed: skills/$SKILL/ + adapters/"
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
