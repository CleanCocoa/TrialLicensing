// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import XCTest
@testable import TrialLicense

class UserDefaultsLicenseWriterTests: XCTestCase {

    var userDefaultsDouble: TestUserDefaults!

    override func setUp() {
        super.setUp()

        userDefaultsDouble = TestUserDefaults()
    }

    override func tearDown() {
        userDefaultsDouble = nil
        super.tearDown()
    }
    
    // MARK: Storing
    
    func testStoring_TrimmingWhitespace_DelegatesToUserDefaults() {
        let writer = UserDefaultsLicenseWriter(userDefaults: userDefaultsDouble, trimmingWhitespace: true)
        let name = "a name"
        
        writer.store(licenseCode: "  \t \n a license code \n   ", forName: name)
        
        let changedDefaults = userDefaultsDouble.didSetValuesForKeys
        XCTAssert(hasValue(changedDefaults))
        if let changedDefaults = changedDefaults {
            
            XCTAssert(changedDefaults[License.UserDefaultsKeys.name] == name)
            XCTAssert(changedDefaults[License.UserDefaultsKeys.licenseCode] == "alicensecode")
        }
    }

    func testStoring_PreservingWhitespace_DelegatesToUserDefaults() {
        let writer = UserDefaultsLicenseWriter(userDefaults: userDefaultsDouble, trimmingWhitespace: false)
        let licenseCode = "  \t \n a license code \n   "
        let name = "a name"

        writer.store(licenseCode: licenseCode, forName: name)

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
