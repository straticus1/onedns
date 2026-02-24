# TICKET-001: onedns - Advanced DNS Debugging & Science Tool

**Project:** After Dark Systems DNS GO! (onedns)
**Priority:** High
**Type:** Feature - New Tool Development
**Created:** 2024-12-30

---

## Executive Summary

Design and implement `onedns` - the world's most advanced, verbose, and integrated DNS debugging tool. This Go-based CLI combines the power of traditional tools like `dig` and `drill` with deep integration into the dnsscience.io platform for internet-scale DNS security research.

---

## 1. Core Architecture

### 1.1 Technology Stack

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           onedns CLI                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  Commands Layer                                                          │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐           │
│  │ query   │ │ debug   │ │ science │ │validate │ │appliance│           │
│  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘           │
├───────┴──────────┴──────────┴──────────┴──────────┴─────────────────────┤
│  Core Engine Layer                                                       │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │
│  │ DNS Resolver │ │ DNSSEC Engine│ │ Packet Forge │ │ Record Parser│   │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘   │
├─────────────────────────────────────────────────────────────────────────┤
│  Integration Layer                                                       │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐   │
│  │dnsscience.io │ │  Infoblox    │ │  BlueCat     │ │  Zone Files  │   │
│  │    API       │ │    WAPI      │ │    API       │ │   Parser     │   │
│  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘   │
├─────────────────────────────────────────────────────────────────────────┤
│  Output Formatters                                                       │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐    │
│  │ short  │ │ long   │ │ detail │ │verbose │ │ debug  │ │  json  │    │
│  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘ └────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Module Structure

```
onedns/
├── cmd/
│   └── onedns/
│       └── main.go                 # Entry point
├── internal/
│   ├── cli/
│   │   ├── root.go                 # Root command
│   │   ├── query.go                # DNS query command
│   │   ├── debug.go                # Debug command
│   │   ├── mkpacket.go             # Packet forging
│   │   ├── makekey.go              # DNSSEC key generation
│   │   ├── txt.go                  # TXT record validation
│   │   ├── spf.go                  # SPF operations
│   │   ├── dmarc.go                # DMARC operations
│   │   ├── dkim.go                 # DKIM operations
│   │   ├── appliance.go            # Appliance management
│   │   ├── validate.go             # Zone/config validation
│   │   └── science.go              # dnsscience.io integration
│   ├── resolver/
│   │   ├── resolver.go             # Core DNS resolution
│   │   ├── dnssec.go               # DNSSEC validation
│   │   ├── recursive.go            # Recursive resolution tracing
│   │   └── cache.go                # Response caching
│   ├── packet/
│   │   ├── forge.go                # DNS packet construction
│   │   ├── parse.go                # Packet parsing
│   │   └── wire.go                 # Wire format encoding
│   ├── security/
│   │   ├── dnssec_keygen.go        # Key pair generation
│   │   ├── dnssec_sign.go          # Zone signing
│   │   └── tsig.go                 # TSIG operations
│   ├── validators/
│   │   ├── spf.go                  # SPF validation engine
│   │   ├── dkim.go                 # DKIM validation
│   │   ├── dmarc.go                # DMARC validation
│   │   ├── zone.go                 # Zone file validation
│   │   └── config.go               # Config file validation
│   ├── integrations/
│   │   ├── dnsscience/
│   │   │   ├── client.go           # API client
│   │   │   ├── scan.go             # Domain scanning
│   │   │   ├── history.go          # Historical data
│   │   │   └── analytics.go        # Analytics queries
│   │   ├── infoblox/
│   │   │   ├── client.go           # WAPI client
│   │   │   ├── records.go          # Record operations
│   │   │   └── zones.go            # Zone operations
│   │   ├── bluecat/
│   │   │   ├── client.go           # API client
│   │   │   └── records.go          # Record operations
│   │   └── platforms/
│   │       ├── bind.go             # BIND-specific
│   │       ├── powerdns.go         # PowerDNS-specific
│   │       ├── unbound.go          # Unbound-specific
│   │       ├── nsd.go              # NSD-specific
│   │       └── djbdns.go           # djbdns-specific
│   ├── output/
│   │   ├── formatter.go            # Output formatting interface
│   │   ├── short.go                # Minimal output
│   │   ├── long.go                 # Standard output
│   │   ├── detail.go               # Detailed output
│   │   ├── verbose.go              # Verbose with explanations
│   │   ├── debug.go                # Full debug output
│   │   ├── json.go                 # JSON output
│   │   └── color.go                # Colorized terminal output
│   └── config/
│       ├── config.go               # Configuration management
│       └── credentials.go          # Secure credential storage
├── pkg/
│   ├── types/                      # Public types
│   └── errors/                     # Error definitions
├── configs/
│   └── onedns.json.example       # Example config
├── go.mod
├── go.sum
└── README.md
```

---

## 2. Global Flags

These flags can be used with any command:

| Flag | Short | Description |
|------|-------|-------------|
| `--embedded-dns` | `-ed` | Use dnsscience.io DNS caches instead of system resolvers |
| `--level` | `-l` | Output verbosity level (short/long/detail/verbose/debug) |
| `--json` | `-j` | Output in JSON format |
| `--no-color` | | Disable colored output |
| `--config` | `-c` | Path to config file |

### Embedded DNS (`--embedded-dns`, `-ed`)

When enabled, queries use the dnsscience.io DNS cache infrastructure instead of system resolvers:

- `cache01.dnsscience.io` (primary)
- `cache02.dnsscience.io` (secondary)
- `cache03.dnsscience.io` (tertiary)
- `cache04.dnsscience.io` (quaternary)

Benefits:
- Consistent results across environments
- Pre-warmed cache for faster responses
- DNSSEC validation enabled by default
- Query logging for debugging (when using API key)

---

## 3. Command Reference

### 3.1 Query Command - `onedns query`

The primary DNS lookup command with unprecedented detail levels.

```bash
onedns query <target> [record-type] [--level <level>] [flags]

# Record Types
all | a | aaaa | cname | txt | ns | ptr | soa | mx | srv |
dnskey | ds | rrsig | nsec | nsec3 | tsig | caa | tlsa |
sshfp | naptr | loc | hinfo | cert | dname | any

# Output Levels
--level short    # One-line answer only
--level long     # Answer with TTL and type (default)
--level detail   # Full response sections
--level verbose  # Explanations + timing
--level debug    # Wire-level packet dump
```

#### Query Examples

```bash
# Basic queries
onedns query example.com                    # A record, long output
onedns query example.com mx                 # MX records
onedns query example.com all                # All common record types
onedns query example.com any --level debug  # ANY query with packet dump

# DNSSEC queries
onedns query example.com dnskey --dnssec    # Fetch DNSKEY with validation
onedns query example.com ds                 # DS records from parent

# Advanced options
onedns query example.com --trace            # Trace from root to answer
onedns query example.com --server 8.8.8.8   # Use specific resolver
onedns query example.com --tcp              # Force TCP
onedns query example.com --timeout 10s      # Custom timeout
onedns query example.com --retries 3        # Retry count

# Embedded DNS - use dnsscience.io cache servers
onedns query example.com --embedded-dns     # Use cache01-04.dnsscience.io
onedns query example.com -ed                # Short form
```

#### Query Output Levels

**Level: short**
```
93.184.216.34
```

**Level: long** (default)
```
example.com.    86400   IN  A   93.184.216.34
```

**Level: detail**
```
;; QUERY: example.com. IN A
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 2, ADDITIONAL: 1

;; QUESTION SECTION:
;example.com.                   IN      A

;; ANSWER SECTION:
example.com.            86400   IN      A       93.184.216.34

;; AUTHORITY SECTION:
example.com.            172800  IN      NS      a.iana-servers.net.
example.com.            172800  IN      NS      b.iana-servers.net.

;; Query time: 23 msec
;; SERVER: 8.8.8.8#53(8.8.8.8)
;; WHEN: Mon Dec 30 10:00:00 UTC 2024
;; MSG SIZE  rcvd: 93
```

**Level: verbose**
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                         DNS QUERY ANALYSIS                                    ║
╠══════════════════════════════════════════════════════════════════════════════╣
║ Target: example.com                                                          ║
║ Type: A (IPv4 Address)                                                       ║
║ Class: IN (Internet)                                                         ║
╠══════════════════════════════════════════════════════════════════════════════╣

