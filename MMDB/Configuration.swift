//
//  Configuration.swift
//  MMDB
//
//  Secure configuration management
//  Created by Tushar Chitnavis on 18/11/25.
//

import Foundation

enum Configuration {
    
    enum Error: Swift.Error {
        case missingKey
        case invalidValue
        case missingConfigFile
        
        var localizedDescription: String {
            switch self {
            case .missingConfigFile:
                return "Configuration file (Config.plist) not found. Please create it from Config.plist.template and add your TMDB API key."
            case .invalidValue:
                return "Invalid API key in Config.plist. Please ensure TMDB_API_KEY is set correctly."
            case .missingKey:
                return "API key not found in Config.plist. Please add your TMDB API key."
            }
        }
    }
    
    static func value<T>(for key: String) throws -> T where T: LosslessStringConvertible {
        // Try to read from Config.plist
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath) else {
            throw Error.missingConfigFile
        }
        
        guard let value = plist.object(forKey: key) as? T else {
            throw Error.invalidValue
        }
        
        return value
    }
    
    static func tmdbAPIKey() throws -> String {
        let key: String = try value(for: "TMDB_API_KEY")
        
        // Validate the key is not empty or placeholder
        guard !key.isEmpty, key != "YOUR_API_KEY_HERE" else {
            throw Error.missingKey
        }
        
        return key
    }
}

