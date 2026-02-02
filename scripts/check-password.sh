#!/bin/bash
# Check if a password has been found in data breaches using Have I Been Pwned API

read -s -p "Enter password: " pw
echo

# Hash the password with SHA-1 and convert to uppercase
hash=$(echo -n "$pw" | shasum -a 1 | awk '{print toupper($1)}')

# Split hash into prefix (first 5 chars) and suffix (remaining chars)
prefix=${hash:0:5}
suffix=${hash:5}

# Query HIBP API and check if suffix exists in results
curl -s "https://api.pwnedpasswords.com/range/$prefix" | grep -i "$suffix" && echo "⚠️  Password found in breaches!" || echo "✅ Password not found."

# Clean up sensitive variables
unset pw hash prefix suffix
