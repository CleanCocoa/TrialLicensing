// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

open class LicenseWriter {
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    
    public init() { }
    
    open func store(licenseCode: String, forName name: String) {
        
        userDefaults.setValue(name, forKey: "\(License.UserDefaultsKeys.name)")
        userDefaults.setValue(licenseCode, forKey: "\(License.UserDefaultsKeys.licenseCode)")
    }
}
