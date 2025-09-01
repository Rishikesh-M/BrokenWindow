#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <host_or_ip> [start_port] [end_port]"
    exit 1
fi

target=$1
start=${2:-1}     # default start port = 1
end=${3:-1024}    # default end port = 1024

echo "🎯 Scanning $target (TCP $start-$end)"
echo "------------------------------------------------"

# find service name from /etc/services
get_service_name() {
    port=$1
    proto=$2
    service=$(grep -w "$port/$proto" /etc/services | awk '{print $1}' | head -n1)
    if [ -n "$service" ]; then
        echo "$service"
    else
        echo "unknown"
    fi
}

# banner grabbing
get_banner() {
    port=$1
    timeout 2 bash -c "exec 3<>/dev/tcp/$target/$port; echo '' >&3; head -n 1 <&3" 2>/dev/null
}

# scan ports
for port in $(seq $start $end); do
    (echo >/dev/tcp/$target/$port) 2>/dev/null
    if [ $? -eq 0 ]; then
        service=$(get_service_name $port tcp)
        banner=$(get_banner $port)
        if [ -n "$banner" ]; then
            echo "[+] TCP $port OPEN → $service | Banner: $banner"
        else
            echo "[+] TCP $port OPEN → $service"
        fi
    fi
done

echo "✅ Scan completed."
