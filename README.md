###⚡️ Fast Concurrent Bash Port Scanner
##This script is a lightweight, concurrent TCP port scanner built entirely in Bash, leveraging the reliability of the netcat (nc) utility. It is designed to quickly check a range of ports on a specified target with configurable concurrency and timeouts.

###🚀 Usage
##The script requires a target address and accepts three optional arguments for configuration:
```
./port_scanner.sh <target> [ports] [timeout_secs] [concurrency]
```
Arguments
Argument

Description

Default Value

Required

<target>

The target IP address or hostname to scan.

-

Yes

[ports]

A comma-separated list of ports and/or port ranges to scan.

1-1024

No

[timeout_secs]

Connection timeout in seconds (how long nc waits per port).

1

No

[concurrency]

The maximum number of simultaneous nc processes to run at once.

200

No

Port Specification Format
The [ports] argument is highly flexible and accepts:

Individual Ports: 80,443,22

Ranges: 1-100

Mixed: 20-25,80,443,8080

📋 Examples
1. Basic Scan (Default Range)
Scans the first 1024 ports of the target with a 1-second timeout and 200 concurrent checks.
```
./port_scanner.sh 192.168.1.1
```
2. Scanning Common Web/SSH Ports
Scans ports 22, 80, 443, and 8080.
```
./port_scanner.sh example.com 22,80,443,8080
```
3. Full Port Scan with Slower Timeout
Scans all 65535 ports on the target, waiting 2 seconds for a response for better reliability, but still using high concurrency.
```
./port_scanner.sh 10.0.0.5 1-65535 2
```
4. Custom Concurrency
Scans only the higher, non-privileged ports (1025-65535) using a low concurrency limit of 50 to reduce load on the scanning system.
```
./port_scanner.sh myserver.local 1025-65535 1 50
```
⚙️ Dependencies
This script requires the following utility to be installed on the system:

netcat (nc): Used for connection testing. Most Linux/Unix systems have a version of netcat installed by default.

⚠️ Notes on Concurrency
The script uses background jobs (&) and wait -n within a loop to manage concurrency.

When the number of running background jobs reaches the CONCURRENCY limit, the script pauses and waits for at least one job to finish before launching the next one.

This prevents the shell from spawning thousands of processes instantly, which could otherwise lead to resource exhaustion.

A trap is implemented to ensure all child processes are gracefully terminated if the script is interrupted (e.g., via Ctrl+C).
