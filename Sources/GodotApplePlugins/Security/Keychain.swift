//
//  Keychain.swift
//  GodotApplePlugins
//
//  iOS Keychain Services wrapper for secure storage
//

import Foundation
import Security
import SwiftGodotRuntime

@Godot
class Keychain: RefCounted, @unchecked Sendable {
    
    /// Stores a string value in the keychain
    /// - Parameters:
    ///   - key: The key to store the value under
    ///   - value: The string value to store
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if successful, false otherwise
    @Callable
    static func set_string(key: String, value: String, service: String = "") -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let byteArray = VariantArray()
        for byte in data {
            byteArray.append(Variant(Int(byte)))
        }
        return set_data(key: key, data: byteArray, service: service)
    }
    
    /// Retrieves a string value from the keychain
    /// - Parameters:
    ///   - key: The key to retrieve the value for
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: The stored string value, or empty string if not found
    @Callable
    static func get_string(key: String, service: String = "") -> String {
        let data = get_data(key: key, service: service)
        if data.size() == 0 {
            return ""
        }
        
        let bytes = data.reduce(into: [UInt8]()) { result, element in
            if let byte = UInt8(element) {
                result.append(byte)
            }
        }
        
        return String(data: Data(bytes), encoding: .utf8) ?? ""
    }
    
    /// Stores binary data in the keychain
    /// - Parameters:
    ///   - key: The key to store the data under
    ///   - data: The data to store as a VariantArray of bytes
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if successful, false otherwise
    @Callable
    static func set_data(key: String, data: VariantArray, service: String = "") -> Bool {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        // Convert GArray to Data
        let bytes = data.reduce(into: [UInt8]()) { result, element in
            if let byte = UInt8(element) {
                result.append(byte)
            }
        }
        let dataToStore = Data(bytes)
        
        // Delete any existing item
        let _ = delete(key: key, service: service)
        
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: serviceId,
            kSecValueData as String: dataToStore,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Retrieves binary data from the keychain
    /// - Parameters:
    ///   - key: The key to retrieve the data for
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: The stored data as a VariantArray of bytes, or empty array if not found
    @Callable
    static func get_data(key: String, service: String = "") -> VariantArray {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: serviceId,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            return VariantArray()
        }
        
        let byteArray = VariantArray()
        for byte in data {
            byteArray.append(Variant(Int(byte)))
        }
        
        return byteArray
    }
    
    /// Deletes an item from the keychain
    /// - Parameters:
    ///   - key: The key to delete
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if successful or item didn't exist, false otherwise
    @Callable
    static func delete(key: String, service: String = "") -> Bool {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: serviceId
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Checks if a key exists in the keychain
    /// - Parameters:
    ///   - key: The key to check
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if the key exists, false otherwise
    @Callable
    static func has_key(key: String, service: String = "") -> Bool {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: serviceId,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Updates an existing keychain item with new string value
    /// - Parameters:
    ///   - key: The key to update
    ///   - value: The new string value
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if successful, false otherwise
    @Callable
    static func update_string(key: String, value: String, service: String = "") -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let byteArray = VariantArray()
        for byte in data {
            byteArray.append(Variant(Int(byte)))
        }
        return update_data(key: key, data: byteArray, service: service)
    }
    
    /// Updates an existing keychain item with new binary data
    /// - Parameters:
    ///   - key: The key to update
    ///   - data: The new data as a VariantArray of bytes
    ///   - service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if successful, false otherwise
    @Callable
    static func update_data(key: String, data: VariantArray, service: String = "") -> Bool {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        // Convert GArray to Data
        let bytes = data.reduce(into: [UInt8]()) { result, element in
            if let byte = UInt8(element) {
                result.append(byte)
            }
        }
        let dataToStore = Data(bytes)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: serviceId
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: dataToStore
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        // If item doesn't exist, try to add it
        if status == errSecItemNotFound {
            return set_data(key: key, data: data, service: service)
        }
        
        return status == errSecSuccess
    }
    
    /// Retrieves all keys stored in the keychain for the service
    /// - Parameter service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: Array of key names
    @Callable
    static func get_all_keys(service: String = "") -> VariantArray {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceId,
            kSecReturnAttributes as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let items = result as? [[String: Any]] else {
            return VariantArray()
        }
        
        let keys = VariantArray()
        for item in items {
            if let account = item[kSecAttrAccount as String] as? String {
                keys.append(Variant(account))
            }
        }
        
        return keys
    }
    
    /// Clears all keychain items for the service
    /// - Parameter service: Optional service identifier (defaults to bundle identifier)
    /// - Returns: true if successful, false otherwise
    @Callable
    static func clear_all(service: String = "") -> Bool {
        let serviceId = service.isEmpty ? getDefaultService() : service
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceId
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Private Helpers
    
    private static func getDefaultService() -> String {
        return Bundle.main.bundleIdentifier ?? "com.godot.game"
    }
}
