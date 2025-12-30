#!/usr/bin/env python3
"""
Generate API key for adsdnsgo / dnsscience integration

This script generates an API key compatible with the dnsscience.io format.
For local/standalone deployments where the full dnsscience backend isn't running.
"""
import secrets
import hashlib
import json
import uuid
from datetime import datetime
import os

def generate_api_key():
    """Generate a new API key in dnsscience format"""
    # Format: dns_live_<32 random hex chars>
    key = f"dns_live_{secrets.token_hex(32)}"
    return key

def hash_key(api_key):
    """Hash an API key for storage"""
    return hashlib.sha256(api_key.encode('utf-8')).hexdigest()

def get_prefix(api_key):
    """Get the display prefix of an API key"""
    return api_key[:16] + "..."

def main():
    # Generate key
    api_key = generate_api_key()
    api_key_id = str(uuid.uuid4())
    key_hash = hash_key(api_key)
    key_prefix = get_prefix(api_key)

    # Get endpoint from environment or use default
    endpoint = os.environ.get('ADSDNSGO_ENDPOINT', 'http://localhost:5000')

    # Create credentials object
    credentials = {
        "version": "1.0",
        "service": "adsdnsgo",
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "api_key_id": api_key_id,
        "api_key": api_key,
        "api_key_prefix": key_prefix,
        "api_key_hash": key_hash,
        "endpoint": endpoint,
        "capabilities": [
            "dns_query",
            "dns_debug",
            "dnssec_validation",
            "spf_check",
            "dkim_check",
            "dmarc_check",
            "zone_validation"
        ]
    }

    # Output
    print("=" * 60)
    print("   adsdnsgo API Key Generated")
    print("=" * 60)
    print()
    print(f"API Key ID:     {api_key_id}")
    print(f"API Key:        {api_key}")
    print(f"Key Prefix:     {key_prefix}")
    print(f"Key Hash:       {key_hash[:32]}...")
    print(f"Endpoint:       {endpoint}")
    print()
    print("-" * 60)
    print("IMPORTANT: Save the API key now - it cannot be recovered!")
    print("-" * 60)
    print()

    # Save to file
    output_file = os.environ.get('OUTPUT_FILE', 'api-key.json')
    with open(output_file, 'w') as f:
        json.dump(credentials, f, indent=2)
    print(f"Credentials saved to: {output_file}")
    print()

    # Generate environment export commands
    print("Environment variables for shell:")
    print(f"  export ADSDNSGO_API_KEY='{api_key}'")
    print(f"  export ADSDNSGO_API_KEY_ID='{api_key_id}'")
    print(f"  export ADSDNSGO_ENDPOINT='{endpoint}'")
    print()

    # Generate .env format
    env_file = output_file.replace('.json', '.env')
    with open(env_file, 'w') as f:
        f.write(f"# adsdnsgo API credentials\n")
        f.write(f"# Generated: {datetime.utcnow().isoformat()}Z\n")
        f.write(f"ADSDNSGO_API_KEY={api_key}\n")
        f.write(f"ADSDNSGO_API_KEY_ID={api_key_id}\n")
        f.write(f"ADSDNSGO_ENDPOINT={endpoint}\n")
        f.write(f"\n# For AEIMS integration\n")
        f.write(f"DNSSCIENCE_API_KEY={api_key}\n")
        f.write(f"DNSSCIENCE_API_KEY_ID={api_key_id}\n")
        f.write(f"DNSSCIENCE_ENDPOINT={endpoint}\n")
    print(f"Environment file saved to: {env_file}")
    print()

    return credentials

if __name__ == '__main__':
    main()
