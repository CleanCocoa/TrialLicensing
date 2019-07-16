// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public struct License {
    
    public let name: String?
    public let licenseCode: String

    public var payload: RegistrationPayload {
        if let name = self.name {
            return RegistrationPayload(name: name, licenseCode: self.licenseCode)
        }
        return RegistrationPayload(licenseCode: self.licenseCode)
    }
    
    public init(name: String?, licenseCode: String) {
        
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
