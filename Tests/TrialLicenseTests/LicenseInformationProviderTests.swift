// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import XCTest
@testable import TrialLicense
import Trial

class LicenseInformationProviderTests: XCTestCase {

    var licenseInfoProvider: LicenseInformationProvider!
    
    var trialProviderDouble: TestTrialProvider!
    var licenseProviderDouble: TestLicenseProvider!
    var clockDouble: TestClock!
    var registrationStrategyDouble: TestRegistrationStrategy!

    var configuration: LicenseConfiguration {
        return LicenseConfiguration(appName: "NameOfTheApp", publicKey: "the-irrelevant-key")
    }

    override func setUp() {
        super.setUp()

        trialProviderDouble = TestTrialProvider()
        licenseProviderDouble = TestLicenseProvider()
        clockDouble = TestClock()
        registrationStrategyDouble = TestRegistrationStrategy()
        
        licenseInfoProvider = LicenseInformationProvider(
            trialProvider: trialProviderDouble,
            licenseProvider: licenseProviderDouble,
            licenseVerifier: NullVerifier(),
            registrationStrategy: registrationStrategyDouble,
            configuration: configuration,
            clock: clockDouble)
    }

    override func tearDown() {
        trialProviderDouble = nil
        licenseProviderDouble = nil
        clockDouble = nil
        licenseInfoProvider = nil
        registrationStrategyDouble = nil
        super.tearDown()
    }
    
    let irrelevantLicense = License(name: "", licenseCode: "")

    func testLicenceInvalidity_NoLicense_ReturnsFalse() {
        
        XCTAssertFalse(licenseInfoProvider.isLicenseInvalid)
    }
    
    func testLicenceInvalidity_ValidLicense_ReturnsFalse() {
        
        registrationStrategyDouble.testIsValid = true
        licenseProviderDouble.testLicense = irrelevantLicense
        
        XCTAssertFalse(licenseInfoProvider.isLicenseInvalid)
    }
    
    func testLicenceInvalidity_InvalidLicense_ReturnsFalse() {
        
        registrationStrategyDouble.testIsValid = false
        licenseProviderDouble.testLicense = irrelevantLicense
        
        XCTAssert(licenseInfoProvider.isLicenseInvalid)
    }
    
    func testCurrentInfo_NoLicense_NoTrialPeriod_ReturnsTrialUp() {
        
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        let trialIsUp: Bool
        
        switch licenseInfo {
        case .trialUp: trialIsUp = true
        default: trialIsUp = false
        }
        
        XCTAssert(trialIsUp)
    }
    
    func testCurrentInfo_NoLicense_ActiveTrialPeriod_ReturnsOnTrial() {
        
        let endDate = Date()
        let expectedPeriod = TrialPeriod(startDate: Date(), endDate: Date())
        clockDouble.testDate = endDate.addingTimeInterval(-1000)
        trialProviderDouble.testTrialPeriod = expectedPeriod
        
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        switch licenseInfo {
        case let .onTrial(trialPeriod): XCTAssertEqual(trialPeriod, expectedPeriod)
        default: XCTFail("expected to be onTrial, got \(licenseInfo)")
        }
    }
    
    func testCurrentInfo_NoLicense_PassedTrialPeriod_ReturnsTrialUp() {
        
        let endDate = Date()
        let expectedPeriod = TrialPeriod(startDate: Date(), endDate: Date())
        clockDouble.testDate = endDate.addingTimeInterval(100)
        trialProviderDouble.testTrialPeriod = expectedPeriod
        
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        let trialIsUp: Bool
        switch licenseInfo {
        case .trialUp: trialIsUp = true
        default: trialIsUp = false
        }
        
        XCTAssert(trialIsUp)
    }

    func testCurrentInfo_WithInvalidLicense_NoTrial_ReturnsTrialUp() {
        
        registrationStrategyDouble.testIsValid = false
        licenseProviderDouble.testLicense = irrelevantLicense
        
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        let trialIsUp: Bool
        switch licenseInfo {
        case .trialUp: trialIsUp = true
        default: trialIsUp = false
        }
        
        XCTAssert(trialIsUp)
    }
    
