#!/usr/bin/env bash
# Kontrola hosta bez zmian w systemie; --install-deps instaluje pakiety Debian.
set -Eeuo pipefail
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo "Wymagany Debian/Ubuntu Linux x86_64." >&2
  exit 1
fi
if [[ "$#" -gt 1 ]]; then
  echo "Opcja: --install-deps (tylko za zgodą administratora)" >&2; exit 2
fi
if [[ "$#" -eq 1 ]]; then
  if [[ "$1" != "--install-deps" ]]; then
    echo "Nieznana opcja. Użyj --install-deps." >&2; exit 2
  fi
  command -v apt-get >/dev/null ||
    { echo "Instalator pakietów działa tylko na systemach Debian/Ubuntu." >&2; exit 1; }
  if [[ "$(id -u)" -ne 0 ]]; then
    echo "Uruchom jako administrator: sudo bash scripts/linux/check-kvm.sh --install-deps" >&2; exit 1
  fi
  apt-get update
  apt-get install -y --no-install-recommends qemu-system-x86 qemu-utils novnc websockify
fi
for package in qemu-system-x86_64 qemu-img websockify; do
  if command -v "$package" >/dev/null; then
    echo "[OK] $package"
  else
    echo "[BRAK] $package"
  fi
done
if [[ -f /usr/share/novnc/vnc.html ]]; then
  echo "[OK] noVNC"
else
  echo "[BRAK] noVNC"
fi
if [[ -c /dev/kvm && -r /dev/kvm && -w /dev/kvm ]]; then
  echo "[OK] Akceleracja KVM dostępna dla tego użytkownika"
else
  echo "[BRAK] /dev/kvm lub uprawnień — VPS musi zapewniać wirtualizację KVM"
fi
