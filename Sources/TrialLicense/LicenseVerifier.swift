// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation
import CocoaFob

public protocol LicenseCodeVerification: AnyObject {
    func isValid(licenseCode: String, registrationName: String) -> Bool
}

/// Verifies license information based on the registration
/// scheme. This is either
/// - `APPNAME,LICENSEE_NAME`, which ties licenses to both application and user, or
/// - `APPNAME` only.
class LicenseVerifier: LicenseCodeVerification {

    let configuration: LicenseConfiguration
    fileprivate var publicKey: String { return configuration.publicKey }

    init(configuration: LicenseConfiguration) {
        
        self.configuration = configuration
    }

    /// - parameter licenseCode: License key to verify.
    /// - parameter registrationName: Format as used on FastSpring, e.g. "appName,userName".
    func isValid(licenseCode: String, registrationName: String) -> Bool {

        guard let verifier = verifier(publicKey: self.publicKey) else {
            assertionFailure("CocoaFob.LicenseVerifier cannot be constructed")
            return false
        }

        return verifier.verify(licenseCode, forName: registrationName)
    }

    fileprivate func verifier(publicKey: String) -> CocoaFob.LicenseVerifier? {

        return CocoaFob.LicenseVerifier(publicKeyPEM: publicKey)
    }
}
