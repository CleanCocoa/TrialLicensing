// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class UserDefaultsLicenseProvider: ProvidesLicense {
    
    let userDefaults: UserDefaults
    let trimmingWhitespace: Bool

    init(userDefaults: UserDefaults, trimmingWhitespace: Bool) {
        self.userDefaults = userDefaults
        self.trimmingWhitespace = trimmingWhitespace
    }
    
    var currentLicense: License? {
        guard let licenseCode = self.licenseCode else { return nil }
        return License(name: self.name, licenseCode: licenseCode)
    }

    @inline(__always)
    private var licenseCode: String? {
        let licenseCode = userDefaults.string(forKey: "\(License.UserDefaultsKeys.licenseCode)")
        if trimmingWhitespace {
            return licenseCode?.replacingCharacters(of: .whitespacesAndNewlines, with: "")
        } else {
            return licenseCode
        }
    }

    @inline(__always)
    private var name: String? { userDefaults.string(forKey: "\(License.UserDefaultsKeys.name)") }
}
