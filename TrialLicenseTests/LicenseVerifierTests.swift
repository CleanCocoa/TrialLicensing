// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense

class LicenseVerifierTests: XCTestCase {

    let verifier = LicenseVerifier()
    
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
    
    func testVerify_ValidLicenseWrongApp_ReturnsFalse() {
        
        let verifier = LicenseVerifier(appName: "AnotherApp")
        
        let result = verifier.isValid(licenseCode: validLicense.licenseCode, forName: validLicense.name)
        
        XCTAssertFalse(result)
    }
}