┌─ RESPONSE HEADER ────────────────────────────────────────────────────────────┐
│ Transaction ID: 0x3039 (12345)                                               │
│ Flags:                                                                       │
│   QR (Query/Response):     1 (Response)                                      │
│   OPCODE:                  0 (Standard Query)                                │
│   AA (Authoritative):      0 (Not Authoritative)                             │
│   TC (Truncated):          0 (Not Truncated)                                 │
│   RD (Recursion Desired):  1 (Recursion Requested)                           │
│   RA (Recursion Avail):    1 (Recursion Available)                           │
│   AD (Authentic Data):     1 (DNSSEC Validated)                              │
│   CD (Checking Disabled):  0 (DNSSEC Checking Enabled)                       │
│   RCODE:                   0 (NOERROR - No Error)                            │
│ Counts: Questions=1, Answers=1, Authority=2, Additional=1                    │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ ANSWER SECTION ─────────────────────────────────────────────────────────────┐
│ example.com.    86400   IN   A   93.184.216.34                               │
│                                                                              │
│ 📝 Explanation:                                                              │
│    • This A record maps example.com to IPv4 address 93.184.216.34            │
│    • TTL of 86400 seconds (24 hours) indicates moderate caching              │
│    • IP belongs to: EDGECAST (AS15133) - CDN provider                        │
│    • Geolocation: Los Angeles, California, United States                     │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ DNSSEC STATUS ──────────────────────────────────────────────────────────────┐
│ ✅ DNSSEC Validation: SECURE                                                 │
│    • DS record found in parent zone (.com)                                   │
│    • DNSKEY algorithm: ECDSAP256SHA256 (Algorithm 13)                        │
│    • Key tag: 31406                                                          │
│    • Signature covers answer, valid until 2025-01-15                         │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ TIMING & TRANSPORT ─────────────────────────────────────────────────────────┐
│ Resolver:        8.8.8.8:53 (Google Public DNS)                              │
│ Transport:       UDP                                                         │
│ Response Size:   93 bytes                                                    │
│ Query Time:      23ms                                                        │
│ RTT Breakdown:                                                               │
│   • Network:     18ms                                                        │
│   • Processing:  5ms                                                         │
└──────────────────────────────────────────────────────────────────────────────┘
```

**Level: debug**
```
╔══════════════════════════════════════════════════════════════════════════════╗
║                      WIRE-LEVEL DNS PACKET ANALYSIS                          ║
╠══════════════════════════════════════════════════════════════════════════════╣

┌─ RAW QUERY PACKET (47 bytes) ────────────────────────────────────────────────┐
│ Offset  Hex                                              ASCII               │
│ 0x0000  30 39 01 00 00 01 00 00 00 00 00 01 07 65 78 61  09......exa        │
│ 0x0010  6d 70 6c 65 03 63 6f 6d 00 00 01 00 01 00 00 29  mple.com.......)   │
│ 0x0020  10 00 00 00 00 00 00 00                          ........           │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ PARSED QUERY ───────────────────────────────────────────────────────────────┐
│ Header (12 bytes):                                                           │
│   ID:     0x3039 (12345)                                                     │
│   Flags:  0x0100                                                             │
│           0... .... .... .... = Query (QR=0)                                 │
│           .000 0... .... .... = Standard Query (OPCODE=0)                    │
│           .... .0.. .... .... = Not Authoritative (AA=0)                     │
│           .... ..0. .... .... = Not Truncated (TC=0)                         │
│           .... ...1 .... .... = Recursion Desired (RD=1)                     │
│           .... .... 0... .... = Recursion Not Available (RA=0)               │
│           .... .... .0.. .... = Reserved (Z=0)                               │
│           .... .... ..0. .... = Not Authenticated (AD=0)                     │
│           .... .... ...0 .... = Checking Enabled (CD=0)                      │
│           .... .... .... 0000 = No Error (RCODE=0)                           │
│   QDCOUNT: 1  ANCOUNT: 0  NSCOUNT: 0  ARCOUNT: 1                             │
│                                                                              │
│ Question Section:                                                            │
│   Name: example.com. (encoded: 07 65 78 61 6d 70 6c 65 03 63 6f 6d 00)      │
│   Type: A (0x0001)                                                           │
│   Class: IN (0x0001)                                                         │
│                                                                              │
│ Additional Section (EDNS0 OPT):                                              │
│   Name: <root>                                                               │
│   Type: OPT (41)                                                             │
│   UDP Payload Size: 4096                                                     │
│   Extended RCODE: 0                                                          │
│   Version: 0                                                                 │
│   DNSSEC OK (DO): 0                                                          │
│   Data Length: 0                                                             │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ RAW RESPONSE PACKET (93 bytes) ─────────────────────────────────────────────┐
│ Offset  Hex                                              ASCII               │
│ 0x0000  30 39 81 80 00 01 00 01 00 02 00 01 07 65 78 61  09...........exa   │
│ 0x0010  6d 70 6c 65 03 63 6f 6d 00 00 01 00 01 c0 0c 00  mple.com........   │
│ 0x0020  01 00 01 00 01 51 80 00 04 5d b8 d8 22 c0 0c 00  .....Q...]..".    │
│ ...                                                                          │
└──────────────────────────────────────────────────────────────────────────────┘

[... Full parsed response with compression pointer analysis ...]
```

---

### 2.2 Debug Command - `onedns debug`

Comprehensive DNS debugging toolkit.

```bash
onedns debug <subcommand> [flags]

Subcommands:
  trace       Trace resolution path from root
  compare     Compare responses from multiple resolvers
  latency     Measure resolver latency
  propagation Check DNS propagation globally
  cache       Analyze caching behavior
  glue        Verify glue record consistency
  delegation  Check NS delegation chain
  recursion   Test recursion behavior
  axfr        Attempt zone transfer (if permitted)
  notify      Send DNS NOTIFY
```

#### Debug Examples

```bash
# Trace full resolution path
onedns debug trace example.com
  Output:
  ┌─ Resolution Trace: example.com ────────────────────────────────────────────┐
  │                                                                            │
  │ Step 1: Root Servers (.)                                                   │
  │   Query: . NS                                                              │
  │   Server: a.root-servers.net (198.41.0.4)                                  │
  │   Response: Referral to .com TLD                                           │
  │   Time: 12ms                                                               │
  │                                                                            │
  │ Step 2: .com TLD                                                           │
  │   Query: example.com NS                                                    │
  │   Server: a.gtld-servers.net (192.5.6.30)                                  │
  │   Response: Referral to example.com nameservers                            │
  │   Time: 18ms                                                               │
  │                                                                            │
  │ Step 3: Authoritative (example.com)                                        │
  │   Query: example.com A                                                     │
  │   Server: a.iana-servers.net (199.43.135.53)                               │
  │   Response: 93.184.216.34 (Authoritative)                                  │
  │   Time: 8ms                                                                │
  │                                                                            │
  │ Total Resolution Time: 38ms (3 steps)                                      │
  │ DNSSEC Chain: ✅ VALID (. → com. → example.com.)                           │
  └────────────────────────────────────────────────────────────────────────────┘

# Compare resolvers
onedns debug compare example.com --resolvers 8.8.8.8,1.1.1.1,9.9.9.9
  Output:
  ┌─ Resolver Comparison: example.com A ───────────────────────────────────────┐
  │                                                                            │
  │ Resolver          IP              Answer           TTL    Time   DNSSEC   │
  │ ─────────────────────────────────────────────────────────────────────────  │
  │ Google (8.8.8.8)  8.8.8.8         93.184.216.34    86400  12ms   ✅        │
  │ Cloudflare        1.1.1.1         93.184.216.34    86400  8ms    ✅        │
  │ Quad9             9.9.9.9         93.184.216.34    86400  15ms   ✅        │
  │                                                                            │
  │ Consensus: ✅ All resolvers agree                                          │
  │ Fastest: Cloudflare (1.1.1.1) at 8ms                                       │
  └────────────────────────────────────────────────────────────────────────────┘

# Global propagation check
onedns debug propagation example.com --type A
  Output:
  ┌─ Global DNS Propagation: example.com A ────────────────────────────────────┐
  │                                                                            │
  │ Region            Location         Resolver            Status    Value     │
  │ ─────────────────────────────────────────────────────────────────────────  │
  │ North America     San Francisco    Level3              ✅        93.184... │
  │ North America     New York         Verizon             ✅        93.184... │
  │ Europe            London           BT                  ✅        93.184... │
  │ Europe            Frankfurt        Deutsche Telekom    ✅        93.184... │
  │ Asia Pacific      Tokyo            NTT                 ✅        93.184... │
  │ Asia Pacific      Singapore        Singtel             ✅        93.184... │
  │ ...                                                                        │
  │                                                                            │
  │ Propagation: 100% (24/24 resolvers)                                        │
  │ TTL Range: 86400-86400 (consistent)                                        │
  └────────────────────────────────────────────────────────────────────────────┘

# Delegation chain verification
onedns debug delegation example.com
  Output:
  ┌─ Delegation Chain Analysis: example.com ───────────────────────────────────┐
  │                                                                            │
  │ Zone              Nameservers                    Glue Records              │
  │ ─────────────────────────────────────────────────────────────────────────  │
  │ . (root)          a.root-servers.net             198.41.0.4                │
  │                   b.root-servers.net             199.9.14.201              │
  │                   ... (13 total)                                           │
  │                                                                            │
  │ com.              a.gtld-servers.net             192.5.6.30                │
  │                   b.gtld-servers.net             192.33.14.30              │
  │                   ... (13 total)                                           │
  │                                                                            │
  │ example.com.      a.iana-servers.net             199.43.135.53             │
  │                   b.iana-servers.net             199.43.133.53             │
  │                                                                            │
  │ Delegation Status:                                                         │
  │   ✅ All NS records have matching glue records                             │
  │   ✅ All nameservers respond authoritatively                               │
  │   ✅ SOA serials match across all NS (2024123001)                          │
  │   ✅ DNSSEC delegation secure                                              │
  └────────────────────────────────────────────────────────────────────────────┘
