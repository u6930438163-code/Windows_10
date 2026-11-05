#!/usr/bin/env bash
# Instalator pełnego Windows 10 w nowej VM KVM, wymagany własny legalny obraz ISO.
# Bez --start: wyłącznie odczyt i plan, bez zmiany systemu.
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DATA="$ROOT/vm"
ISO=""
START=0
SHA=""
while (($#)); do
  case "$1" in
    --iso) (($# >= 2)) || exit 2; ISO="$2"; shift 2 ;;
    --sha256) (($# >= 2)) || exit 2; SHA="$2"; shift 2 ;;
    --start) START=1; shift ;;
    --help|-h)
      echo "Użycie: bash scripts/linux/windows10-kvm.sh --iso /sciezka/Win10.iso [--sha256 HASH] [--start]"
      exit 0 ;;
    *) echo "Nieznana opcja: $1" >&2; exit 2 ;;
  esac
done
[[ "$(uname -s)" = Linux && "$(uname -m)" = x86_64 ]] ||
  { echo "Wymagany Linux x86_64." >&2; exit 1; }
[[ -n "$ISO" && -f "$ISO" && -r "$ISO" ]] ||
  { echo "Podaj istniejący, czytelny obraz Windows 10: --iso /sciezka/Win10.iso" >&2; exit 1; }
shopt -s nocasematch
[[ "$ISO" = *.iso ]] || { echo "Wymagane rozszerzenie .iso" >&2; exit 1; }
shopt -u nocasematch
ISO="$(realpath -- "$ISO")"
SIZE="$(stat -c %s -- "$ISO")"
((SIZE > 1000000000)) || { echo "Obraz ISO jest podejrzanie mały." >&2; exit 1; }
ACTUAL_SHA="$(sha256sum -- "$ISO" | awk '{print $1}')"
if [[ -n "$SHA" ]]; then
  [[ "$SHA" =~ ^[a-fA-F0-9]{64}$ ]] || { echo "Nieprawidłowy SHA256" >&2; exit 2; }
  [[ "$(echo "$SHA" | tr A-F a-f)" = "$ACTUAL_SHA" ]] ||
    { echo "ISO nie zgadza się z podanym SHA256!" >&2; exit 1; }
fi
echo "Czysty Windows 10 na oddzielnym dysku vm/Windows10.qcow2 (64 GB)."
echo "ISO: $ISO"
echo "SHA256: $ACTUAL_SHA"
[[ -n "$SHA" ]] || echo "Brak oficjalnego wzorca SHA256, autentyczność ISO niezweryfikowana."
if ((START == 0)); then
  echo "PLAN: bez zmian. Dodaj --start, aby utworzyć i uruchomić VM."
  exit 0
fi
[[ -c /dev/kvm && -r /dev/kvm && -w /dev/kvm ]] ||
  { echo "Brak dostępu do KVM. VPS musi wspierać /dev/kvm." >&2; exit 1; }
for cmd in qemu-img qemu-system-x86_64 websockify; do
  command -v "$cmd" >/dev/null ||
    { echo "Brakuje $cmd. Zainstaluj: qemu-system-x86 qemu-utils websockify novnc." >&2; exit 1; }
done
[[ -f /usr/share/novnc/vnc.html ]] ||
  { echo "Brak pakietu novnc." >&2; exit 1; }
[[ ! -L "$DATA" ]] || { echo "Katalog vm/ nie może być linkiem symbolicznym." >&2; exit 1; }
mkdir -p -- "$DATA"
chmod 700 -- "$DATA"
DISK="$DATA/Windows10.qcow2"
[[ ! -L "$DISK" ]] || { echo "Dysk VM jest linkiem symbolicznym." >&2; exit 1; }
[[ ! -e "$DISK" || -f "$DISK" ]] || { echo "Nieprawidłowy dysk VM." >&2; exit 1; }
for pidfile in "$DATA/qemu.pid" "$DATA/novnc.pid"; do
  if [[ -f "$pidfile" ]]; then
    oldpid="$(cat "$pidfile")"
    if [[ "$oldpid" =~ ^[0-9]+$ ]] && kill -0 "$oldpid" 2>/dev/null; then
      echo "VM/noVNC już działa, PID $oldpid. Przerwano." >&2
      exit 1
    fi
    rm -f "$pidfile"
  fi
done
if [[ ! -e "$DISK" ]]; then
  qemu-img create -f qcow2 "$DISK" 64G
  chmod 600 "$DISK"
fi
# QEMU nigdy nie otrzymuje fizycznego dysku hosta. VNC tylko loopback.
qemu-system-x86_64 -name Windows10Clean -machine q35,accel=kvm \
  -cpu host -smp 2 -m 4096 \
  -drive "file=$DISK,if=ide,format=qcow2" \
  -cdrom "$ISO" -boot order=c,once=d \
  -netdev user,id=n0 -device e1000,netdev=n0 \
  -display none -vnc 127.0.0.1:1 \
  -daemonize -pidfile "$DATA/qemu.pid"
# noVNC również tylko loopback: wymagany osobny bezpieczny proxy.
nohup websockify --web=/usr/share/novnc/ 127.0.0.1:6080 127.0.0.1:5901 \
  >"$DATA/novnc.log" 2>&1 &
PID="$!"
echo "$PID" > "$DATA/novnc.pid"
sleep 1
kill -0 "$PID" 2>/dev/null || { echo "noVNC nie uruchomiono. Zobacz vm/novnc.log." >&2; exit 1; }
echo "Instalator uruchomiony. Lokalnie: http://127.0.0.1:6080/vnc.html"
echo "Z telefonu: tylko przez uwierzytelniony HTTPS reverse proxy, nigdy publiczne VNC."
