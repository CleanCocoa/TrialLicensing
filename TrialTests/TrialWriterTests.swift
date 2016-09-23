// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import Trial

class TrialWriterTests: XCTestCase {

    let writer = TrialWriter()

    let userDefaultsDouble: TestUserDefaults = TestUserDefaults()
    
    override func setUp() {
        
        super.setUp()
        
        writer.userDefaults = userDefaultsDouble
    }

    func testStoring_DelegatesToUserDefaults() {
        
        // Given
        let startDate = Date(timeIntervalSince1970: 4567)
        let endDate = Date(timeIntervalSince1970: 121314)
        let trialPeriod = TrialPeriod(startDate: startDate, endDate: endDate)
        
        // When
        writer.store(trialPeriod: trialPeriod)
        
        // Then
        let changedDefaults = userDefaultsDouble.didSetObjectsForKeys
        XCTAssert(hasValue(changedDefaults))
        
        if let changedDefaults = changedDefaults {
            
            XCTAssert(changedDefaults[TrialPeriod.UserDefaultsKeys.startDate] == startDate)
            XCTAssert(changedDefaults[TrialPeriod.UserDefaultsKeys.endDate] == endDate)
        }
    }

    
    // MARK: - 
    
    class TestUserDefaults: NullUserDefaults {
        
        var didSetObjectsForKeys: [String : Date]?
        override func set(_ value: Any?, forKey key: String) {
            
            if !hasValue(didSetObjectsForKeys) {
                didSetObjectsForKeys = [String : Date]()
            }
            
            didSetObjectsForKeys![key] = value as? Date
        }
    }
}