```

---

### 2.3 Packet Forge Command - `onedns mkpacket`

Construct custom DNS packets for testing and research.

```bash
onedns mkpacket <packet-type> [flags]

Packet Types:
  query       Construct DNS query packet
  response    Construct DNS response packet
  notify      Construct DNS NOTIFY packet
  update      Construct DNS UPDATE packet
  axfr        Construct AXFR request

Flags:
  --id <id>           Transaction ID (random if not specified)
  --flags <flags>     Header flags (e.g., "qr,aa,rd")
  --question <q>      Question section (name:type:class)
  --answer <a>        Answer RR (name:ttl:type:rdata)
  --authority <a>     Authority RR
  --additional <a>    Additional RR
  --edns              Include EDNS0 OPT record
  --edns-size <n>     EDNS UDP payload size (default 4096)
  --dnssec-ok         Set DNSSEC OK flag
  --tsig <key>        Sign with TSIG
  --output <format>   Output format: hex, base64, binary, annotated
  --send <server>     Send packet to server and show response
```

#### Packet Examples

```bash
# Create standard A query
onedns mkpacket query --question example.com:A:IN --output annotated
  Output:
  ┌─ DNS QUERY PACKET ─────────────────────────────────────────────────────────┐
  │                                                                            │
  │ ; Header                                                                   │
  │ ;  ID: 0x7b2f (31535)                                                      │
  │ ;  Flags: 0x0100 (RD=1)                                                    │
  │ ;  Questions: 1, Answers: 0, Authority: 0, Additional: 0                   │
  │                                                                            │
  │ ; Question Section                                                         │
  │ ;example.com.                  IN      A                                   │
  │                                                                            │
  │ ; Wire Format (30 bytes):                                                  │
  │ 7b 2f 01 00 00 01 00 00 00 00 00 00 07 65 78 61                            │
  │ 6d 70 6c 65 03 63 6f 6d 00 00 01 00 01                                     │
  │                                                                            │
  │ ; Base64: ey8BAAAAAAAAAAAAAAFlxYWmucGxlA2NvbQAAAQAB                         │
  └────────────────────────────────────────────────────────────────────────────┘

# Create malformed packet for testing (truncated)
onedns mkpacket query --question test.example.com:A:IN --flags "qr,tc" --output hex
  Output: 7b2f8500000100000000000004746573740765...

# Create DNS UPDATE for dynamic DNS
onedns mkpacket update \
  --zone example.com \
  --prerequisite "yxrrset:host.example.com:A" \
  --update "delete:host.example.com:A" \
  --update "add:host.example.com:300:A:192.168.1.100" \
  --tsig hmac-sha256:keyname:base64secret \
  --send ns1.example.com

# Create EDNS query with large UDP size and DNSSEC
onedns mkpacket query \
  --question example.com:DNSKEY:IN \
  --edns \
  --edns-size 4096 \
  --dnssec-ok \
  --send 8.8.8.8
```

---

### 2.4 DNSSEC Key Commands - `onedns makekey`

Generate and manage DNSSEC keys.

```bash
onedns makekey [flags]

Flags:
  --algorithm <alg>   Algorithm: RSASHA256, RSASHA512, ECDSAP256SHA256,
                      ECDSAP384SHA384, ED25519, ED448 (default: ECDSAP256SHA256)
  --type <type>       Key type: ZSK (Zone Signing) or KSK (Key Signing)
  --bits <n>          Key size in bits (for RSA)
  --zone <zone>       Zone name for key
  --output <dir>      Output directory
  --format <fmt>      Output format: bind, powerdns, knot
```

#### Key Generation Examples

```bash
# Generate ECDSA P-256 KSK (recommended)
onedns makekey --algorithm ECDSAP256SHA256 --type KSK --zone example.com
  Output:
  ┌─ DNSSEC Key Generation ────────────────────────────────────────────────────┐
  │                                                                            │
  │ Zone: example.com.                                                         │
  │ Type: KSK (Key Signing Key)                                                │
  │ Algorithm: 13 (ECDSAP256SHA256)                                            │
  │ Key Tag: 31406                                                             │
  │                                                                            │
  │ Files Created:                                                             │
  │   Kexample.com.+013+31406.key    (public key)                              │
  │   Kexample.com.+013+31406.private (private key)                            │
  │                                                                            │
  │ DNSKEY Record:                                                             │
  │ example.com. IN DNSKEY 257 3 13 (                                          │
  │   mdsswUyr3DPW132mOi8V9xESWE8jTo0dxCjjnopKl+GqJxpVXckHAeF+                 │
  │   KkxLbxILfDLUT0rAK9iUzy1L53eKGQ== )                                       │
  │                                                                            │
  │ DS Record (for parent zone):                                               │
  │ example.com. IN DS 31406 13 2 (                                            │
  │   E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D )       │
  │                                                                            │
  │ ⚠️  Store private key securely! It can sign any record in your zone.       │
  └────────────────────────────────────────────────────────────────────────────┘

# Generate ZSK with RSA (legacy compatibility)
onedns makekey --algorithm RSASHA256 --type ZSK --bits 2048 --zone example.com

# Generate Ed25519 keys (modern, fast)
onedns makekey --algorithm ED25519 --type KSK --zone example.com
```

---

### 2.5 Email Security Commands

#### SPF Commands - `onedns spf`

```bash
onedns spf <subcommand> <domain> [flags]

Subcommands:
  get         Fetch and display SPF record
  validate    Check SPF syntax and semantics
  test        Test if IP/host passes SPF
  make        Generate SPF record interactively
  flatten     Flatten SPF includes to IPs
  lookup      Count DNS lookups in SPF
```

##### SPF Examples

```bash
# Get SPF record with analysis
onedns spf get google.com --level verbose
  Output:
  ┌─ SPF Analysis: google.com ─────────────────────────────────────────────────┐
  │                                                                            │
  │ Raw Record:                                                                │
  │ v=spf1 include:_spf.google.com ~all                                        │
  │                                                                            │
  │ Parsed Mechanisms:                                                         │
  │   #1  include:_spf.google.com                                              │
  │       └─ Expands to: ip4:172.217.0.0/19 ip4:172.217.32.0/20 ...            │
  │   #2  ~all (SoftFail)                                                      │
  │       └─ Non-matching IPs get SoftFail result                              │
  │                                                                            │
  │ DNS Lookups: 4 of 10 maximum                                               │
  │   └─ _spf.google.com → _netblocks.google.com → ...                         │
  │                                                                            │
  │ Total Authorized IPs: ~2.1 million                                         │
  │ Policy Strength: MODERATE (SoftFail allows delivery)                       │
  │                                                                            │
  │ Recommendations:                                                           │
  │   ⚠️  Consider using -all instead of ~all for stricter enforcement         │
  └────────────────────────────────────────────────────────────────────────────┘

# Test if an IP passes SPF
onedns spf test google.com --ip 172.217.14.99 --sender user@google.com
  Output:
  ┌─ SPF Test Result ──────────────────────────────────────────────────────────┐
  │ Domain: google.com                                                         │
  │ Client IP: 172.217.14.99                                                   │
  │ Sender: user@google.com                                                    │
  │                                                                            │
  │ Result: ✅ PASS                                                            │
  │                                                                            │
  │ Matched Mechanism: ip4:172.217.0.0/19                                      │
  │ Lookup Path: v=spf1 → include:_spf.google.com → ip4:172.217.0.0/19         │
  └────────────────────────────────────────────────────────────────────────────┘

# Generate SPF record
onedns spf make example.com
  Interactive:
  ? Include your mail server IPs? [Y/n] Y
  ? Enter IPv4 addresses (comma-separated): 192.168.1.10, 192.168.1.11
  ? Include third-party senders?
    ❯ Google Workspace (include:_spf.google.com)
      Microsoft 365 (include:spf.protection.outlook.com)
      Mailchimp (include:servers.mcsv.net)
      [Add custom include]
  ? SPF failure policy?
    ❯ Reject (-all) - Recommended
      SoftFail (~all) - Delivers but marks suspicious
      Neutral (?all) - No policy

  Generated SPF Record:
  v=spf1 ip4:192.168.1.10 ip4:192.168.1.11 include:_spf.google.com -all

# Flatten SPF (resolve all includes to IPs)
onedns spf flatten example.com
  Output:
  v=spf1 ip4:192.168.1.10 ip4:192.168.1.11 ip4:172.217.0.0/19 ip4:172.217.32.0/20
         ip4:172.217.128.0/19 ... -all
```

#### DKIM Commands - `onedns dkim`

```bash
onedns dkim <subcommand> [flags]

Subcommands:
  get         Fetch DKIM record for selector
  validate    Verify DKIM record syntax
  discover    Find DKIM selectors for domain
  verify      Verify DKIM signature in email
  makekey     Generate DKIM key pair
