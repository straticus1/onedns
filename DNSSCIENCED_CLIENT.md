# adsdnsgo - Official DNS Client for DNSScienced

## Overview

`adsdnsgo` (branded as `dnsgo`) is the official command-line DNS client for the DNSScienced DNS server platform. It provides advanced querying, debugging, and management capabilities specifically designed to work seamlessly with DNSScienced servers.

---

## Relationship to DNSScienced

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DNSSCIENCED ECOSYSTEM                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        SERVER COMPONENTS                             │   │
│  │                                                                      │   │
│  │  ┌──────────────────┐    ┌──────────────────┐    ┌──────────────┐  │   │
│  │  │ dnsscience-authd │    │ dnsscience-cached│    │ dnssciencectl│  │   │
│  │  │ (Authoritative)  │    │ (Recursive)      │    │ (Management) │  │   │
│  │  └──────────────────┘    └──────────────────┘    └──────────────┘  │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                      │                                      │
│                                      │ DNS Protocol                         │
│                                      │ + Management API                     │
│                                      │                                      │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        CLIENT COMPONENT                              │   │
│  │                                                                      │   │
│  │  ┌─────────────────────────────────────────────────────────────┐   │   │
│  │  │                      dnsgo (adsdnsgo)                        │   │   │
│  │  │                                                              │   │   │
│  │  │  • DNS Query Engine            • DNSSEC Debugging           │   │   │
│  │  │  • Zone Validation             • Email Security Suite       │   │   │
│  │  │  • DNSScienced Management      • dnsscience.io Integration  │   │   │
│  │  │  • Wire Protocol Analysis      • DDI Appliance Support      │   │   │
│  │  │                                                              │   │   │
│  │  └─────────────────────────────────────────────────────────────┘   │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                        CLOUD PLATFORM                                │   │
│  │                                                                      │   │
│  │  ┌────────────────────┐    ┌────────────────────┐                   │   │
│  │  │   dnsscience.io    │    │  licensing.        │                   │   │
│  │  │   (Analytics)      │    │  afterdarksys.com  │                   │   │
│  │  └────────────────────┘    └────────────────────┘                   │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## DNSScienced-Specific Features

### Server Management Commands

```bash
# Connect to DNSScienced server
dnsgo server connect <host> [--port 8443] [--api-key KEY]

# Server status
dnsgo server status
dnsgo server stats [--period 5m|1h|24h]
dnsgo server health

# Zone management
dnsgo server zones list
dnsgo server zones show <zone>
dnsgo server zones reload <zone>
dnsgo server zones notify <zone>

# Cache management
dnsgo server cache stats
dnsgo server cache lookup <domain> [type]
dnsgo server cache flush [domain]

# DNSSEC management
dnsgo server dnssec status <zone>
dnsgo server dnssec ds <zone>
dnsgo server dnssec rollover <zone> [ksk|zsk]

# Configuration
dnsgo server config show [section]
dnsgo server config reload

# License information
dnsgo server license info
dnsgo server license features
```

### Configuration File

```json
{
  "defaults": {
    "output_level": "long",
    "color": true,
    "timeout": "10s"
  },
  "resolvers": {
    "default": ["8.8.8.8", "1.1.1.1"],
    "internal": ["10.0.0.1", "10.0.0.2"]
  },
  "dnsscienced": {
    "servers": {
      "primary": {
        "host": "dns-auth1.example.com",
        "port": 8443,
        "api_key_file": "~/.config/adsdnsgo/dnsscienced-api-key.json",
        "tls": {
          "verify": true,
          "ca_cert": "~/.config/adsdnsgo/ca.crt"
        }
      },
      "secondary": {
        "host": "dns-auth2.example.com",
        "port": 8443,
        "api_key_file": "~/.config/adsdnsgo/dnsscienced-api-key.json"
      }
    },
    "default_server": "primary"
  },
  "dnsscience": {
    "api_key_file": "~/.config/adsdnsgo/dnsscience-key.json",
    "embedded_dns": {
      "enabled": false,
      "servers": [
        "cache01.dnsscience.io",
        "cache02.dnsscience.io",
        "cache03.dnsscience.io",
        "cache04.dnsscience.io"
      ]
    }
  },
  "appliances": {
    "infoblox": {
      "url": "https://infoblox.example.com/wapi/v2.12",
      "credentials_file": "~/.config/adsdnsgo/infoblox.json"
    },
    "bluecat": {
      "url": "https://bluecat.example.com/api/v2",
      "credentials_file": "~/.config/adsdnsgo/bluecat.json"
    }
  }
}
```

