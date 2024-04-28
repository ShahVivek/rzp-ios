//
//  UserDefaults.swift
//  CricBuddy
//
//  Created by Vivek Shah on 26/03/24.
//
import Foundation

// Create a separate file, e.g., UserDefaultsExtension.swift

extension UserDefaults {
    // Method to set a value (as string) for a specific key
    static func setString(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    // Method to get a string value for a specific key
    static func getString(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    // Method for setting a value (as string) with key in a generic way
    static func set<T>(_ value: T, forKey key: String) {
        if let stringValue = value as? String {
            setString(stringValue, forKey: key)
        } else {
            setString(String(describing: value), forKey: key)
        }
    }
    
    // Method for getting a value using key in a generic way
    static func get<T>(forKey key: String) -> T? {
        guard let stringValue = getString(forKey: key) else { return nil }
        return stringValue as? T
    }
}
