#!/data/data/com.termux/files/usr/bin/bash
set -e
pkg install -y python git curl
mkdir -p "$HOME/bin" "$HOME/projetos"
cp "$(dirname "$0")/coucou-agent" "$HOME/bin/coucou-agent"
chmod +x "$HOME/bin/coucou-agent"
if ! grep -q 'HOME/bin' "$HOME/.zshrc" 2>/dev/null; then printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.zshrc"; fi
echo 'Instalado. Rode: source ~/.zshrc && coucou-agent'
