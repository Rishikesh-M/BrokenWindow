#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-}"
PORT_SPEC="${2:-1-1024}"
TIMEOUT="${3:-1}"
CONCURRENCY="${4:-200}"

usage() {
    printf "Usage: %s <target> [ports] [timeout_secs] [concurrency]\n" "$0" >&2
    exit 2
}

if [[ -z "$TARGET" ]]; then usage; fi
if ! command -v nc >/dev/null 2>&1; then
    echo "Error: 'netcat' (nc) command not found. Install it to proceed." >&2
    exit 1
fi

re='^[0-9]+$'
if ! [[ "$TIMEOUT" =~ $re && "$CONCURRENCY" =~ $re ]]; then
    echo "Error: timeout and concurrency must be integers" >&2
    exit 3
fi
if (( TIMEOUT <= 0 || CONCURRENCY <= 0 )); then
    echo "Error: timeout and concurrency must be > 0" >&2
    exit 4
fi

expand_ports() {
    local spec="$1" out=()
    IFS=',' read -ra parts <<< "$spec"
    for p in "${parts[@]}"; do
        if [[ "$p" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            local s=${BASH_REMATCH[1]} e=${BASH_REMATCH[2]}
            if (( s < 1 || e > 65535 || s > e )); then echo "Error: Invalid port range $p" >&2; exit 5; fi
            for ((i=s; i<=e; i++)); do out+=("$i"); done
        elif [[ "$p" =~ ^[0-9]+$ ]]; then
            if (( p < 1 || p > 65535 )); then echo "Error: Invalid port $p" >&2; exit 5; fi
            out+=("$p")
        else
            echo "Error: Invalid port token: $p" >&2; exit 5
        fi
    done
    printf "%s\n" "${out[@]}"
}

ports=( $(expand_ports "$PORT_SPEC") )
trap 'pkill -P $$ 2>/dev/null || true' INT TERM EXIT

scan_port() {
    local port=$1
    if nc -z -w "$TIMEOUT" "$TARGET" "$port" >/dev/null 2>&1; then
        printf "%s\n" "$port"
    fi
}

running=0
pids=()

for port in "${ports[@]}"; do
    scan_port "$port" &
    pids+=("$!")
    running=$((running + 1))

    if (( running >= CONCURRENCY )); then
        wait -n 2>/dev/null || true
        newp=()
        running=0
        for id in "${pids[@]}"; do
          if kill -0 "$id" 2>/dev/null; then
            newp+=("$id");
            running=$((running+1));
          fi
        done
        pids=("${newp[@]}")
    fi
done

wait
