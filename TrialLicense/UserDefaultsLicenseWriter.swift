// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class UserDefaultsLicenseWriter: WritesLicense {
    
    init() { }

    lazy var userDefaults: UserDefaults = UserDefaults.standard

    func store(licenseCode: String, forName name: String) {
        
        userDefaults.setValue(name, forKey: License.UserDefaultsKeys.name)
        userDefaults.setValue(licenseCode, forKey: License.UserDefaultsKeys.licenseCode)
    }

    func removeLicense() {

        userDefaults.removeObject(forKey: License.UserDefaultsKeys.name)
        userDefaults.removeObject(forKey: License.UserDefaultsKeys.licenseCode)
    }
}