    func testCurrentInfo_WithInvalidLicense_OnTrial_ReturnsTrial() {
        
        // Given
        registrationStrategyDouble.testIsValid = false
        licenseProviderDouble.testLicense = irrelevantLicense

        let startDate = Date(timeIntervalSince1970: 1000)
        let endDate = Date(timeIntervalSince1970: 9999)
        let expectedPeriod = TrialPeriod(startDate: startDate, endDate: endDate)
        clockDouble.testDate = endDate.addingTimeInterval(-1000) // rewind before end date
        trialProviderDouble.testTrialPeriod = expectedPeriod
        
        // When
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        // Then
        switch licenseInfo {
        case let .onTrial(trialPeriod): XCTAssertEqual(trialPeriod, expectedPeriod)
        default: XCTFail("expected to be onTrial, got \(licenseInfo)")
        }
    }
    
    func testCurrentInfo_WithValidLicense_NoTrial_ReturnsRegisteredWithInfo() {
        
        registrationStrategyDouble.testIsValid = true
        let name = "a name"
        let licenseCode = "a license code"
        let license = License(name: name, licenseCode: licenseCode)
        licenseProviderDouble.testLicense = license
        
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        switch licenseInfo {
        case let .registered(foundLicense): XCTAssertEqual(foundLicense, license)
        default: XCTFail("expected .registered(_)")
        }
    }
    
    func testCurrentInfo_WithValidLicense_OnTrial_ReturnsRegistered() {
        
        // Given
        registrationStrategyDouble.testIsValid = true
        
        let endDate = Date()
        let expectedPeriod = TrialPeriod(startDate: Date(), endDate: endDate)
        clockDouble.testDate = endDate.addingTimeInterval(-1000)
        trialProviderDouble.testTrialPeriod = expectedPeriod
        
        let name = "a name"
        let licenseCode = "a license code"
        let license = License(name: name, licenseCode: licenseCode)
        licenseProviderDouble.testLicense = license
        
        // When
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        // Then
        switch licenseInfo {
        case let .registered(foundLicense): XCTAssertEqual(foundLicense, license)
        default: XCTFail("expected .registered(_)")
        }
    }
    
    func testCurrentInfo_WithValidLicense_PassedTrial_ReturnsRegistered() {
        
        // Given
        registrationStrategyDouble.testIsValid = true
        let endDate = Date()
        let expectedPeriod = TrialPeriod(startDate: Date(), endDate: endDate)
        clockDouble.testDate = endDate.addingTimeInterval(+9999)
        trialProviderDouble.testTrialPeriod = expectedPeriod
        
        let name = "a name"
        let licenseCode = "a license code"
        let license = License(name: name, licenseCode: licenseCode)
        licenseProviderDouble.testLicense = license
        
        // When
        let licenseInfo = licenseInfoProvider.currentLicenseInformation
        
        // Then
        switch licenseInfo {
        case let .registered(foundLicense): XCTAssertEqual(foundLicense, license)
        default: XCTFail("expected .registered(_)")
        }
    }
    
    
    // MARK: -
    
    class TestTrialProvider: ProvidesTrial {
        
        var testTrialPeriod: TrialPeriod?
        var currentTrialPeriod: TrialPeriod? {
            return testTrialPeriod
        }
    }
    
    class TestLicenseProvider: ProvidesLicense {
    
        var testLicense: License?
        var currentLicense: License? {
            return testLicense
        }
    }
    
    class TestClock: KnowsTimeAndDate {
        
        var testDate: Date!
        func now() -> Date {
            
            return testDate
        }
    }

    class TestRegistrationStrategy: RegistrationStrategy {

        var testIsValid = false
        func isValid(payload: RegistrationPayload, configuration: LicenseConfiguration, licenseVerifier: LicenseCodeVerification) -> Bool {
            return testIsValid
        }
    }

    class NullVerifier: LicenseVerifier {

        init() {
            super.init(configuration: LicenseConfiguration(appName: "irrelevant app name", publicKey: "irrelevant key"))
        }

        override func isValid(licenseCode: String, registrationName: String) -> Bool {
            return false
        }
    }
}
