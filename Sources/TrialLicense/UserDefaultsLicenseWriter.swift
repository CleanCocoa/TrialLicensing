// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class UserDefaultsLicenseWriter: WritesLicense {
    
    let userDefaults: UserDefaults
    let removingWhitespace: Bool

    init(userDefaults: UserDefaults, removingWhitespace: Bool) {
        self.userDefaults = userDefaults
        self.removingWhitespace = removingWhitespace
    }

    func store(licenseCode untreatedLicenseCode: String, forName name: String?) {

        let licenseCode: String
        if removingWhitespace {
            licenseCode = untreatedLicenseCode.replacingCharacters(of: .whitespacesAndNewlines, with: "")
        } else {
            licenseCode = untreatedLicenseCode
        }

        userDefaults.setValue(name, forKey: License.UserDefaultsKeys.name)
        userDefaults.setValue(licenseCode, forKey: License.UserDefaultsKeys.licenseCode)
    }

    func removeLicense() {

        userDefaults.removeObject(forKey: License.UserDefaultsKeys.name)
        userDefaults.removeObject(forKey: License.UserDefaultsKeys.licenseCode)
    }
}