```

##### DKIM Examples

```bash
# Discover DKIM selectors
onedns dkim discover google.com
  Output:
  ┌─ DKIM Selector Discovery: google.com ──────────────────────────────────────┐
  │                                                                            │
  │ Found Selectors:                                                           │
  │                                                                            │
  │ Selector: google                                                           │
  │   Record: google._domainkey.google.com                                     │
  │   Algorithm: rsa-sha256                                                    │
  │   Key Size: 2048 bits                                                      │
  │   Status: ✅ Valid                                                         │
  │                                                                            │
  │ Selector: 20230601                                                         │
  │   Record: 20230601._domainkey.google.com                                   │
  │   Algorithm: rsa-sha256                                                    │
  │   Key Size: 2048 bits                                                      │
  │   Status: ✅ Valid                                                         │
  │                                                                            │
  │ Selectors Checked: 50                                                      │
  │ Selectors Found: 2                                                         │
  │                                                                            │
  │ Common Selector Names Tried:                                               │
  │   default, selector1, selector2, google, s1, s2, mail, email, dkim, k1,   │
  │   20230601, 20230701, ... (date-based patterns)                            │
  └────────────────────────────────────────────────────────────────────────────┘

# Generate DKIM keys
onedns dkim makekey --selector mail --domain example.com --bits 2048
  Output:
  ┌─ DKIM Key Generation ──────────────────────────────────────────────────────┐
  │                                                                            │
  │ Domain: example.com                                                        │
  │ Selector: mail                                                             │
  │ Algorithm: RSA-SHA256                                                      │
  │ Key Size: 2048 bits                                                        │
  │                                                                            │
  │ DNS TXT Record (mail._domainkey.example.com):                              │
  │ v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...         │
  │                                                                            │
  │ Files Created:                                                             │
  │   mail.private.pem   (private key for mail server)                         │
  │   mail.public.pem    (public key for DNS)                                  │
  │   mail.dns.txt       (ready-to-use DNS record)                             │
  └────────────────────────────────────────────────────────────────────────────┘
```

#### DMARC Commands - `onedns dmarc`

```bash
onedns dmarc <subcommand> <domain> [flags]

Subcommands:
  get         Fetch and analyze DMARC record
  validate    Check DMARC configuration
  make        Generate DMARC record
  report      Parse DMARC aggregate report
```

##### DMARC Examples

```bash
# Get DMARC with full analysis
onedns dmarc get microsoft.com --level verbose
  Output:
  ┌─ DMARC Analysis: microsoft.com ────────────────────────────────────────────┐
  │                                                                            │
  │ Raw Record:                                                                │
  │ v=DMARC1; p=reject; pct=100; rua=mailto:d@rua.contoso.com;                 │
  │ ruf=mailto:d@ruf.contoso.com; fo=1; adkim=s; aspf=s                        │
  │                                                                            │
  │ ┌─ Policy Configuration ───────────────────────────────────────────────┐   │
  │ │ Policy (p):            reject   → Reject unauthenticated mail        │   │
  │ │ Subdomain Policy (sp): reject   → Same for subdomains (inherited)    │   │
  │ │ Percentage (pct):      100%     → Apply to all messages              │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ Alignment Settings ─────────────────────────────────────────────────┐   │
  │ │ DKIM Alignment (adkim): strict  → DKIM domain must exactly match     │   │
  │ │ SPF Alignment (aspf):   strict  → SPF domain must exactly match      │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ Reporting ──────────────────────────────────────────────────────────┐   │
  │ │ Aggregate Reports (rua): mailto:d@rua.contoso.com                    │   │
  │ │ Forensic Reports (ruf):  mailto:d@ruf.contoso.com                    │   │
  │ │ Failure Options (fo):    1 (report on any failure)                   │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ Security Grade: A+ (Maximum Protection)                                    │
  │                                                                            │
  │ ✅ Best Practices Met:                                                     │
  │    • Policy is set to 'reject' (strongest)                                 │
  │    • 100% of messages covered                                              │
  │    • Strict alignment for both SPF and DKIM                                │
  │    • Aggregate and forensic reporting enabled                              │
  └────────────────────────────────────────────────────────────────────────────┘

# Generate DMARC record interactively
onedns dmarc make example.com
  Interactive:
  ? What policy for failing emails?
    ❯ reject (Recommended for established domains)
      quarantine (Good for testing)
      none (Monitor only)

  ? Apply to what percentage of mail? 100

  ? Where to send aggregate reports? dmarc-reports@example.com

  ? Enable forensic reports? [Y/n] Y
  ? Forensic report email? forensics@example.com

  ? DKIM alignment mode?
    ❯ relaxed (Allow subdomains)
      strict (Exact domain match only)

  Generated DMARC Record (_dmarc.example.com TXT):
  v=DMARC1; p=reject; pct=100; rua=mailto:dmarc-reports@example.com;
  ruf=mailto:forensics@example.com; adkim=r; aspf=r; fo=1
```

#### TXT Record Validation - `onedns txt`

```bash
onedns txt <host> <subcommand> [flags]

Subcommands:
  get         Fetch all TXT records
  validate    Validate TXT record syntax
  search      Search for specific TXT patterns
```

##### TXT Examples

```bash
# Get all TXT records with analysis
onedns txt google.com get --level verbose
  Output:
  ┌─ TXT Records: google.com ──────────────────────────────────────────────────┐
  │                                                                            │
  │ Record #1: SPF                                                             │
  │   v=spf1 include:_spf.google.com ~all                                      │
  │   Purpose: Email sender authentication                                     │
  │   Status: ✅ Valid SPF record                                              │
  │                                                                            │
  │ Record #2: Domain Verification (Google)                                    │
  │   google-site-verification=wD8N7i1JTNTkezJ49swvWW48f8_9xveREV4oB-0Hf5o     │
  │   Purpose: Google Search Console verification                              │
  │                                                                            │
  │ Record #3: Domain Verification (Facebook)                                  │
  │   facebook-domain-verification=22rm551cu4k0ab0bxsw536tlds4h95              │
  │   Purpose: Facebook Business verification                                  │
  │                                                                            │
  │ Record #4: DMARC (at _dmarc.google.com)                                    │
  │   v=DMARC1; p=reject; rua=mailto:...                                       │
  │   Purpose: Email authentication policy                                     │
  │   Status: ✅ Valid DMARC record                                            │
  │                                                                            │
  │ Record #5: MTA-STS (at _mta-sts.google.com)                                │
  │   v=STSv1; id=20231201T010101                                              │
  │   Purpose: SMTP TLS enforcement                                            │
  │   Status: ✅ Valid MTA-STS record                                          │
  │                                                                            │
  │ Summary:                                                                   │
  │   Total TXT records: 5                                                     │
  │   Email security: SPF ✅, DKIM ✅, DMARC ✅, MTA-STS ✅                       │
  └────────────────────────────────────────────────────────────────────────────┘
```

---

### 2.6 Appliance Integration - `onedns appliance`

Manage DDI appliance connections.

```bash
onedns appliance <subcommand> [flags]

Subcommands:
  set         Configure appliance connection
  get         Show current configuration
  test        Test appliance connectivity
  sync        Sync records from appliance

Appliance Types:
  infoblox    Infoblox NIOS (WAPI)
  bluecat     BlueCat Address Manager

Flags:
  --url <url>         Appliance URL
  --username <user>   API username
  --password <pass>   API password (or use --password-file)
  --api-key <key>     API key (alternative to username/password)
  --version <ver>     API version
  --insecure          Skip TLS verification (not recommended)
```

#### Appliance Examples

```bash
# Configure Infoblox
onedns appliance set infoblox \
  --url https://infoblox.example.com \
  --username admin \
  --password-file ~/.infoblox-pass \
  --version 2.11

# Test connection
onedns appliance test infoblox
  Output:
  ┌─ Infoblox Connection Test ─────────────────────────────────────────────────┐
  │                                                                            │
  │ URL: https://infoblox.example.com                                          │
  │ Version: WAPI v2.11                                                        │
  │                                                                            │
  │ Connection: ✅ Successful                                                  │
  │ Authentication: ✅ Valid credentials                                       │
  │ Grid Status: Active                                                        │
  │ Grid Master: gm.example.com                                                │
  │ Members: 3                                                                 │
  │                                                                            │
  │ Available Permissions:                                                     │
  │   ✅ Read zones                                                            │
  │   ✅ Read records                                                          │
  │   ✅ Create records                                                        │
  │   ✅ Modify records                                                        │
  │   ❌ Delete zones (insufficient permissions)                               │
  └────────────────────────────────────────────────────────────────────────────┘

