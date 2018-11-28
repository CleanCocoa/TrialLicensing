// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense

class LicenseWriterTests: XCTestCase {

    var writer: LicenseWriter!
    var userDefaultsDouble: TestUserDefaults!

    override func setUp() {
        super.setUp()

        userDefaultsDouble = TestUserDefaults()

        writer = LicenseWriter()
        writer.userDefaults = userDefaultsDouble
    }

    override func tearDown() {
        writer = nil
        userDefaultsDouble = nil
        super.tearDown()
    }
    
    // MARK: Storing
    
    func testStoring_DelegatesToUserDefaults() {
        
        // Given
        let licenseCode = "a license code"
        let name = "a name"
        
        // When
        writer.store(licenseCode: licenseCode, forName: name)
        
        // Then
        let changedDefaults = userDefaultsDouble.didSetValuesForKeys
        XCTAssert(hasValue(changedDefaults))
        
        if let changedDefaults = changedDefaults {
            
            XCTAssert(changedDefaults[License.UserDefaultsKeys.name] == name)
            XCTAssert(changedDefaults[License.UserDefaultsKeys.licenseCode] == licenseCode)
        }
    }


    // MARK: -
    
    class TestUserDefaults: NullUserDefaults {
        
        var didSetValuesForKeys: [String : String]?
        override func setValue(_ value: Any?, forKey key: String) {
            
            if !hasValue(didSetValuesForKeys) {
                didSetValuesForKeys = [String : String]()
            }
            
            didSetValuesForKeys![key] = value as? String
        }
    }
}
