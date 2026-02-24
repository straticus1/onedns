# onedns - One DNS Tool for Everything

**The Ultimate DNS CLI - Query, Debug, Secure, Manage**

One DNS tool to rule them all. The world's most advanced, verbose, and integrated DNS debugging tool.

## Overview

`onedns` is a next-generation DNS CLI that combines the power of `dig` and `drill` with:
- **DNSScienced Integration** - Full server management and control
- **dnsscience.io Platform** - Internet-scale DNS security research
- **Email Security Suite** - SPF, DKIM, DMARC analysis

Part of the [DNSScienced](https://github.com/dnsscience/dnsscienced) ecosystem.

> *"DNS Science: DNS Data, Management, Analytics, and Security experts."*

## Features

- **DNSScienced Server Management** - Full control of DNSScienced servers via REST API
- **Ultra-fast DNS Query Engine** - Optimized Go implementation
- **5 Verbosity Levels** - From one-line answers to wire-level packet dumps
- **Full DNSSEC Support** - Validation, chain tracing, key generation, rollover management
- **Email Security Suite** - SPF, DKIM, DMARC analysis and generation
- **Zone Import/Export** - AXFR, IXFR, NSEC walking, intelligent enumeration (Cloudflare-style)
- **Zone Validation** - Support for BIND, PowerDNS, Unbound, NSD, djbdns, DNSScienced native format
- **DNS Appliance Integration** - Infoblox WAPI, BlueCat API support
- **dnsscience.io Integration** - Full API access for internet-scale research

## Commands

```
# DNS Queries
onedns query <target> [type] [--level short|long|detail|verbose|debug] [--embedded-dns|-ed]
onedns debug <trace|compare|propagation|delegation|latency>

# DNSScienced Server Management
onedns server connect <host> [--api-key KEY]
onedns server status|stats|health
onedns server zones <list|show|reload|notify> [zone]
onedns server cache <stats|flush|lookup> [domain]
onedns server dnssec <status|ds|rollover> <zone>
onedns server license <info|features>

# DNSSEC & Packet Tools
onedns mkpacket <query|response|update|notify>
onedns makekey [--algorithm ECDSAP256SHA256|ED25519|...]

# Email Security
onedns spf <get|validate|test|make|flatten> <domain>
onedns dkim <get|discover|verify|makekey> <domain>
onedns dmarc <get|validate|make> <domain>
onedns txt <host> <get|validate>

# Zone Import/Export
onedns zone import <domain> [--method axfr|ixfr|walk|enumerate]
onedns zone export <domain> [--format bind|json|yaml|csv|terraform]

# Zone Validation
onedns validate <zone|config> <path> [--platform bind|powerdns|unbound|nsd|dnsscienced]

# DDI Appliances
onedns appliance <set|get|test|query> <infoblox|bluecat>

# dnsscience.io Integration
onedns science <scan|history|compare|search|analytics|drift> [options]
```

## Output Levels

| Level | Description |
|-------|-------------|
| `short` | Answer only (for scripting) |
| `long` | Answer with TTL and type (default) |
| `detail` | Full DNS response sections |
| `verbose` | Explanations, timing, DNSSEC analysis |
| `debug` | Wire-level packet dumps with hex |

## Global Flags

| Flag | Description |
|------|-------------|
| `--embedded-dns`, `-ed` | Use dnsscience.io DNS caches (cache01-04.dnsscience.io) instead of system resolvers |

## Quick Examples

```bash
# Basic query
onedns query example.com

# Full debug output
onedns query example.com mx --level debug

# Trace resolution from root
onedns debug trace example.com

# Compare resolvers
onedns debug compare example.com --resolvers 8.8.8.8,1.1.1.1,9.9.9.9

# Use dnsscience.io embedded DNS caches
onedns query example.com mx --embedded-dns

# Analyze SPF record
onedns spf get google.com --level verbose

# Scan via dnsscience.io
onedns science scan example.com

# Import zone via AXFR transfer
onedns zone import example.com --method axfr

# Import zone via NSEC walking (when AXFR blocked)
onedns zone import example.com --method walk

# Import with intelligent enumeration (Cloudflare-style)
onedns zone import example.com --method enumerate

# Export zone to different formats
onedns zone export example.com.zone --format terraform

# Validate zone file
onedns validate zone /etc/bind/zones/example.com.zone --platform bind
```

## Installation

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

### Quick Install (Go)

```bash
go install github.com/onedns/onedns@latest
```

### Build from Source

```bash
git clone https://github.com/onedns/onedns.git
cd onedns
go build -o onedns ./cmd/onedns
```

## Configuration

Create `~/.config/onedns/config.json`:

```json
{
  "defaults": {
    "output_level": "long",
    "color": true,
    "timeout": "10s"
  },
  "resolvers": {
    "default": ["8.8.8.8", "1.1.1.1"]
  },
  "dnsscience": {
    "api_key_file": "~/.config/onedns/dnsscience-key.json"
  }
}
```

## DNSScienced Server Integration

Manage DNSScienced servers directly from the command line:

```bash
# Connect to your DNSScienced server
onedns server connect dns.example.com --api-key ~/.config/onedns/api-key.json

# Check server status
onedns server status
# Output: Server: dns.example.com | Status: healthy | QPS: 45,231 | Cache hit: 92%

# Manage zones
onedns server zones list
onedns server zones reload example.com

# DNSSEC key rollover
onedns server dnssec rollover example.com zsk

# View license info
onedns server license info
```

See [DNSSCIENCED_CLIENT.md](DNSSCIENCED_CLIENT.md) for full DNSScienced integration documentation.

---

## dnsscience.io Integration

Connect to the dnsscience.io platform for:
- Internet-scale DNS security research
- Historical scan data and drift detection
- Email security adoption analytics
- Domain reputation checking

```bash
# Set API key
onedns science key set ./api-key.json

# Run comprehensive scan
onedns science scan example.com --level verbose

# View historical data
onedns science history example.com --limit 30

# Get analytics
onedns science analytics --period 30d
```

## Supported Platforms

**DNS Servers:**
- BIND
- PowerDNS
- Unbound
- NSD
- djbdns

**DDI Appliances:**
- Infoblox NIOS (WAPI)
- BlueCat Address Manager

## Documentation

- [INSTALL.md](INSTALL.md) - Installation guide
- [DNSSCIENCED_CLIENT.md](DNSSCIENCED_CLIENT.md) - DNSScienced server integration guide
- [TICKET-001-ONEDNS-DESIGN.md](TICKET-001-ONEDNS-DESIGN.md) - Full technical design

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome. Please read the design document before submitting PRs.

## Acknowledgments

Thanks, Claude for debugging weird Go DNS API issues for DNSSEC.
