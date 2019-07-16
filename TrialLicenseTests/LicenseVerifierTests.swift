// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense

fileprivate let publicKey: String = {

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
}()

fileprivate let appName = "MyNewApp"

fileprivate func personalizedRegistrationName(licenseeName: String) -> String {
    return LicensingScheme.personalizedLicense.registrationName(
        appName: appName,
        payload: [.name : licenseeName])
}

class LicenseVerifierTests: XCTestCase {

    var verifier: LicenseVerifier!

    override func setUp() {
        super.setUp()
        let configuration = LicenseConfiguration(appName: appName, publicKey: publicKey)
        verifier = LicenseVerifier(configuration: configuration)
    }

    override func tearDown() {
        verifier = nil
        super.tearDown()
    }
    
    func testVerify_EmptyStrings_ReturnsFalse() {
        
        let result = verifier.isValid(licenseCode: "", registrationName: "")
        
        XCTAssertFalse(result)
    }

    // MARK: Personalized license

    var validPersonalizedLicense: License {
        return License(
            name: "John Appleseed",
            licenseCode: "GAWQE-FABU3-HNQXA-B7EGM-34X2E-DGMT4-4F44R-9PUQC-CUANX-FXMCZ-4536Y-QKX9D-PU2C3-QG2ZA-U88NJ-Q")
    }

    func testVerifyPersonalizedLicense_ValidCodeWrongName_ReturnsFalse() {
        
        let result = verifier.isValid(licenseCode: validPersonalizedLicense.licenseCode,
                                      registrationName: personalizedRegistrationName(licenseeName: "Jon Snow"))
        
        XCTAssertFalse(result)
    }
    
    func testVerifyPersonalizedLicense_ValidLicense_ReturnsTrue() {
        
        let result = verifier.isValid(licenseCode: validPersonalizedLicense.licenseCode,
                                      registrationName: personalizedRegistrationName(licenseeName: validPersonalizedLicense.name!))
        
        XCTAssert(result)
    }
    
    func testVerifyPersonalizedLicense_ValidLicenseWrongAppName_ReturnsFalse() {

        let registrationNameForWrongApp = LicensingScheme.personalizedLicense.registrationName(
            appName: "totally-wrong-app-name",
            payload: [.name : validPersonalizedLicense.name!])

        let result = verifier.isValid(licenseCode: validPersonalizedLicense.licenseCode,
                                      registrationName: registrationNameForWrongApp)
        
        XCTAssertFalse(result)
    }
}