# Query records from Infoblox
onedns appliance query infoblox "host.example.com" --type A
  Output:
  ┌─ Infoblox Record Query ────────────────────────────────────────────────────┐
  │                                                                            │
  │ host.example.com                                                           │
  │                                                                            │
  │ Record Type: A (Host Record)                                               │
  │ IP Address: 192.168.1.100                                                  │
  │ View: default                                                              │
  │ Zone: example.com                                                          │
  │ TTL: 3600                                                                  │
  │                                                                            │
  │ Infoblox Metadata:                                                         │
  │   Reference: record:host/ZG5zLmhvc3QkLl9kZWZhdWx0...                       │
  │   Created: 2024-01-15 10:30:00 by admin                                    │
  │   Modified: 2024-06-20 14:22:00 by dns-admin                               │
  │   Comment: Production web server                                           │
  │   Extensible Attributes:                                                   │
  │     Environment: Production                                                │
  │     Owner: WebOps Team                                                     │
  └────────────────────────────────────────────────────────────────────────────┘

# Configure BlueCat
onedns appliance set bluecat \
  --url https://bluecat.example.com \
  --api-key $BLUECAT_API_KEY
```

---

### 2.7 Zone Validation - `onedns validate`

Validate zone files and DNS configurations.

```bash
onedns validate <type> <path> [flags]

Types:
  zone        Validate zone file
  config      Validate DNS server config

Platforms (for config validation):
  bind        BIND named.conf
  powerdns    PowerDNS config
  unbound     Unbound config
  nsd         NSD config
  djbdns      djbdns/tinydns data

Flags:
  --strict        Enable strict validation
  --fix           Attempt to fix issues
  --output <fmt>  Output format: text, json, junit
```

#### Validation Examples

```bash
# Validate BIND zone file
onedns validate zone /etc/bind/zones/example.com.zone --platform bind
  Output:
  ┌─ Zone Validation: example.com ─────────────────────────────────────────────┐
  │                                                                            │
  │ File: /etc/bind/zones/example.com.zone                                     │
  │ Format: BIND zone file                                                     │
  │ Records: 47                                                                │
  │                                                                            │
  │ ┌─ SOA Record ─────────────────────────────────────────────────────────┐   │
  │ │ Primary NS: ns1.example.com                                          │   │
  │ │ Admin: admin.example.com                                             │   │
  │ │ Serial: 2024123001                                                   │   │
  │ │ Refresh: 86400 (1 day)                                               │   │
  │ │ Retry: 7200 (2 hours)                                                │   │
  │ │ Expire: 3600000 (~42 days)                                           │   │
  │ │ Minimum: 172800 (2 days)                                             │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ Errors (2):                                                                │
  │   ❌ Line 23: CNAME at apex (example.com CNAME other.com)                  │
  │      RFC 1912: CNAME records cannot exist at zone apex                     │
  │                                                                            │
  │   ❌ Line 45: Missing glue record                                          │
  │      NS record ns3.example.com has no A/AAAA record in zone                │
  │                                                                            │
  │ Warnings (3):                                                              │
  │   ⚠️  Line 12: TTL mismatch in RRset                                       │
  │      www.example.com has A records with different TTLs (300, 3600)         │
  │                                                                            │
  │   ⚠️  SOA serial format not YYYYMMDDNN                                     │
  │      Current: 2024123001 (valid but recommend date-based)                  │
  │                                                                            │
  │   ⚠️  No DNSSEC records found                                              │
  │      Consider signing zone for security                                    │
  │                                                                            │
  │ Info:                                                                      │
  │   ℹ️  SPF record found and valid                                           │
  │   ℹ️  DMARC record found and valid                                         │
  │   ℹ️  MX records properly prioritized                                      │
  │                                                                            │
  │ Result: ❌ FAILED (2 errors, 3 warnings)                                   │
  └────────────────────────────────────────────────────────────────────────────┘

# Validate BIND configuration
onedns validate config /etc/bind/named.conf --platform bind --strict
  Output:
  ┌─ BIND Configuration Validation ────────────────────────────────────────────┐
  │                                                                            │
  │ Main Config: /etc/bind/named.conf                                          │
  │ Included Files: 4                                                          │
  │                                                                            │
  │ Zones Defined: 12                                                          │
  │   Primary: 8                                                               │
  │   Secondary: 3                                                             │
  │   Hint: 1                                                                  │
  │                                                                            │
  │ Security Analysis:                                                         │
  │   ✅ Recursion disabled for external queries                               │
  │   ✅ Version hiding enabled                                                │
  │   ✅ Query logging enabled                                                 │
  │   ⚠️  Rate limiting not configured (consider adding)                       │
  │   ❌ Zone transfers allowed from any (should restrict)                     │
  │                                                                            │
  │ DNSSEC:                                                                    │
  │   ✅ DNSSEC validation enabled                                             │
  │   ✅ Managed keys configured                                               │
  │   ⚠️  3 zones not signed (example.com, test.com, dev.example.com)          │
  │                                                                            │
  │ Performance:                                                               │
  │   ⚠️  Max cache size not set (using default)                               │
  │   ✅ TCP clients limit configured (1000)                                   │
  │                                                                            │
  │ Result: ⚠️  PASSED with warnings (0 errors, 4 warnings)                    │
  └────────────────────────────────────────────────────────────────────────────┘
```

---

### 2.8 Zone Import/Export - `onedns zone`

Import DNS zones from live nameservers using AXFR, IXFR, or zone walking techniques. Export zones to various formats.

```bash
onedns zone import <domain> [flags]
onedns zone export <domain> [flags]

Import Methods:
  axfr          Full zone transfer (AXFR)
  ixfr          Incremental zone transfer (IXFR)
  walk          Zone walking via NSEC/NSEC3
  enumerate     Intelligent enumeration (like Cloudflare import)

Export Formats:
  bind          BIND zone file format
  json          JSON structured format
  csv           CSV format
  yaml          YAML format
  dnsscienced   DNSScienced native format
  terraform     Terraform DNS resources

Flags:
  --server <ns>         Nameserver to query (default: authoritative NS)
  --method <method>     Import method (default: auto-detect)
  --tsig-key <key>      TSIG key for authenticated transfer
  --output <file>       Output file path
  --format <fmt>        Export format
  --include-dnssec      Include DNSSEC records
  --strip-comments      Remove comments from zone
  --sort                Sort records alphabetically
```

#### Zone Import Examples

```bash
# Import via AXFR (zone transfer)
onedns zone import example.com --method axfr
  Output:
  ┌─ Zone Import: example.com ─────────────────────────────────────────────────┐
  │                                                                            │
  │ Method: AXFR (Full Zone Transfer)                                          │
  │ Nameserver: ns1.example.com (203.0.113.1)                                  │
  │ Zone: example.com                                                          │
  │                                                                            │
  │ Transfer Progress:                                                         │
  │ [████████████████████████████████████████] 100%                            │
  │                                                                            │
  │ Records Imported:                                                          │
  │   SOA:        1                                                            │
  │   NS:         4                                                            │
  │   A:          127                                                          │
  │   AAAA:       45                                                           │
  │   CNAME:      38                                                           │
  │   MX:         5                                                            │
  │   TXT:        12                                                           │
  │   SRV:        3                                                            │
  │   DNSKEY:     2   (DNSSEC)                                                 │
  │   RRSIG:      156 (DNSSEC)                                                 │
  │   NSEC3:      312 (DNSSEC)                                                 │
  │   ─────────────────                                                        │
  │   Total:      705 records                                                  │
  │                                                                            │
  │ Zone saved to: example.com.zone                                            │
  │ Format: BIND zone file                                                     │
  │                                                                            │
  │ ✅ Import completed in 1.23s                                                │
  └────────────────────────────────────────────────────────────────────────────┘

# Import via zone walking (when AXFR is blocked)
onedns zone import example.com --method walk --level verbose
  Output:
  ┌─ Zone Import: example.com (NSEC Walking) ──────────────────────────────────┐
  │                                                                            │
  │ Method: NSEC Chain Walking                                                 │
  │ AXFR Status: ❌ Refused (attempting zone walk)                             │
  │                                                                            │
  │ Starting from: example.com (SOA)                                           │
  │ Walking NSEC chain...                                                      │
  │                                                                            │
  │ Discovered Records:                                                        │
  │   1. example.com                    → SOA, NS, A, MX, TXT                  │
  │   2. _dmarc.example.com             → TXT                                  │
  │   3. api.example.com                → A, AAAA                              │
  │   4. autodiscover.example.com       → CNAME                                │
  │   5. blog.example.com               → A                                    │
  │   6. cdn.example.com                → CNAME                                │
  │   7. ftp.example.com                → A                                    │
  │   8. mail.example.com               → A, MX                                │
  │   9. ns1.example.com                → A, AAAA                              │
  │  10. ns2.example.com                → A, AAAA                              │
  │  11. shop.example.com               → A                                    │
  │  12. webmail.example.com            → CNAME                                │
  │  13. www.example.com                → A, AAAA                              │
  │                                                                            │
  │ [████████████████████████████] 13 names discovered                         │
  │                                                                            │
  │ Total Records: 47                                                          │
  │ Walk Time: 2.8s                                                            │
  │                                                                            │
  │ ⚠️  Note: NSEC walking only discovers existing names, may miss some        │
  │    records in zones with NSEC3 hashing or opt-out                          │
  │                                                                            │
  │ Zone saved to: example.com.zone                                            │
  └────────────────────────────────────────────────────────────────────────────┘

