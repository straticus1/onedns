# adsdnsgo - After Dark Systems DNS GO!

**The Official CLI Client for DNSScienced**

The world's most advanced, verbose, and integrated DNS debugging tool.

## Overview

`adsdnsgo` (command: `dnsgo`) is a next-generation DNS CLI that combines the power of `dig` and `drill` with:
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
- **Zone Validation & Conversion** - Support for BIND, PowerDNS, Unbound, NSD, djbdns, DNSScienced native format
- **DNS Appliance Integration** - Infoblox WAPI, BlueCat API support
- **dnsscience.io Integration** - Full API access for internet-scale research

## Commands

```
# DNS Queries
dnsgo query <target> [type] [--level short|long|detail|verbose|debug] [--embedded-dns|-ed]
dnsgo debug <trace|compare|propagation|delegation|latency>

# DNSScienced Server Management
dnsgo server connect <host> [--api-key KEY]
dnsgo server status|stats|health
dnsgo server zones <list|show|reload|notify> [zone]
dnsgo server cache <stats|flush|lookup> [domain]
dnsgo server dnssec <status|ds|rollover> <zone>
dnsgo server license <info|features>

# DNSSEC & Packet Tools
dnsgo mkpacket <query|response|update|notify>
dnsgo makekey [--algorithm ECDSAP256SHA256|ED25519|...]

# Email Security
dnsgo spf <get|validate|test|make|flatten> <domain>
dnsgo dkim <get|discover|verify|makekey> <domain>
dnsgo dmarc <get|validate|make> <domain>
dnsgo txt <host> <get|validate>

# Zone Validation & Conversion
dnsgo validate <zone|config> <path> [--platform bind|powerdns|unbound|nsd|dnsscienced]
dnsgo convert zone <input> <output> [--from bind|djbdns] [--to dnsscienced]

# DDI Appliances
dnsgo appliance <set|get|test|query> <infoblox|bluecat>

# dnsscience.io Integration
dnsgo science <scan|history|compare|search|analytics|drift> [options]
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
dnsgo query example.com

# Full debug output
dnsgo query example.com mx --level debug

# Trace resolution from root
dnsgo debug trace example.com

# Compare resolvers
dnsgo debug compare example.com --resolvers 8.8.8.8,1.1.1.1,9.9.9.9

# Use dnsscience.io embedded DNS caches
dnsgo query example.com mx --embedded-dns

# Analyze SPF record
dnsgo spf get google.com --level verbose

# Scan via dnsscience.io
dnsgo science scan example.com

# Validate zone file
dnsgo validate zone /etc/bind/zones/example.com.zone --platform bind
```

## Installation

See [INSTALL.md](INSTALL.md) for detailed installation instructions.

### Quick Install (Go)

```bash
go install github.com/afterdarksystems/adsdnsgo@latest
```

### Build from Source

```bash
git clone https://github.com/afterdarksystems/adsdnsgo.git
cd adsdnsgo
go build -o dnsgo ./cmd/adsdnsgo
```

## Configuration

Create `~/.config/adsdnsgo/config.json`:

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
    "api_key_file": "~/.config/adsdnsgo/dnsscience-key.json"
  }
}
```

## DNSScienced Server Integration

Manage DNSScienced servers directly from the command line:

```bash
# Connect to your DNSScienced server
dnsgo server connect dns.example.com --api-key ~/.config/adsdnsgo/api-key.json

# Check server status
dnsgo server status
# Output: Server: dns.example.com | Status: healthy | QPS: 45,231 | Cache hit: 92%

# Manage zones
dnsgo server zones list
dnsgo server zones reload example.com

# DNSSEC key rollover
dnsgo server dnssec rollover example.com zsk

# View license info
dnsgo server license info
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
dnsgo science key set ./api-key.json

# Run comprehensive scan
dnsgo science scan example.com --level verbose

# View historical data
dnsgo science history example.com --limit 30

# Get analytics
dnsgo science analytics --period 30d
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
- [TICKET-001-ADSDNSGO-DESIGN.md](TICKET-001-ADSDNSGO-DESIGN.md) - Full technical design

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome. Please read the design document before submitting PRs.

## Acknowledgments

Thanks, Claude for debugging weird Go DNS API issues for DNSSEC.
