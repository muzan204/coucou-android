#!/data/data/com.termux/files/usr/bin/bash
set -e

pkg install -y curl
mkdir -p "$HOME/bin"

cp "$(dirname "$0")/coucou" "$HOME/bin/coucou"
cp "$(dirname "$0")/coucou-run" "$HOME/bin/coucou-run"

chmod +x "$HOME/bin/coucou" "$HOME/bin/coucou-run"

if ! grep -q 'HOME/bin' "$HOME/.zshrc" 2>/dev/null; then
  printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.zshrc"
fi

if [ -f "$HOME/.bashrc" ] && ! grep -q 'HOME/bin' "$HOME/.bashrc"; then
  printf '\nexport PATH="$HOME/bin:$PATH"\n' >> "$HOME/.bashrc"
fi

echo
echo "Instalado."
echo "Rode: source ~/.zshrc"
echo "Depois teste: coucou ping"