# Import using intelligent enumeration (Cloudflare-style)
onedns zone import example.com --method enumerate --level verbose
  Output:
  ┌─ Zone Import: example.com (Smart Enumeration) ─────────────────────────────┐
  │                                                                            │
  │ Import Strategy:                                                           │
  │   1. AXFR attempt            → ❌ Refused                                  │
  │   2. NSEC/NSEC3 walk         → ✅ Partial (13 names)                       │
  │   3. Common subdomain scan   → ✅ Running                                  │
  │   4. Wildcard detection      → ✅ Running                                  │
  │   5. Certificate transparency → ✅ Running                                 │
  │                                                                            │
  │ Progress:                                                                  │
  │ [████████████████████████████████████] 87%                                 │
  │                                                                            │
  │ Discovered via:                                                            │
  │   NSEC Walk:              13 names                                         │
  │   Common Subdomains:      8 names  (www, mail, ftp, etc.)                 │
  │   Certificate Trans:      24 names  (from crt.sh)                          │
  │   MX Lookups:             2 names   │
  │   NS Glue Records:        4 names                                          │
  │   SPF Includes:           3 names                                          │
  │   ─────────────────────────────────                                        │
  │   Total Unique:           42 names                                         │
  │                                                                            │
  │ Querying each name for all record types...                                 │
  │ [████████████████████████████████████] 42/42 names                         │
  │                                                                            │
  │ Final Record Count:                                                        │
  │   A:        58                                                             │
  │   AAAA:     34                                                             │
  │   CNAME:    21                                                             │
  │   MX:       6                                                              │
  │   TXT:      18                                                             │
  │   NS:       4                                                              │
  │   SOA:      1                                                              │
  │   SRV:      2                                                              │
  │   CAA:      1                                                              │
  │   ─────────────                                                            │
  │   Total:    145 records                                                    │
  │                                                                            │
  │ Confidence: HIGH (cross-verified via multiple sources)                     │
  │                                                                            │
  │ ⚠️  This is a best-effort reconstruction. May not be 100% complete         │
  │    compared to actual zone file. Review before using in production.        │
  │                                                                            │
  │ Zone saved to: example.com.zone                                            │
  │ Import completed in 8.4s                                                   │
  └────────────────────────────────────────────────────────────────────────────┘

# Import with TSIG authentication
onedns zone import example.com --method axfr --tsig-key transfer-key.conf
  Using TSIG key: hmac-sha256:transfer-key
  ✅ Zone transfer successful (authenticated)

# Import and export to different format
onedns zone import example.com --method axfr --format json --output example.json
onedns zone import example.com --method axfr --format terraform --output example.tf
```

#### Zone Export Examples

```bash
# Export existing zone file to JSON
onedns zone export example.com.zone --format json
  Output: example.com.json
  {
    "zone": "example.com",
    "ttl": 86400,
    "soa": {
      "mname": "ns1.example.com",
      "rname": "admin.example.com",
      "serial": 2024123001,
      "refresh": 86400,
      "retry": 7200,
      "expire": 3600000,
      "minimum": 172800
    },
    "records": [
      { "name": "@", "type": "NS", "ttl": 86400, "value": "ns1.example.com" },
      { "name": "@", "type": "NS", "ttl": 86400, "value": "ns2.example.com" },
      { "name": "@", "type": "A", "ttl": 300, "value": "203.0.113.1" },
      { "name": "www", "type": "A", "ttl": 300, "value": "203.0.113.1" },
      ...
    ]
  }

# Convert BIND zone to Terraform
onedns zone export example.com.zone --format terraform --output zones.tf
  Output: zones.tf
  # Terraform configuration for example.com
  # Generated by onedns zone export

  resource "aws_route53_zone" "example_com" {
    name = "example.com"
  }

  resource "aws_route53_record" "example_com_ns" {
    zone_id = aws_route53_zone.example_com.zone_id
    name    = "example.com"
    type    = "NS"
    ttl     = "86400"
    records = [
      "ns1.example.com",
      "ns2.example.com",
    ]
  }

  resource "aws_route53_record" "example_com_a" {
    zone_id = aws_route53_zone.example_com.zone_id
    name    = "example.com"
    type    = "A"
    ttl     = "300"
    records = ["203.0.113.1"]
  }
  ...

# Export with DNSSEC records stripped (for migration)
onedns zone export example.com.zone --format bind --no-dnssec --output example-nosec.zone
  ✅ Exported 247 records (DNSSEC records removed)

# Export sorted alphabetically
onedns zone export example.com.zone --format bind --sort --output example-sorted.zone
```

#### Advanced Import Features

```bash
# Incremental zone transfer (IXFR)
onedns zone import example.com --method ixfr --since-serial 2024123001
  Changes since serial 2024123001:
  + www.example.com    300  IN  A     203.0.113.10  (added)
  - www.example.com    300  IN  A     203.0.113.1   (removed)
  + api.example.com    300  IN  A     203.0.113.20  (added)

  3 changes applied
  New serial: 2024123002

# Compare live zone with local file
onedns zone import example.com --method axfr --compare example.com.zone
  Differences detected:

  Only in live zone:
    + shop.example.com        A      203.0.113.50
    + staging.example.com     CNAME  dev.example.com

  Only in local file:
    - old.example.com         A      203.0.113.99

  Different values:
    www.example.com
      Live:  203.0.113.10  (TTL: 300)
      Local: 203.0.113.1   (TTL: 300)

# Multi-format export
onedns zone import example.com --export-all
  Exported to:
    ✅ example.com.zone      (BIND format)
    ✅ example.com.json      (JSON format)
    ✅ example.com.yaml      (YAML format)
    ✅ example.com.csv       (CSV format)
    ✅ example.com.tf        (Terraform format)
```

#### Import Methods Comparison

| Method | Speed | Completeness | Requirements | Use Case |
|--------|-------|--------------|--------------|----------|
| **AXFR** | Fast | 100% | Zone transfer allowed | Best option when available |
| **IXFR** | Fastest | Incremental | Zone transfer allowed | Sync changes only |
| **NSEC Walk** | Medium | High | DNSSEC with NSEC | When AXFR blocked, DNSSEC zone |
| **NSEC3 Walk** | Slow | Partial | DNSSEC with NSEC3 | AXFR blocked, hashed NSEC |
| **Enumerate** | Slow | Variable | None | AXFR blocked, no DNSSEC |

**Smart Auto-Detection Logic:**
1. Try AXFR first (fastest, most complete)
2. If AXFR refused, check for DNSSEC:
   - NSEC → Use NSEC walking
   - NSEC3 → Use enumeration + partial NSEC3
3. If no DNSSEC → Use intelligent enumeration
4. Combine multiple techniques for best coverage

---

### 2.9 DNS Science Integration - `onedns science`

Full integration with dnsscience.io platform.

```bash
onedns science <subcommand> [flags]

Subcommands:
  key         Manage API key
  scan        Scan domain via dnsscience.io
  history     Get scan history
  compare     Compare current vs historical
  search      Search scanned domains
  analytics   Get analytics/statistics
  export      Export scan data

Flags:
  --api-key <key>     API key (or use 'onedns science key set')
  --format <fmt>      Output format: text, json, csv
```

#### Science Examples

```bash
# Configure API key
onedns science key set ./dnsscience-api-key.json
  Output:
  ✅ API key configured successfully
  Endpoint: https://api.dnsscience.io
  Organization: After Dark Systems
  Permissions: scan, read, analytics