---

## Extended Command Set

### Full Command Reference

```
dnsgo - After Dark Systems DNS GO! (Official DNSScienced Client)

QUERY COMMANDS
  dnsgo query <target> [type] [options]
    Query DNS records with configurable verbosity
    Types: A, AAAA, CNAME, MX, TXT, NS, SOA, PTR, SRV, DNSKEY, DS, RRSIG, NSEC, NSEC3, CAA, HTTPS, SVCB, ANY
    Options:
      --level, -l        Output level: short|long|detail|verbose|debug
      --server, -s       DNS server to query
      --tcp              Force TCP
      --edns             Enable EDNS(0)
      --dnssec, -D       Request DNSSEC records
      --cd               Set Checking Disabled flag
      --embedded-dns     Use dnsscience.io DNS caches

DEBUG COMMANDS
  dnsgo debug trace <target>
    Trace resolution from root servers

  dnsgo debug compare <target> --resolvers <list>
    Compare results across multiple resolvers

  dnsgo debug propagation <target> --resolvers <list>
    Check propagation status across nameservers

  dnsgo debug delegation <target>
    Analyze delegation chain

  dnsgo debug latency <target> [--server <server>] [--count <n>]
    Measure query latency

  dnsgo debug glue <zone>
    Check glue record consistency

  dnsgo debug authority <zone>
    Verify authoritative server configuration

PACKET COMMANDS
  dnsgo mkpacket query <name> <type> [options]
    Create DNS query packet

  dnsgo mkpacket response <query-file> [options]
    Create DNS response packet

  dnsgo mkpacket update <zone> [options]
    Create DNS UPDATE packet (RFC 2136)

  dnsgo mkpacket notify <zone> [options]
    Create DNS NOTIFY packet

  dnsgo parsepacket <file|hex>
    Parse and display DNS packet

DNSSEC COMMANDS
  dnsgo makekey [options]
    Generate DNSSEC key pair
    Options:
      --algorithm        ECDSAP256SHA256 (default), ED25519, RSASHA256, etc.
      --type             ksk|zsk
      --zone             Zone name

  dnsgo dnssec validate <domain>
    Validate DNSSEC chain of trust

  dnsgo dnssec chain <domain>
    Display full DNSSEC chain

  dnsgo dnssec ds <zone> --key <keyfile>
    Generate DS record from DNSKEY

EMAIL SECURITY COMMANDS
  dnsgo spf <subcommand> <domain> [options]
    SPF record tools
    Subcommands:
      get       - Retrieve and parse SPF record
      validate  - Check SPF syntax and semantics
      test      - Test IP against SPF policy
      make      - Generate SPF record interactively
      flatten   - Flatten SPF includes to IPs

  dnsgo dkim <subcommand> <domain> [options]
    DKIM tools
    Subcommands:
      get       - Retrieve DKIM public key
      discover  - Find DKIM selectors
      verify    - Verify DKIM signature
      makekey   - Generate DKIM keypair

  dnsgo dmarc <subcommand> <domain> [options]
    DMARC tools
    Subcommands:
      get       - Retrieve and parse DMARC policy
      validate  - Check DMARC syntax
      make      - Generate DMARC record interactively

  dnsgo txt <host> <subcommand>
    TXT record tools
    Subcommands:
      get       - Retrieve TXT records
      validate  - Validate TXT record format

VALIDATION COMMANDS
  dnsgo validate zone <path> [options]
    Validate zone file
    Options:
      --platform         bind|powerdns|nsd|djbdns|dnsscienced
      --check-ns         Verify NS record reachability
      --check-dnssec     Verify DNSSEC configuration

  dnsgo validate config <path> [options]
    Validate DNS server configuration
    Options:
      --platform         bind|powerdns|unbound|nsd|dnsscienced

  dnsgo convert zone <input> <output> [options]
    Convert zone file format
    Options:
      --from             Source format
      --to               Target format (dnszone for DNSScienced)

DDI APPLIANCE COMMANDS
  dnsgo appliance set <type> <options>
    Configure DDI appliance connection
    Types: infoblox, bluecat

  dnsgo appliance get <type> <resource>
    Retrieve data from DDI appliance

  dnsgo appliance test <type>
    Test DDI appliance connectivity

  dnsgo appliance query <type> <query>
    Query DDI appliance

DNSSCIENCED SERVER COMMANDS
  dnsgo server connect <host> [options]
    Connect to DNSScienced management API

  dnsgo server status
    Show server status and health

  dnsgo server stats [--period <period>]
    Show server statistics

  dnsgo server zones <subcommand>
    Zone management commands

  dnsgo server cache <subcommand>
    Cache management commands

  dnsgo server dnssec <subcommand>
    DNSSEC management commands

  dnsgo server config <subcommand>
    Configuration commands

  dnsgo server license <subcommand>
    License information commands

DNSSCIENCE.IO COMMANDS
  dnsgo science key set <json-file>
    Set dnsscience.io API key

  dnsgo science scan <domain> [options]
    Run comprehensive DNS scan

  dnsgo science history <domain> [options]
    View historical scan data

  dnsgo science compare <domain1> <domain2>
    Compare DNS configurations

  dnsgo science search <query>
    Search dnsscience.io database

  dnsgo science analytics [options]
    View DNS analytics

  dnsgo science drift <domain> [--period <days>]
    Detect DNS configuration drift

GLOBAL FLAGS
  --config, -c         Config file path
  --output, -o         Output format: text|json|yaml
  --no-color           Disable color output
  --quiet, -q          Suppress non-essential output
  --verbose, -v        Increase verbosity
  --version            Show version
  --help, -h           Show help
```

