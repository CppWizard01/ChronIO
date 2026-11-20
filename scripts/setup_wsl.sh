#!/usr/bin/env bash
# ==============================================================================
# ChronIO — Complete WSL2 Ubuntu Toolchain Installer
# Installs:
#   1. System simulators & synthesis: verilator, iverilog, yosys, gtkwave
#   2. OCaml 5.1.1 + opam + dune
#   3. Jane Street Hardcaml suite: hardcaml, hardcaml_waveterm, ppx_hardcaml,
#      ppx_jane, ppx_expect
#   4. Python venv: cocotb, cocotbext-uart, cocotbext-spi, pytest, pyyaml,
#      python-dotenv, rich, librelane
#
# Run inside WSL2 Ubuntu:
#   sed -i 's/\r$//' /mnt/c/Users/sdhai/Desktop/ChronIO/scripts/setup_wsl.sh
#   bash /mnt/c/Users/sdhai/Desktop/ChronIO/scripts/setup_wsl.sh
# ==============================================================================
set -euo pipefail

CHRONIO_DIR="/mnt/c/Users/sdhai/Desktop/ChronIO"

echo "==> [1/4] Installing Ubuntu packages (opam, verilator, iverilog, yosys, gtkwave, python3)..."
sudo apt-get update
sudo apt-get install -y \
  build-essential git curl m4 unzip bubblewrap pkg-config \
  opam verilator iverilog yosys gtkwave \
  python3 python3-pip python3-venv python3-dev

echo "==> [2/4] Initializing opam & OCaml 5.1.1 switch..."
if [ ! -d "$HOME/.opam" ]; then
  opam init --disable-sandboxing -y
fi

if ! opam switch list -s | grep -q "^chronio-5.1.1$"; then
  opam switch create chronio-5.1.1 5.1.1 -y
else
  opam switch set chronio-5.1.1
fi

eval "$(opam env --switch=chronio-5.1.1)"

echo "==> [3/4] Installing Jane Street Hardcaml & ASCII Waveform Expect-Test packages..."
opam install -y \
  dune \
  base \
  stdio \
  hardcaml \
  hardcaml_waveterm \
  ppx_hardcaml \
  ppx_jane \
  ppx_expect \
  ocaml-lsp-server \
  ocamlformat

echo "==> [4/4] Creating Python virtualenv (~/.venvs/chronio) & installing cocotb + librelane..."
mkdir -p "$HOME/.venvs"
if [ ! -d "$HOME/.venvs/chronio" ]; then
  python3 -m venv "$HOME/.venvs/chronio"
fi

source "$HOME/.venvs/chronio/bin/activate"
pip install --upgrade pip
pip install -r "$CHRONIO_DIR/requirements.txt"
pip install librelane || echo "Note: For full local GDS hardening with IHP PDK, use Nix or Docker per Tiny Tapeout local-hardening guide."

# Auto-activate in ~/.bashrc if not already present
if ! grep -q "chronio-5.1.1" "$HOME/.bashrc"; then
  cat >> "$HOME/.bashrc" << 'EOF'

# --- ChronIO Toolchain Auto-Activation ---
if [ -d "$HOME/.opam" ]; then
  eval "$(opam env --switch=chronio-5.1.1 2>/dev/null)" || true
fi
if [ -f "$HOME/.venvs/chronio/bin/activate" ]; then
  source "$HOME/.venvs/chronio/bin/activate"
fi
EOF
fi

echo ""
echo "=============================================================================="
echo " ALL TOOLS INSTALLED SUCCESSFULLY!"
echo "   - OCaml + Dune + Hardcaml + Hardcaml_waveterm"
echo "   - cocotb + cocotbext-uart + cocotbext-spi + pytest + pyyaml"
echo "   - Verilator + Icarus Verilog + Yosys"
echo " Run 'source ~/.bashrc' in WSL2 to activate immediately."
echo "=============================================================================="
