// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation
import CocoaFob

/// Verifies license information based on the registration
/// scheme `APPNAME,LICENSEE_NAME` which ties licenses to
/// both application and user.
open class LicenseVerifier {

    let configuration: LicenseConfiguration
    fileprivate var appName: String { return configuration.appName }
    fileprivate var publicKey: String { return configuration.publicKey }

    public init(configuration: LicenseConfiguration) {
        
        self.configuration = configuration
    }
    
    open func isValid(licenseCode: String, forName name: String) -> Bool {
        
        // Same format as on FastSpring
        let registrationName = "\(appName),\(name)"
        let publicKey = self.publicKey
        
        guard let verifier = verifier(publicKey: publicKey) else {
            assertionFailure("CocoaFob.LicenseVerifier cannot be constructed")
            return false
        }
        
        return verifier.verify(licenseCode, forName: registrationName)
    }
    
    fileprivate func verifier(publicKey: String) -> CocoaFob.LicenseVerifier? {

        return CocoaFob.LicenseVerifier(publicKeyPEM: publicKey)
    }
}
