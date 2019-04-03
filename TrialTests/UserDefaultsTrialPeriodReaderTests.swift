// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import XCTest
@testable import Trial

class UserDefaultsTrialPeriodReaderTests: XCTestCase {

    var reader: UserDefaultsTrialPeriodReader!
    var userDefaultsDouble: TestUserDefaults!

    override func setUp() {
        super.setUp()
        userDefaultsDouble = TestUserDefaults()
        reader = UserDefaultsTrialPeriodReader()
        reader.userDefaults = userDefaultsDouble
    }

    override func tearDown() {
        reader = nil
        userDefaultsDouble = nil
        super.tearDown()
    }

    func provideTrialDefaults(_ startDate: Date, endDate: Date) {
        userDefaultsDouble.testValues = [
            TrialPeriod.UserDefaultsKeys.startDate : startDate,
            TrialPeriod.UserDefaultsKeys.endDate : endDate
        ]
    }


    // MARK: -
    // MARK: Empty Defaults, no trial

    func testCurrentPeriod_WithEmptyDefaults_QueriesDefaultsForStartData() {

        _ = reader.currentTrialPeriod

        let usedDefaultNames = userDefaultsDouble.didCallObjectForKeyWith
        XCTAssert(hasValue(usedDefaultNames))

        if let usedDefaultNames = usedDefaultNames {

            XCTAssert(usedDefaultNames.contains(TrialPeriod.UserDefaultsKeys.startDate))
        }
    }

    func testCurrentPeriod_WithEmptyDefaults_ReturnsNil() {

        let trialInfo = reader.currentTrialPeriod

        XCTAssertFalse(hasValue(trialInfo))
    }


    // MARK: Existing Defaults, returns trial period

    func testCurrentPeriod_WithDefaultsValues_QueriesDefaultsForStartAndEndDate() {

        provideTrialDefaults(Date(), endDate: Date())

        _ = reader.currentTrialPeriod

        let usedDefaultNames = userDefaultsDouble.didCallObjectForKeyWith
        XCTAssert(hasValue(usedDefaultNames))

        if let usedDefaultNames = usedDefaultNames {

            XCTAssert(usedDefaultNames.contains(TrialPeriod.UserDefaultsKeys.startDate))
        }
    }

    func testCurrentPeriod_WithDefaultsValues_ReturnsTrialPeriodWithInfo() {

        let startDate = Date(timeIntervalSince1970: 0)
        let endDate = Date(timeIntervalSince1970: 12345)
        provideTrialDefaults(startDate, endDate: endDate)

        let trialPeriod = reader.currentTrialPeriod

        XCTAssert(hasValue(trialPeriod))
        if let trialPeriod = trialPeriod {
            XCTAssertEqual(trialPeriod.startDate, startDate)
            XCTAssertEqual(trialPeriod.endDate, endDate)
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
}
