// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class UserDefaultsLicenseWriter: WritesLicense {
    
    public let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    func store(licenseCode: String, forName name: String?) {
        
        userDefaults.setValue(name, forKey: License.UserDefaultsKeys.name)
        userDefaults.setValue(licenseCode, forKey: License.UserDefaultsKeys.licenseCode)
    }

    func removeLicense() {

        userDefaults.removeObject(forKey: License.UserDefaultsKeys.name)
        userDefaults.removeObject(forKey: License.UserDefaultsKeys.licenseCode)
    }
}