# Comprehensive domain scan
onedns science scan google.com --level verbose
  Output:
  ┌─ DNS Science Comprehensive Scan: google.com ───────────────────────────────┐
  │                                                                            │
  │ Scan ID: scan_2024123001_google.com                                        │
  │ Timestamp: 2024-12-30T10:00:00Z                                            │
  │                                                                            │
  │ ╔══════════════════════════════════════════════════════════════════════╗   │
  │ ║                    SECURITY SCORE: 92/100 (Grade: A)                 ║   │
  │ ╚══════════════════════════════════════════════════════════════════════╝   │
  │                                                                            │
  │ ┌─ DNSSEC ─────────────────────────────────────────────────────────────┐   │
  │ │ Status: ✅ ENABLED & VALID                                           │   │
  │ │ Algorithm: ECDSAP256SHA256 (13)                                      │   │
  │ │ Key Tag: 41856                                                       │   │
  │ │ DS in parent: ✅ Present in .com zone                                │   │
  │ │ Chain validation: ✅ SECURE (root → com → google.com)                │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ SPF ────────────────────────────────────────────────────────────────┐   │
  │ │ Status: ✅ VALID                                                     │   │
  │ │ Record: v=spf1 include:_spf.google.com ~all                          │   │
  │ │ Policy: SoftFail (~all)                                              │   │
  │ │ DNS Lookups: 4/10                                                    │   │
  │ │ Recommendation: Consider -all for stricter policy                    │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ DKIM ───────────────────────────────────────────────────────────────┐   │
  │ │ Status: ✅ VALID                                                     │   │
  │ │ Selectors Found: google, 20230601                                    │   │
  │ │ Key Type: RSA 2048-bit                                               │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ DMARC ──────────────────────────────────────────────────────────────┐   │
  │ │ Status: ✅ ENABLED                                                   │   │
  │ │ Policy: reject                                                       │   │
  │ │ Subdomain Policy: reject                                             │   │
  │ │ Percentage: 100%                                                     │   │
  │ │ Alignment: DKIM=strict, SPF=strict                                   │   │
  │ │ Reporting: Aggregate ✅, Forensic ✅                                  │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ MTA-STS ────────────────────────────────────────────────────────────┐   │
  │ │ Status: ✅ ENABLED                                                   │   │
  │ │ Policy Mode: enforce                                                 │   │
  │ │ Max Age: 604800 (7 days)                                             │   │
  │ │ MX Hosts: *.smtp.google.com                                          │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ STARTTLS ───────────────────────────────────────────────────────────┐   │
  │ │ Port 25:  ✅ STARTTLS Available (TLS 1.3)                            │   │
  │ │ Port 587: ✅ STARTTLS Available (TLS 1.3)                            │   │
  │ │ Certificate: Valid, expires 2025-03-15                               │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ Advanced Features ──────────────────────────────────────────────────┐   │
  │ │ CAA Records: ✅ Present (pki.goog, letsencrypt.org)                  │   │
  │ │ BIMI: ✅ Enabled (logo configured)                                   │   │
  │ │ DANE/TLSA: ❌ Not configured                                         │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ Reputation ─────────────────────────────────────────────────────────┐   │
  │ │ Risk Score: 0 (LOW)                                                  │   │
  │ │ Blacklists: Clean (0/25 DNSBLs)                                      │   │
  │ │ Domain Age: 27 years (registered 1997-09-15)                         │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ Scan saved to dnsscience.io database                                       │
  │ View online: https://dnsscience.io/domain/google.com                       │
  └────────────────────────────────────────────────────────────────────────────┘

# Get historical scan data
onedns science history google.com --limit 10
  Output:
  ┌─ Scan History: google.com ─────────────────────────────────────────────────┐
  │                                                                            │
  │ Date                Score  DNSSEC  SPF  DKIM  DMARC  MTA-STS  Changes      │
  │ ────────────────────────────────────────────────────────────────────────   │
  │ 2024-12-30 10:00    92     ✅      ✅    ✅     ✅      ✅       -            │
  │ 2024-12-23 10:00    92     ✅      ✅    ✅     ✅      ✅       -            │
  │ 2024-12-16 10:00    92     ✅      ✅    ✅     ✅      ✅       -            │
  │ 2024-12-09 10:00    90     ✅      ✅    ✅     ✅      ❌       MTA-STS add  │
  │ 2024-12-02 10:00    90     ✅      ✅    ✅     ✅      ❌       -            │
  │ 2024-11-25 10:00    88     ✅      ⚠️    ✅     ✅      ❌       SPF fix      │
  │ 2024-11-18 10:00    88     ✅      ⚠️    ✅     ✅      ❌       -            │
  │ 2024-11-11 10:00    88     ✅      ⚠️    ✅     ✅      ❌       -            │
  │ 2024-11-04 10:00    85     ✅      ⚠️    ⚠️     ✅      ❌       DKIM add     │
  │ 2024-10-28 10:00    75     ❌      ⚠️    ⚠️     ✅      ❌       DNSSEC add   │
  │                                                                            │
  │ Drift Detection:                                                           │
  │   • MTA-STS enabled on 2024-12-09                                          │
  │   • SPF record corrected on 2024-11-25                                     │
  │   • New DKIM selector added on 2024-11-04                                  │
  │   • DNSSEC enabled on 2024-10-28                                           │
  └────────────────────────────────────────────────────────────────────────────┘

# Compare with historical baseline
onedns science compare google.com --baseline "2024-11-01"
  Output:
  ┌─ Security Drift Analysis: google.com ──────────────────────────────────────┐
  │                                                                            │
  │ Comparing: 2024-11-01 → 2024-12-30 (59 days)                               │
  │                                                                            │
  │ Security Score: 75 → 92 (+17 points) 📈                                    │
  │                                                                            │
  │ Changes Detected:                                                          │
  │                                                                            │
  │ ✅ DNSSEC Enabled                                                          │
  │    Before: Not configured                                                  │
  │    After:  ECDSAP256SHA256, Key Tag 41856                                  │
  │    Impact: +15 points, significant security improvement                    │
  │                                                                            │
  │ ✅ MTA-STS Enabled                                                         │
  │    Before: Not configured                                                  │
  │    After:  enforce mode, 7-day max-age                                     │
  │    Impact: +5 points, SMTP transport security                              │
  │                                                                            │
  │ ⚠️  SPF Record Changed                                                     │
  │    Before: v=spf1 include:_spf.google.com ?all                             │
  │    After:  v=spf1 include:_spf.google.com ~all                             │
  │    Impact: Neutral modifier strengthened                                   │
  │                                                                            │
  │ ✅ New DKIM Selector                                                       │
  │    Added: 20230601._domainkey.google.com                                   │
  │    Impact: Additional signing capability                                   │
  │                                                                            │
  │ Summary: Significant security posture improvement over 59 days             │
  └────────────────────────────────────────────────────────────────────────────┘

# Search domains by criteria
onedns science search --no-dnssec --has-dmarc --limit 100
  Output:
  Domains without DNSSEC but with DMARC (showing 100 of 12,453):

  Domain              Score  SPF  DKIM  DMARC Policy  Last Scan
  ──────────────────────────────────────────────────────────────
  example1.com        65     ✅    ✅     reject        2024-12-30
  example2.org        60     ✅    ⚠️     quarantine    2024-12-30
  example3.net        55     ⚠️    ✅     none          2024-12-29
  ...

# Analytics dashboard
onedns science analytics --period 30d
  Output:
  ┌─ DNS Science Analytics (Last 30 Days) ─────────────────────────────────────┐
  │                                                                            │
  │ Dataset: 1,234,567 domains scanned                                         │
  │                                                                            │
  │ ┌─ Email Security Adoption ────────────────────────────────────────────┐   │
  │ │                                                                      │   │
  │ │ Feature         Adoption    Change (30d)    Trend                    │   │
  │ │ ─────────────────────────────────────────────────────────────────    │   │
  │ │ SPF             89.3%       +0.8%           📈 Increasing            │   │
  │ │ DKIM            73.5%       +1.2%           📈 Increasing            │   │
  │ │ DMARC           67.2%       +2.1%           📈 Fast growth           │   │
  │ │ DMARC (reject)  34.1%       +3.5%           📈 Strong adoption       │   │
  │ │ MTA-STS         12.4%       +0.5%           📈 Slow growth           │   │
  │ │ BIMI            2.1%        +0.3%           📈 Early adoption        │   │
  │ │                                                                      │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ DNSSEC Adoption ────────────────────────────────────────────────────┐   │
  │ │                                                                      │   │
  │ │ Metric              Value       Change                               │   │
  │ │ ─────────────────────────────────────────────────────────────────    │   │
  │ │ DNSSEC Enabled      45.2%       +0.3%                                │   │
  │ │ DNSSEC Valid        42.1%       +0.4%                                │   │
  │ │ Algorithm 13 (EC)   67.8%       +2.1%  (of signed domains)           │   │
  │ │ Algorithm 8 (RSA)   31.2%       -1.8%  (of signed domains)           │   │
  │ │                                                                      │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  │                                                                            │
  │ ┌─ Security Score Distribution ────────────────────────────────────────┐   │
  │ │                                                                      │   │
  │ │ Grade A (90-100):  12.3%  ████████                                   │   │
  │ │ Grade B (80-89):   23.4%  ████████████████                           │   │
  │ │ Grade C (70-79):   28.7%  ████████████████████                       │   │
  │ │ Grade D (60-69):   18.9%  █████████████                              │   │
  │ │ Grade F (<60):     16.7%  ███████████                                │   │
  │ │                                                                      │   │
  │ └──────────────────────────────────────────────────────────────────────┘   │
  └────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Configuration

### 3.1 Configuration File Format

```json
{
  "version": "1.0",
  "defaults": {
    "output_level": "long",
    "color": true,
    "timeout": "10s",
    "retries": 3
  },
  "resolvers": {
    "default": ["8.8.8.8", "1.1.1.1"],
    "dnssec_validation": ["9.9.9.9"],
    "internal": ["192.168.1.53"]
  },
  "dnsscience": {
    "api_key_file": "~/.config/onedns/dnsscience-key.json",
    "endpoint": "https://api.dnsscience.io",
    "auto_submit": false
  },
  "appliances": {
    "infoblox": {
      "url": "https://infoblox.example.com",
      "username": "api-user",
      "password_file": "~/.config/onedns/infoblox-pass",
      "version": "2.11",
      "default_view": "default"
    },
    "bluecat": {
      "url": "https://bluecat.example.com",
      "api_key_file": "~/.config/onedns/bluecat-key"
    }
  },
  "dkim_selectors": [
    "default", "selector1", "selector2", "google", "mail", "dkim",
    "s1", "s2", "k1", "k2", "email", "smtp"
  ],
  "dnsbls": [
    "zen.spamhaus.org",
    "bl.spamcop.net",
    "b.barracudacentral.org"
  ],
  "output": {
    "timestamps": "RFC3339",
    "colors": {
      "success": "green",
      "warning": "yellow",
      "error": "red",
      "info": "cyan"
    }
  }
}
```

