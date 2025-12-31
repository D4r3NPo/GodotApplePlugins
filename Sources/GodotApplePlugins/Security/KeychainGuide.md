# iOS Keychain Integration Guide

Secure storage for sensitive data on iOS and macOS.

## Basic Usage

```gdscript
# Store a string
Keychain.set_string("user_token", "abc123")

# Retrieve a string
var token = Keychain.get_string("user_token")

# Check if exists
if Keychain.has_key("user_token"):
    print("Token exists")

# Delete
Keychain.delete("user_token")

# Store binary data
var data = PackedByteArray([1, 2, 3, 4])
Keychain.set_data("encryption_key", data)

# Retrieve binary data
var key_data = Keychain.get_data("encryption_key")
```

## With Service Identifiers

```gdscript
# Organize by service
Keychain.set_string("password", "secret", "com.mygame.auth")
var password = Keychain.get_string("password", "com.mygame.auth")

# Get all keys for a service
var keys = Keychain.get_all_keys("com.mygame.auth")

# Clear all for a service
Keychain.clear_all("com.mygame.auth")
```

## Common Use Case

```gdscript
const SERVICE = "com.mygame.auth"

func save_login(username: String, token: String):
    Keychain.set_string("username", username, SERVICE)
    Keychain.set_string("token", token, SERVICE)

func get_saved_token() -> String:
    return Keychain.get_string("token", SERVICE)

func logout():
    Keychain.clear_all(SERVICE)
```

## API Methods

- `set_string(key, value, service="")` - Store string
- `get_string(key, service="")` - Retrieve string
- `set_data(key, data, service="")` - Store binary data
- `get_data(key, service="")` - Retrieve binary data
- `has_key(key, service="")` - Check existence
- `delete(key, service="")` - Remove item
- `update_string(key, value, service="")` - Update or create string
- `update_data(key, data, service="")` - Update or create data
- `get_all_keys(service="")` - List all keys
- `clear_all(service="")` - Remove all items
