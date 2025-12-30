#!/usr/bin/env python3
"""
Register API key in dnsscience.io database

This script inserts the generated API key hash into the production database
so it can be used for authentication.
"""
import psycopg2
import os
import json
import sys

# Database connection from dnsscience.io production
DATABASE_URL = os.environ.get(
    'DATABASE_URL',
    'postgresql://dnsscience:dnsscience_secure_2024@129.153.158.177:5432/dnsscience'
)

def register_api_key(key_hash, key_prefix, name, tier='enterprise'):
    """Register an API key in the database"""
    conn = psycopg2.connect(DATABASE_URL)
    try:
        with conn.cursor() as cursor:
            # Check if key already exists
            cursor.execute(
                "SELECT id FROM api_keys WHERE key_hash = %s",
                (key_hash,)
            )
            existing = cursor.fetchone()

            if existing:
                print(f"API key already registered with ID: {existing[0]}")
                return existing[0]

            # Insert the new key
            cursor.execute("""
                INSERT INTO api_keys (
                    key_hash,
                    key_prefix,
                    name,
                    tier,
                    is_active,
                    rate_limit_per_minute,
                    rate_limit_per_day,
                    metadata
                )
                VALUES (%s, %s, %s, %s, TRUE, 1000, 100000, %s)
                RETURNING id
            """, (
                key_hash,
                key_prefix,
                name,
                tier,
                json.dumps({
                    'service': 'adsdnsgo',
                    'purpose': 'AEIMS integration',
                    'created_by': 'deploy script'
                })
            ))

            key_id = cursor.fetchone()[0]
            conn.commit()
            print(f"API key registered successfully with ID: {key_id}")
            return key_id

    except Exception as e:
        conn.rollback()
        print(f"Error registering API key: {e}")
        raise
    finally:
        conn.close()


def main():
    # Load the generated API key credentials
    script_dir = os.path.dirname(os.path.abspath(__file__))
    key_file = os.path.join(script_dir, '..', 'api-key.json')

    if not os.path.exists(key_file):
        print(f"Error: API key file not found at {key_file}")
        print("Run generate-api-key.py first to create the key.")
        sys.exit(1)

    with open(key_file, 'r') as f:
        credentials = json.load(f)

    print("=" * 60)
    print("   Registering API Key in dnsscience.io Database")
    print("=" * 60)
    print()
    print(f"Key Prefix:  {credentials['api_key_prefix']}")
    print(f"Key Hash:    {credentials['api_key_hash'][:32]}...")
    print(f"Endpoint:    {credentials['endpoint']}")
    print()

    # Register the key
    key_id = register_api_key(
        key_hash=credentials['api_key_hash'],
        key_prefix=credentials['api_key_prefix'],
        name='adsdnsgo - AEIMS Integration',
        tier='enterprise'
    )

    print()
    print("-" * 60)
    print("API key is now active and ready to use!")
    print("-" * 60)
    print()
    print(f"Database Key ID: {key_id}")
    print(f"API Key:         {credentials['api_key']}")
    print(f"Endpoint:        {credentials['endpoint']}")
    print()


if __name__ == '__main__':
    main()
