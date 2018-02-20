// Copyright (c) 2015-2018 Christian Tietze
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

class LicenseVerifierTests: XCTestCase {

    let verifier: LicenseVerifier = {
        let configuration = LicenseConfiguration(appName: "MyNewApp", publicKey: publicKey)
        return LicenseVerifier(configuration: configuration)
    }()

    let validLicense = License(name: "John Appleseed", licenseCode: "GAWQE-FABU3-HNQXA-B7EGM-34X2E-DGMT4-4F44R-9PUQC-CUANX-FXMCZ-4536Y-QKX9D-PU2C3-QG2ZA-U88NJ-Q")

    func testVerify_EmptyStrings_ReturnsFalse() {
        
        let result = verifier.isValid(licenseCode: "", forName: "")
        
        XCTAssertFalse(result)
    }
    
    func testVerify_ValidCodeWrongName_ReturnsFalse() {
        
        let result = verifier.isValid(licenseCode: validLicense.licenseCode, forName: "Jon Snow")
        
        XCTAssertFalse(result)
    }
    
    func testVerify_ValidLicense_ReturnsTrue() {
        
        let result = verifier.isValid(licenseCode: validLicense.licenseCode, forName: validLicense.name)
        
        XCTAssert(result)
    }
    
    func testVerify_ValidLicenseWrongAppName_ReturnsFalse() {

        let configuration = LicenseConfiguration(appName: "TotallyWrongAppName", publicKey: publicKey)
        let verifier = LicenseVerifier(configuration: configuration)
        
        let result = verifier.isValid(licenseCode: validLicense.licenseCode, forName: validLicense.name)
        
        XCTAssertFalse(result)
    }
}
