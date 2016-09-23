// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation
import CocoaFob

open class LicenseVerifier {
    
    static let AppName = "MyNewApp"
    let appName: String
    
    public convenience init() {
        
        self.init(appName: LicenseVerifier.AppName)
    }
    
    public init(appName: String) {
        
        self.appName = appName
    }
    
    open func isValid(licenseCode: String, forName name: String) -> Bool {
        
        // Same format as on FastSpring
        let registrationName = "\(appName),\(name)"
        let publicKey = self.publicKey()
        
        guard let verifier = verifier(publicKey: publicKey) else {
            assertionFailure("CocoaFob.LicenseVerifier cannot be constructed")
            return false
        }
        
        return verifier.verify(licenseCode, forName: registrationName)
    }
    
    fileprivate func verifier(publicKey: String) -> CocoaFob.LicenseVerifier? {

        return CocoaFob.LicenseVerifier(publicKeyPEM: publicKey)
    }
    
    fileprivate func publicKey() -> String {
        
        var parts = [String]()
        
        parts.append("-----BEGIN DSA PUBLIC KEY-----\n")
        parts.append("MIHwMIGoBgcqhkjOOAQBMIGcAkEAoKLaPXkgAPng5YtV")
        parts.append("G14BUE1I5Q")
        parts.append("aGesaf9PTC\nnmUlYMp4m7M")
        parts.append("rVC2/YybXE")
        parts.append("QlaILBZBmyw+A4Kps2k/T12q")
        parts.append("L8EUwIVAPxEzzlcqbED\nKaw6oJ9THk1i4Lu")
        parts.append("TAkAG")
        parts.append("RPr6HheNNnH9GQZGjCuv")
        parts.append("6pLUOBo64QJ0WNEs2c9QOSBU\nHpWZU")
        parts.append("m8bGMQevt38P")
        parts.append("iSZZwU0hCAJ6pd09eeTP983A0MAAkB+yDfp+53KPSk")
        parts.append("5dH")
        parts.append("xh\noBm6kTBKsYk")
        parts.append("xonpPlBrFJTJeyvZInHIKrd0N8Du")
        parts.append("i3XKDtqrLWPIQcM0mWOj")
        parts.append("YHUlf\nUpIg\n")
        parts.append("-----END DSA PUBLIC KEY-----\n")
        
        let publicKey = parts.joined(separator: "")
        
        return publicKey
    }
}
