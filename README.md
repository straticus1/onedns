# adsdnsgo - After Dark Systems DNS GO!

The world's most advanced, verbose, and integrated DNS debugging tool.

## Overview

`adsdnsgo` is a next-generation DNS CLI that combines the power of `dig` and `drill` with deep integration into the [dnsscience.io](https://dnsscience.io) platform for internet-scale DNS security research.

## Features

- **Ultra-fast DNS Query Engine** - Optimized Go implementation
- **5 Verbosity Levels** - From one-line answers to wire-level packet dumps
- **Full DNSSEC Support** - Validation, chain tracing, key generation
- **Email Security Suite** - SPF, DKIM, DMARC analysis and generation
- **DNS Appliance Integration** - Infoblox WAPI, BlueCat API support
- **Zone Validation** - Support for BIND, PowerDNS, Unbound, NSD, djbdns
- **dnsscience.io Integration** - Full API access for internet-scale research

## Commands

```
dnsgo query <target> [type] [--level short|long|detail|verbose|debug] [--embedded-dns|-ed]
dnsgo debug <trace|compare|propagation|delegation|latency>
dnsgo mkpacket <query|response|update|notify>
dnsgo makekey [--algorithm ECDSAP256SHA256|ED25519|...]
dnsgo spf <get|validate|test|make|flatten> <domain>
dnsgo dkim <get|discover|verify|makekey> <domain>
dnsgo dmarc <get|validate|make> <domain>
dnsgo txt <host> <get|validate>
dnsgo appliance <set|get|test|query> <infoblox|bluecat>
dnsgo validate <zone|config> <path> [--platform bind|powerdns|unbound|nsd]
dnsgo science <scan|history|compare|search|analytics> [options]
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
- [TICKET-001-ADSDNSGO-DESIGN.md](TICKET-001-ADSDNSGO-DESIGN.md) - Full technical design

## License

MIT License - see [LICENSE](LICENSE)

## Contributing

Contributions welcome. Please read the design document before submitting PRs.

## Acknowledgments

Thanks, Claude for debugging weird Go DNS API issues for DNSSEC.