### 3.2 Environment Variables

```bash
# Core settings
ONEDNS_CONFIG=/path/to/config.json
ONEDNS_OUTPUT_LEVEL=verbose
ONEDNS_COLOR=true

# Resolver settings
ONEDNS_RESOLVER=8.8.8.8
ONEDNS_TIMEOUT=10s

# API keys
ONEDNS_DNSSCIENCE_KEY=<api-key>
ONEDNS_INFOBLOX_URL=https://infoblox.example.com
ONEDNS_INFOBLOX_USER=admin
ONEDNS_INFOBLOX_PASS=<password>
ONEDNS_BLUECAT_KEY=<api-key>
```

---

## 4. dnsscience.io API Integration

### 4.1 API Endpoints Used

Based on the dnsscience.io codebase, the following API endpoints will be integrated:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/scan` | POST | Submit domain for scanning |
| `/api/domain/<domain>` | GET | Get latest scan results |
| `/api/domain/<domain>/history` | GET | Get historical scans |
| `/api/compare/<domain>` | GET | Compare current vs previous |
| `/api/search` | GET | Search domains by criteria |
| `/api/domains` | GET | List all scanned domains |
| `/api/analytics/summary` | GET | Get adoption statistics |
| `/api/analytics/drift` | GET | Get drift detection data |
| `/api/analytics/vulnerable` | GET | Get high-risk domains |

### 4.2 Data Model Mapping

```go
// ScanResult maps to dnsscience.io scan_history table
type ScanResult struct {
    Domain           string    `json:"domain"`
    ScanTimestamp    time.Time `json:"scan_timestamp"`
    ScanStatus       string    `json:"scan_status"`

    // DNSSEC
    DNSSECEnabled    bool      `json:"dnssec_enabled"`
    DNSSECValid      bool      `json:"dnssec_valid"`
    DNSSECDetails    string    `json:"dnssec_details"`

    // SPF
    SPFRecord        string    `json:"spf_record"`
    SPFValid         bool      `json:"spf_valid"`
    SPFDetails       string    `json:"spf_details"`

    // DKIM
    DKIMSelectors    []string  `json:"dkim_selectors"`
    DKIMValid        bool      `json:"dkim_valid"`
    DKIMDetails      string    `json:"dkim_details"`

    // DMARC
    DMARCEnabled     bool      `json:"dmarc_enabled"`
    DMARCPolicy      string    `json:"dmarc_policy"`
    DMARCRecord      string    `json:"dmarc_record"`
    DMARCDetails     string    `json:"dmarc_details"`

    // MTA-STS
    MTASTSEnabled    bool      `json:"mta_sts_enabled"`
    MTASTSPolicy     string    `json:"mta_sts_policy"`
    MTASTSDetails    string    `json:"mta_sts_details"`

    // STARTTLS
    STARTTLS25       bool      `json:"smtp_starttls_25"`
    STARTTLS587      bool      `json:"smtp_starttls_587"`
    SMTPDetails      string    `json:"smtp_details"`

    // Advanced (from checkers.py enhancements)
    CAAEnabled       bool      `json:"caa_enabled"`
    CAARecords       []CAARecord `json:"caa_records"`
    BIMIEnabled      bool      `json:"bimi_enabled"`
    BIMILogoURL      string    `json:"bimi_logo_url"`
    TLSAEnabled      bool      `json:"tlsa_enabled"`
    TLSARecords      []TLSARecord `json:"tlsa_records"`

    // Security Score
    SecurityScore    int       `json:"security_score"`
    SecurityGrade    string    `json:"security_grade"`

    // SSL Certificates
    SSLCertificates  []Certificate `json:"ssl_certificates"`

    // Reputation (from reputation_checker.py)
    ReputationScore  int       `json:"reputation_score"`
    RiskLevel        string    `json:"risk_level"`
    BlacklistStatus  []string  `json:"blacklist_status"`
}
```

---

## 5. Output Level Specifications

### 5.1 Level Definitions

| Level | Description | Use Case | Verbosity |
|-------|-------------|----------|-----------|
| `short` | Answer only | Scripting, piping | Minimal |
| `long` | Answer with metadata | Default CLI use | Low |
| `detail` | Full DNS sections | Troubleshooting | Medium |
| `verbose` | Explanations + context | Learning/debugging | High |
| `debug` | Wire-level packets | Deep debugging | Maximum |
| `json` | Machine-readable | API integration | Variable |

### 5.2 Output Components by Level

```
Component                  short  long  detail  verbose  debug
──────────────────────────────────────────────────────────────
Answer value                 ✅     ✅     ✅      ✅       ✅
Record type/class            ❌     ✅     ✅      ✅       ✅
TTL                          ❌     ✅     ✅      ✅       ✅
Response header              ❌     ❌     ✅      ✅       ✅
Question section             ❌     ❌     ✅      ✅       ✅
Authority section            ❌     ❌     ✅      ✅       ✅
Additional section           ❌     ❌     ✅      ✅       ✅
Query timing                 ❌     ❌     ✅      ✅       ✅
Server information           ❌     ❌     ✅      ✅       ✅
Flag explanations            ❌     ❌     ❌      ✅       ✅
Record explanations          ❌     ❌     ❌      ✅       ✅
DNSSEC chain analysis        ❌     ❌     ❌      ✅       ✅
IP geolocation/ASN           ❌     ❌     ❌      ✅       ✅
RTT breakdown                ❌     ❌     ❌      ✅       ✅
Raw packet hex               ❌     ❌     ❌      ❌       ✅
Wire format parsing          ❌     ❌     ❌      ❌       ✅
Compression pointer analysis ❌     ❌     ❌      ❌       ✅
Byte-by-byte annotation      ❌     ❌     ❌      ❌       ✅
```

---

## 6. Implementation Phases

### Phase 1: Core DNS Engine (Foundation)
- Basic DNS resolution using `miekg/dns`
- All record type support
- DNSSEC validation
- Output formatting framework
- Configuration system

### Phase 2: Query & Debug Commands
- `onedns query` with all levels
- `onedns debug trace`
- `onedns debug compare`
- Resolver comparison
- Propagation checking

### Phase 3: Packet Forging & Keys
- `onedns mkpacket` all packet types
- `onedns makekey` DNSSEC key generation
- TSIG support
- DNS UPDATE construction

### Phase 4: Email Security Suite
- `onedns spf` full implementation
- `onedns dkim` with selector discovery
- `onedns dmarc` analysis
- `onedns txt` validation

### Phase 5: dnsscience.io Integration
- API client implementation
- `onedns science scan`
- `onedns science history`
- `onedns science compare`
- `onedns science analytics`

### Phase 6: Appliance Integration
- Infoblox WAPI client
- BlueCat API client
- `onedns appliance` commands
- Record synchronization

### Phase 7: Zone Validation
- `onedns validate zone`
- `onedns validate config`
- Platform-specific validators (BIND, PowerDNS, etc.)
- Auto-fix capabilities

### Phase 8: Polish & Advanced Features
- Global propagation checking
- AXFR/IXFR support
- DNS NOTIFY
- Performance optimization
- Comprehensive testing

---

## 7. Dependencies

### Go Libraries

```go
require (
    github.com/miekg/dns v1.1.58        // DNS library
    github.com/spf13/cobra v1.8.0       // CLI framework
    github.com/spf13/viper v1.18.2      // Configuration
    github.com/fatih/color v1.16.0      // Terminal colors
    github.com/olekukonko/tablewriter v0.0.5 // Tables
    golang.org/x/crypto v0.18.0         // Cryptography
    github.com/go-resty/resty/v2 v2.11.0 // HTTP client
)
```

---

## 8. Success Criteria

- [ ] All dig/drill functionality replicated
- [ ] 5 output verbosity levels working
- [ ] Full DNSSEC chain validation
- [ ] dnsscience.io API fully integrated
- [ ] Infoblox WAPI integration complete
- [ ] BlueCat API integration complete
- [ ] Zone validation for 6 platforms
- [ ] Sub-second query performance
- [ ] Comprehensive test coverage (>80%)
- [ ] Documentation complete

---

## 9. References

- dnsscience.io API: `/Users/ryan/development/dnsscience.io/`
- RFC 1035 - DNS Protocol
- RFC 4033-4035 - DNSSEC
- RFC 7208 - SPF
- RFC 6376 - DKIM
- RFC 7489 - DMARC
- RFC 8461 - MTA-STS

---

**Ticket Created:** 2024-12-30
**Last Updated:** 2024-12-30
**Status:** Design Complete - Ready for Implementation
