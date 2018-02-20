// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class LicenseProvider {
    
    init() { }
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    
    var currentLicense: License? {
        
        if let name = userDefaults.string(forKey: "\(License.UserDefaultsKeys.name)"),
            let licenseCode = userDefaults.string(forKey: "\(License.UserDefaultsKeys.licenseCode)") {
                
                return License(name: name, licenseCode: licenseCode)
        }
        
        return .none
    }
}
