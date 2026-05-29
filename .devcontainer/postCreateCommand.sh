#!/usr/bin/env bash
set -euo pipefail

# Setup fisher plugin manager for fish and install plugins
/usr/bin/fish -c "
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
fisher install decors/fish-colored-man
fisher install edc/bass
fisher install jorgebucaran/autopair.fish
fisher install nickeb96/puffer-fish
fisher install PatrickF1/fzf.fish
"

# Create/update virtual environment
if ! grep -q "venv /workspaces/" .venv/pyvenv.cfg; then
    rm -rf .venv
fi

# Mise-Aktivierung nur einmalig hinzufügen (idempotent)
if ! grep -q 'mise activate fish' ~/.config/fish/config.fish; then
    echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish
fi
if ! grep -q 'mise activate bash' ~/.bashrc; then
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
fi

# Shims für dieses Script verfügbar machen
export PATH="$HOME/.local/share/mise/shims:$PATH"

mise trust
pip install pipx
mise install