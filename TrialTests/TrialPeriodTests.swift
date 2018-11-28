// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import Trial

class TrialPeriodTests: XCTestCase {

    var clockDouble: TestClock!

    override func setUp() {
        super.setUp()
        clockDouble = TestClock()
    }

    override func tearDown() {
        clockDouble = nil
        super.tearDown()
    }

    let irrelevantDate = Date(timeIntervalSinceNow: 987654321)
    
    func testCreation_WithClock_AddsDaysToCurrentTime() {
        
        let date = Date(timeIntervalSinceReferenceDate: 9999)
        clockDouble.testDate = date
        // 10 days
        let expectedDate = date.addingTimeInterval(10 * 24 * 60 * 60)
        
        let trialPeriod = TrialPeriod(numberOfDays: Days(10), clock: clockDouble)
        
        XCTAssertEqual(trialPeriod.startDate, date)
        XCTAssertEqual(trialPeriod.endDate, expectedDate)
    }
    
    
    // MARK: Days left
    
    func testDaysLeft_12Hours_ReturnsHalfDay() {
        
        let currentDate = Date()
        clockDouble.testDate = currentDate
        let endDate = currentDate.addingTimeInterval(12*60*60)
        let trialPeriod = TrialPeriod(startDate: irrelevantDate, endDate: endDate)
        
        let daysLeft = trialPeriod.daysLeft(clock: clockDouble)
        
        XCTAssertEqual(daysLeft, Days(0.5))
    }
    
    
    // MARK: Ended?
    
    func testTrialEnded_WithEarlierClock_ReturnsFalse() {
        
        let endDate = Date(timeIntervalSinceNow: 4567)
        let trialPeriod = TrialPeriod(startDate: irrelevantDate, endDate: endDate)
        
        clockDouble.testDate = Date(timeIntervalSinceNow: 1)
        
        XCTAssertFalse(trialPeriod.ended(clock: clockDouble))
    }

    func testTrialEnded_WithLaterClock_ReturnsTrue() {
        
        let endDate = Date(timeIntervalSinceNow: 4567)
        let trialPeriod = TrialPeriod(startDate: irrelevantDate, endDate: endDate)
        
        clockDouble.testDate = Date(timeIntervalSinceNow: 9999)
        
        XCTAssert(trialPeriod.ended(clock: clockDouble))
    }
    
    
    // MARK: -
    
    class TestClock: KnowsTimeAndDate {
        
        var testDate: Date!
        func now() -> Date {
            
            return testDate
        }
    }
}
