// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class LicenseWriter {
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    
    init() { }

    func store(license: License) {

        self.store(licenseCode: license.licenseCode, forName: license.name)
    }

    func store(licenseCode: String, forName name: String) {
        
        userDefaults.setValue(name, forKey: License.UserDefaultsKeys.name)
        userDefaults.setValue(licenseCode, forKey: License.UserDefaultsKeys.licenseCode)
    }

    func removeLicense() {

        userDefaults.removeObject(forKey: License.UserDefaultsKeys.name)
        userDefaults.removeObject(forKey: License.UserDefaultsKeys.licenseCode)
    }
}
