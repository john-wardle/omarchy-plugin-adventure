#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ID="io.github.john-wardle.adventure-ollama"
LEGACY_PLUGIN_ID="io.github.kszx11.adventure"
MODEL="${ADVENTURE_OLLAMA_MODEL:-qwen2.5:3b}"
PLUGIN_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/plugins"
TARGET="$PLUGIN_DIR/$PLUGIN_ID"
BACKUP_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy-adventure/plugin-backups"
SOURCE_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

log() { printf '[adventure-install] %s\n' "$*"; }
fail() { printf '[adventure-install] ERROR: %s\n' "$*" >&2; exit 1; }

[[ "$SOURCE_DIR" != "$TARGET" ]] || fail "run this installer from the downloaded repository, not the installed plugin directory"
command -v omarchy >/dev/null 2>&1 || fail "Omarchy was not found on PATH"
command -v curl >/dev/null 2>&1 || fail "curl is required to install and check Ollama"

install_ollama() {
    if command -v ollama >/dev/null 2>&1; then
        log "Ollama is already installed: $(command -v ollama)"
        return
    fi

    log "Ollama is missing; running the official Ollama installer"
    curl -fsSL https://ollama.com/install.sh | sh
    command -v ollama >/dev/null 2>&1 || fail "Ollama installation finished, but ollama is not on PATH"
}

start_ollama() {
    if curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
        log "Ollama is already running"
        return
    fi

    if command -v systemctl >/dev/null 2>&1 && systemctl list-unit-files ollama.service >/dev/null 2>&1; then
        log "Enabling and starting ollama.service"
        sudo systemctl enable --now ollama.service
    else
        log "Starting Ollama in the background"
        nohup ollama serve >"${XDG_STATE_HOME:-$HOME/.local/state}/omarchy-adventure/ollama.log" 2>&1 &
    fi

    for attempt in {1..30}; do
        if curl -fsS --max-time 2 http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
            return
        fi
        sleep 1
    done
    fail "Ollama did not become ready at http://127.0.0.1:11434"
}

install_model() {
    if ollama list 2>/dev/null | awk 'NR > 1 {print $1}' | grep -Fxq "$MODEL"; then
        log "Model is already installed: $MODEL"
    else
        log "Pulling Ollama model: $MODEL"
        ollama pull "$MODEL"
    fi
}

install_plugin() {
    mkdir -p "$PLUGIN_DIR" "$BACKUP_DIR"

    if [[ -e "$PLUGIN_DIR/$LEGACY_PLUGIN_ID" || -L "$PLUGIN_DIR/$LEGACY_PLUGIN_ID" ]]; then
        omarchy plugin disable "$LEGACY_PLUGIN_ID" >/dev/null 2>&1 || true
    fi

    if [[ -e "$TARGET" || -L "$TARGET" ]]; then
        local stamp backup
        stamp=$(date +%Y%m%d-%H%M%S)
        backup="$BACKUP_DIR/$PLUGIN_ID-$stamp"
        log "Moving the existing Adventure plugin to $backup"
        mv -- "$TARGET" "$backup"
    fi

    while IFS= read -r -d '' old_copy; do
        [[ "$old_copy" == "$TARGET" ]] && continue
        local stamp backup
        stamp=$(date +%Y%m%d-%H%M%S)
        backup="$BACKUP_DIR/$(basename "$old_copy")-$stamp"
        log "Moving duplicate plugin copy to $backup"
        mv -- "$old_copy" "$backup"
    done < <(find "$PLUGIN_DIR" -mindepth 1 -maxdepth 1 -type d \( -name "$PLUGIN_ID*" -o -name "$LEGACY_PLUGIN_ID*" \) -print0)

    mkdir -p "$TARGET"
    tar --exclude=.git -C "$SOURCE_DIR" -cf - . | tar -C "$TARGET" -xf -
    omarchy plugin validate "$TARGET"
    log "Installed $PLUGIN_ID at $TARGET"
}

enable_plugin() {
    if omarchy restart shell >/dev/null 2>&1; then
        omarchy plugin enable "$PLUGIN_ID" --section right >/dev/null 2>&1 || true
        log "Adventure is enabled in the Omarchy bar"
    else
        log "The Omarchy shell could not be restarted automatically"
        log "Run: omarchy restart shell"
        log "Then run: omarchy plugin enable $PLUGIN_ID --section right"
    fi
}

install_ollama
mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy-adventure"
start_ollama
install_model
install_plugin
enable_plugin
log "Complete. Adventure uses local Ollama model $MODEL; no OpenAI API is configured."