---

## DNSScienced Integration Examples

### Managing DNSScienced Server

```bash
# Connect to server
$ dnsgo server connect dns-auth1.example.com --api-key ~/.config/adsdnsgo/api-key.json
Connected to dns-auth1.example.com (DNSScienced v1.2.3)
License: Enterprise (expires: 2025-01-01)
Features: 45 enabled

# Check server status
$ dnsgo server status
Server: dns-auth1.example.com
Status: healthy
Uptime: 15d 4h 32m
Queries/sec: 45,231
Cache hit rate: 92.4%
Zones loaded: 150

# View zone details
$ dnsgo server zones show example.com
Zone: example.com
Type: primary
Serial: 2024011503
Records: 152
DNSSEC: enabled (ECDSAP256SHA256)
Last modified: 2024-01-15T10:30:00Z

# Reload zone
$ dnsgo server zones reload example.com
Zone example.com reloaded
Old serial: 2024011503
New serial: 2024011504
Records: 155

# DNSSEC key rollover
$ dnsgo server dnssec rollover example.com zsk
Initiating ZSK rollover for example.com
New key ID: 67892
Timeline:
  Publish: 2024-01-15 (now)
  Activate: 2024-01-22
  Retire old: 2024-01-22
  Delete old: 2024-01-29
```

### Advanced Query Examples

