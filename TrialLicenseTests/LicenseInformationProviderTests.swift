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
    var verifierDouble: TestVerifier!
    
    override func setUp() {
        super.setUp()

        trialProviderDouble = TestTrialProvider()
        licenseProviderDouble = TestLicenseProvider()
        clockDouble = TestClock()
        verifierDouble = TestVerifier()
        
        licenseInfoProvider = LicenseInformationProvider(
            trialProvider: trialProviderDouble,
            licenseProvider: licenseProviderDouble,
            licenseVerifier: verifierDouble,
            clock: clockDouble)
    }

    override func tearDown() {
        trialProviderDouble = nil
        licenseProviderDouble = nil
        clockDouble = nil
        verifierDouble = nil
        licenseInfoProvider = nil
        super.tearDown()
    }
    
    let irrelevantLicense = License(name: "", licenseCode: "")

    func testLicenceInvalidity_NoLicense_ReturnsFalse() {
        
        XCTAssertFalse(licenseInfoProvider.isLicenseInvalid)
    }
    
    func testLicenceInvalidity_ValidLicense_ReturnsFalse() {
        
        verifierDouble.testValidity = true
        licenseProviderDouble.testLicense = irrelevantLicense
        
        XCTAssertFalse(licenseInfoProvider.isLicenseInvalid)
    }
    
    func testLicenceInvalidity_InvalidLicense_ReturnsFalse() {
        
        verifierDouble.testValidity = false
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
        
        verifierDouble.testValidity = false
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
        verifierDouble.testValidity = false
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
        
        verifierDouble.testValidity = true
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
        verifierDouble.testValidity = true
        
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
        verifierDouble.testValidity = true
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
    
    class TestVerifier: LicenseVerifier {
        
        init() {
            super.init(configuration: LicenseConfiguration(appName: "irrelevant app name", publicKey: "irrelevant key"))
        }
        
        var testValidity = false
        var didCallIsValidWith: (licenseCode: String, name: String)?
        override func isValid(licenseCode: String, forName name: String) -> Bool {
            
            didCallIsValidWith = (licenseCode, name)
            
            return testValidity
        }
    }
}
