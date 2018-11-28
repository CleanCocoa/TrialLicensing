// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import XCTest
@testable import Trial

class TrialProviderTests: XCTestCase {

    var trialProvider: TrialProvider!
    var trialReaderDouble: TrialPeriodReaderDouble!
    var clockDouble: KnowsTimeAndDate!

    override func setUp() {
        super.setUp()
        clockDouble = TestClock()
        trialReaderDouble = TrialPeriodReaderDouble()
        trialProvider = TrialProvider(trialPeriodReader: trialReaderDouble)
    }

    override func tearDown() {
        clockDouble = nil
        trialReaderDouble = nil
        trialProvider = nil
        super.tearDown()
    }


    // MARK: -
    // MARK: Empty Defaults, no trial

    func testCurrentPeriod_ReaderReturnsNil_ReturnsNil() {
        trialReaderDouble.testTrialPeriod = nil

        XCTAssertNil(trialProvider.currentTrialPeriod)
    }

    func testCurrentPeriod_ReaderReturnsTrialPeriod_ForwardsResult() {
        let trialPeriod = TrialPeriod.init(startDate: Date(timeIntervalSince1970: 1234), endDate: Date(timeIntervalSince1970: 5678))
        trialReaderDouble.testTrialPeriod = trialPeriod

        XCTAssertEqual(trialProvider.currentTrialPeriod, trialPeriod)
    }
    
    
    // MARK: Trial wrapping
    
    func testCurrentTrial_EmptyReader_ReturnsNil() {
        trialReaderDouble.testTrialPeriod = nil

        XCTAssertFalse(hasValue(trialProvider.currentTrial(clock: clockDouble)))
    }
    
    func testCurrentTrial_WithTrialPeriod_ReturnsTrialWithClockAndPeriod() {
        let trialPeriod = TrialPeriod(startDate: Date(timeIntervalSince1970: 456), endDate: Date(timeIntervalSince1970: 999))
        trialReaderDouble.testTrialPeriod = trialPeriod
        
        let trial = trialProvider.currentTrial(clock: clockDouble)
        
        XCTAssert(hasValue(trial))
        if let trial = trial {
            XCTAssertEqual(trial.trialPeriod, trialPeriod)
            XCTAssert(trial.clock === clockDouble)
        }
    }
    
    
    // MARK : -

    class TrialPeriodReaderDouble: ReadsTrialPeriod {
        var testTrialPeriod: TrialPeriod? = nil
        var currentTrialPeriod: TrialPeriod? {
            return testTrialPeriod
        }
    }
    
    class TestClock: KnowsTimeAndDate {
        var testDate: Date!
        func now() -> Date {
            return testDate
        }
    }
}
