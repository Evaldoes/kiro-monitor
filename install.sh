#!/usr/bin/env bash
# Instala o kiro-monitor em ~/.kiro-monitor e o agente Kiro "monitor".
# Uso: ./install.sh [--default]   (--default torna o agente monitor o padrão do Kiro)
set -euo pipefail
cd "$(dirname "$0")"
D=~/.kiro-monitor
mkdir -p "$D/bin" "$D/web" ~/.kiro/agents ~/.local/bin
cp bin/* "$D/bin/" && chmod +x "$D"/bin/*
cp web/index.html "$D/web/"
sed "s#__HOME__#$HOME#g" config/kiro-agent-monitor.json > ~/.kiro/agents/monitor.json
ln -sf "$D/bin/kiro-monitor" "$D/bin/kmon-up" ~/.local/bin/
[ "${1:-}" = "--default" ] && kiro-cli agent set-default monitor
echo "Instalado. Hooks do Claude Code: mescle config/claude-hooks.json (troque __HOME__ por $HOME) em ~/.claude/settings.json"
