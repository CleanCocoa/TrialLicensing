// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public struct License {
    
    public let name: String
    public let licenseCode: String
    
    public init(name: String, licenseCode: String) {
        
        self.name = name
        self.licenseCode = licenseCode
    }
    
    public struct UserDefaultsKeys {
        private init() { }

        public static func change(nameKey: String, licenseCodeKey: String) {
            UserDefaultsKeys.name = nameKey
            UserDefaultsKeys.licenseCode = licenseCodeKey
        }

        public static var name = "licensee"
        public static var licenseCode = "license_code"
    }
}

extension License: Equatable { }

public func ==(lhs: License, rhs: License) -> Bool {
    
    return lhs.name == rhs.name && lhs.licenseCode == rhs.licenseCode
}
