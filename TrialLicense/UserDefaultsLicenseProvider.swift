// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class UserDefaultsLicenseProvider: ProvidesLicense {
    
    public let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    var currentLicense: License? {
        
        if let name = userDefaults.string(forKey: "\(License.UserDefaultsKeys.name)"),
            let licenseCode = userDefaults.string(forKey: "\(License.UserDefaultsKeys.licenseCode)") {
                
                return License(name: name, licenseCode: licenseCode)
        }
        
        return .none
    }
}
