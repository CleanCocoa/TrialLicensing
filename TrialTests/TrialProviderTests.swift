// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import Trial

class TrialProviderTests: XCTestCase {

    let trialProvider = TrialProvider()
    
    let userDefaultsDouble: TestUserDefaults = TestUserDefaults()
    
    override func setUp() {

        super.setUp()
        
        trialProvider.userDefaults = userDefaultsDouble
    }
        
    func provideTrialDefaults(_ startDate: Date, endDate: Date) {
        userDefaultsDouble.testValues = [
            TrialPeriod.UserDefaultsKeys.startDate.rawValue : startDate,
            TrialPeriod.UserDefaultsKeys.endDate.rawValue : endDate
        ]
    }
    
    
    // MARK: -
    // MARK: Empty Defaults, no trial
    
    func testCurrentPeriod_WithEmptyDefaults_QueriesDefaultsForStartData() {
        
        _ = trialProvider.currentTrialPeriod
        
        let usedDefaultNames = userDefaultsDouble.didCallObjectForKeyWith
        XCTAssert(hasValue(usedDefaultNames))
        
        if let usedDefaultNames = usedDefaultNames {
            
            XCTAssert(usedDefaultNames.contains(TrialPeriod.UserDefaultsKeys.startDate.rawValue))
        }
    }
    
    func testCurrentPeriod_WithEmptyDefaults_ReturnsNil() {
        
        let trialInfo = trialProvider.currentTrialPeriod
        
        XCTAssertFalse(hasValue(trialInfo))
    }
    
    
    // MARK: Existing Defaults, returns trial period
    
    func testCurrentPeriod_WithDefaultsValues_QueriesDefaultsForStartAndEndDate() {
        
        provideTrialDefaults(Date(), endDate: Date())
        
        _ = trialProvider.currentTrialPeriod
        
        let usedDefaultNames = userDefaultsDouble.didCallObjectForKeyWith
        XCTAssert(hasValue(usedDefaultNames))
        
        if let usedDefaultNames = usedDefaultNames {
            
            XCTAssert(usedDefaultNames.contains(TrialPeriod.UserDefaultsKeys.startDate.rawValue))
        }
    }
    
    func testCurrentPeriod_WithDefaultsValues_ReturnsTrialPeriodWithInfo() {
        
        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 12345)
        provideTrialDefaults(startDate, endDate: endDate)
        
        let trialPeriod = trialProvider.currentTrialPeriod
        
        XCTAssert(hasValue(trialPeriod))
        if let trialPeriod = trialPeriod {
            XCTAssertEqual(trialPeriod.startDate, startDate)
            XCTAssertEqual(trialPeriod.endDate, endDate)
        }
    }
    
    
    // MARK: Trial wrapping
    
    let clockDouble = TestClock()
    
    func testCurrentTrial_WithoutDefaults_ReturnsNil() {
        
        XCTAssertFalse(hasValue(trialProvider.currentTrial(clock: clockDouble)))
    }
    
    func testCurrentTrial_WithTrialPeriod_ReturnsTrialWithClockAndPeriod() {
        
        let startDate = Date(timeIntervalSince1970: 456)
        let endDate = Date(timeIntervalSince1970: 999)
        provideTrialDefaults(startDate, endDate: endDate)
        
        let trial = trialProvider.currentTrial(clock: clockDouble)
        
        XCTAssert(hasValue(trial))
        if let trial = trial {
            XCTAssertEqual(trial.trialPeriod, trialProvider.currentTrialPeriod!)
            XCTAssert(trial.clock === clockDouble)
        }
    }
    
    
    // MARK : -

    class TestUserDefaults: NullUserDefaults {
        
        var testValues = [AnyHashable : Any]()
        var didCallObjectForKeyWith: [String]?
        override func object(forKey defaultName: String) -> Any? {
            
            if !hasValue(didCallObjectForKeyWith) {
                didCallObjectForKeyWith = [String]()
            }
            
            didCallObjectForKeyWith?.append(defaultName)
            
            return testValues[defaultName]
        }
    }
    
    class TestClock: KnowsTimeAndDate {
        
        var testDate: Date!
        func now() -> Date {
            
            return testDate
        }
    }
}