```bash
# Query with full DNSSEC validation trace
$ dnsgo query example.com A --level verbose --dnssec
Query: example.com. IN A
Server: 8.8.8.8:53 (UDP)

;; ANSWER SECTION:
example.com.    300    IN    A    93.184.216.34

;; DNSSEC Validation:
✓ RRSIG valid (algorithm: ECDSAP256SHA256, key: 31406)
✓ DNSKEY verified by DS in parent zone
✓ Chain of trust verified to root

Response time: 12.3ms

# Compare across resolvers
$ dnsgo debug compare example.com A --resolvers 8.8.8.8,1.1.1.1,9.9.9.9
┌─────────────┬──────────────────┬─────────┬────────┐
│ Resolver    │ Answer           │ TTL     │ Time   │
├─────────────┼──────────────────┼─────────┼────────┤
│ 8.8.8.8     │ 93.184.216.34    │ 300     │ 12ms   │
│ 1.1.1.1     │ 93.184.216.34    │ 300     │ 8ms    │
│ 9.9.9.9     │ 93.184.216.34    │ 300     │ 15ms   │
└─────────────┴──────────────────┴─────────┴────────┘
All resolvers agree ✓

# Use DNSScienced embedded DNS
$ dnsgo query suspicious-domain.xyz A --embedded-dns --level verbose
Query via: cache01.dnsscience.io (dnsscience.io embedded DNS)

;; ANSWER SECTION:
suspicious-domain.xyz.    60    IN    A    192.0.2.1

;; DNSScience Analysis:
⚠ Domain registered: 2 days ago
⚠ Hosting: Known bulletproof provider
⚠ DGA Score: 0.87 (likely DGA-generated)
Threat Level: HIGH
```

### Zone Validation and Conversion

```bash
# Validate BIND zone file
$ dnsgo validate zone /etc/bind/zones/example.com.zone --platform bind
Validating: /etc/bind/zones/example.com.zone
Platform: BIND

Results:
  ✓ Syntax valid
  ✓ SOA record present and valid
  ✓ NS records point to valid nameservers
  ✓ No dangling CNAMEs
  ⚠ Warning: MX record TTL (86400) differs from A record TTL (300)
  ✓ DNSSEC records consistent

Zone is valid with 1 warning

# Convert BIND zone to DNSScienced format
$ dnsgo convert zone example.com.zone example.com.dnszone --from bind --to dnsscienced
Converting zone file...
Input: BIND format (example.com.zone)
Output: DNSScienced native format (example.com.dnszone)

Converted 152 records
Output written to: example.com.dnszone
```

### Email Security Analysis

```bash
# Full email security audit
$ dnsgo spf get google.com --level verbose
SPF Record for google.com:
v=spf1 include:_spf.google.com ~all

Expanded mechanisms:
  include:_spf.google.com
    ├── include:_netblocks.google.com (35,651,584 IPs)
    ├── include:_netblocks2.google.com (4,096 IPs)
    └── include:_netblocks3.google.com (1,048,576 IPs)

Analysis:
  ✓ Valid SPF syntax
  ✓ Lookup count: 4 (limit: 10)
  ✓ Uses softfail (~all) - recommended
  ⚠ Large IP range (36+ million IPs)

$ dnsgo dmarc get google.com
DMARC Policy for google.com:
v=DMARC1; p=reject; rua=mailto:mailauth-reports@google.com

Policy: reject (strict)
Subdomain policy: inherit
Reporting: enabled
```

---

## Installation as DNSScienced Client

### Install with DNSScienced

```bash
# Clone DNSScienced with client submodule
git clone --recursive https://github.com/dnsscience/dnsscienced.git
cd dnsscienced

# Build server and client together
make all

# Or build just the client
make client

# Install
sudo make install
# Installs: dnsscience-authd, dnsscience-cached, dnssciencectl, dnsgo
```

### Standalone Installation

```bash
# Go install
go install github.com/afterdarksystems/adsdnsgo/cmd/dnsgo@latest

# Or build from source
git clone https://github.com/afterdarksystems/adsdnsgo.git
cd adsdnsgo
go build -o dnsgo ./cmd/dnsgo
sudo mv dnsgo /usr/local/bin/
```

---

## Version Compatibility

| dnsgo Version | DNSScienced Version | Features |
|---------------|---------------------|----------|
| 1.0.x         | 1.0.x               | Basic server management |
| 1.1.x         | 1.1.x               | DNSSEC key management |
| 1.2.x         | 1.2.x - 1.3.x       | Web3 DNS support |
| 2.0.x         | 2.0.x               | DIP integration, AI features |

---

## Contributing

See the main [DNSScienced repository](https://github.com/dnsscience/dnsscienced) for contribution guidelines.

adsdnsgo is developed as part of the DNSScienced ecosystem by After Dark Systems.

---

*Part of the DNS Science ecosystem*
*"DNS Data, Management, Analytics, and Security experts."*
