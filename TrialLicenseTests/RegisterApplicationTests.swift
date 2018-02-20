// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense
import Trial

class RegisterApplicationTests: XCTestCase {

    var service: RegisterApplication!

    var verifierDouble: TestVerifier!
    var writerDouble: TestWriter!
    var licenseChangeCallback: LicenseChangeCallbackDouble!
    var invalidLicenseCallback: InvalidLicenseCallbackDouble!
    var informationProviderDouble: TestLicenseInformationProvider!
    var trialProviderDouble: TestTrialProvider!

    override func setUp() {
        
        super.setUp()

        verifierDouble = TestVerifier()
        writerDouble = TestWriter()
        licenseChangeCallback = LicenseChangeCallbackDouble()
        invalidLicenseCallback = InvalidLicenseCallbackDouble()
        informationProviderDouble = TestLicenseInformationProvider()
        trialProviderDouble = TestTrialProvider()

        service = RegisterApplication(
            licenseVerifier: verifierDouble,
            licenseWriter: writerDouble,
            licenseInformationProvider: informationProviderDouble,
            trialProvider: trialProviderDouble,
            licenseChangeCallback: licenseChangeCallback.receive,
            invalidLicenseCallback: invalidLicenseCallback.receive)
    }

    override func tearDown() {
        service = nil
        verifierDouble = nil
        writerDouble = nil
        licenseChangeCallback = nil
        invalidLicenseCallback = nil
        informationProviderDouble = nil
        trialProviderDouble = nil
        super.tearDown()
    }

    var irrelevantName: String { return "irrelevant" }
    var irrelevantLicenseCode: String { return "irrelevant" }
    var irrelevantLicense: License { return License(name: "irrelevant", licenseCode: "irrelevant") }
    var irrelevantTrialPeriod: TrialPeriod { return TrialPeriod(startDate: Date(timeIntervalSince1970: 1234), endDate: Date(timeIntervalSince1970: 9999)) }


    // MARK: - Register

    func testRegister_DelegatesToVerifier() {
        
        let name = "a name"
        let licenseCode = "123-456"
        
        service.register(name: name, licenseCode: licenseCode)
        
        XCTAssertNotNil(verifierDouble.didCallIsValidWith)
        if let values = verifierDouble.didCallIsValidWith {
            
            XCTAssertEqual(values.name, name)
            XCTAssertEqual(values.licenseCode, licenseCode)
        }
    }

    func testRegister_InvalidLicense_DoesntTryToStore() {
        
        verifierDouble.testValidity = false
        
        service.register(name: irrelevantName, licenseCode: irrelevantLicenseCode)
        
        XCTAssertNil(writerDouble.didStoreWith)
    }

    func testRegister_InvalidLicense_DoesntBroadcastChange() {
        
        verifierDouble.testValidity = false
        
        service.register(name: irrelevantName, licenseCode: irrelevantLicenseCode)
        
        XCTAssertNil(licenseChangeCallback.didReceiveWith)
    }

    func testRegister_InvalidLicense_TriggersInvalidLicenseCallback() {

        let name = "the name"
        let licenseCode = "the code"
        verifierDouble.testValidity = false

        service.register(name: name, licenseCode: licenseCode)

        XCTAssertNotNil(invalidLicenseCallback.didReceiveWith)
        if let values = invalidLicenseCallback.didReceiveWith {
            XCTAssertEqual(values.name, name)
            XCTAssertEqual(values.licenseCode, licenseCode)
        }
    }

    func testRegister_ValidLicense_DelegatesToStore() {
        
        let name = "It's Me"
        let licenseCode = "0900-ACME"
        verifierDouble.testValidity = true
        
        service.register(name: name, licenseCode: licenseCode)
        
        XCTAssertNotNil(writerDouble.didStoreWith)
        if let values = writerDouble.didStoreWith {
            
            XCTAssertEqual(values.name, name)
            XCTAssertEqual(values.licenseCode, licenseCode)
        }
    }

    func testRegister_ValidLicense_BroadcastsChange() {
        
        let name = "Hello again"
        let licenseCode = "fr13nd-001"
        verifierDouble.testValidity = true
        
        service.register(name: name, licenseCode: licenseCode)
        
        XCTAssertNotNil(licenseChangeCallback.didReceiveWith)
        if let licenseInfo = licenseChangeCallback.didReceiveWith {
            
            switch licenseInfo {
            case let .registered(license):
                XCTAssertEqual(license.name, name)
                XCTAssertEqual(license.licenseCode, licenseCode)
            default: XCTFail("should be registered")
            }
        }
    }


    // MARK: Unregister

    func testUnregister_CurrentlyRegistered_RemovesLicenseFromWriter() {

        informationProviderDouble.testCurrentLicenseInformation = .registered(irrelevantLicense)

        service.unregister()

        XCTAssert(writerDouble.didRemove)
    }

    func testUnregister_CurrentlyRegistered_TrialIsUp_InvokesCallback() {

        informationProviderDouble.testCurrentLicenseInformation = .registered(irrelevantLicense)
        trialProviderDouble.testCurrentTrialPeriod = nil

        service.unregister()

        XCTAssertEqual(licenseChangeCallback.didReceiveWith, LicenseInformation.trialUp)
    }

    func testUnregister_CurrentlyRegistered_TrialDaysLeft_InvokesCallback() {

        informationProviderDouble.testCurrentLicenseInformation = .registered(irrelevantLicense)
        let trialPeriod = TrialPeriod(startDate: Date(timeIntervalSinceReferenceDate: -100), endDate: Date(timeIntervalSinceReferenceDate: 200))
        trialProviderDouble.testCurrentTrialPeriod = trialPeriod

        service.unregister()

        XCTAssertEqual(licenseChangeCallback.didReceiveWith, LicenseInformation.onTrial(trialPeriod))
    }

    func testUnregister_CurrentlyOnTrial_RemovesLicenseFromWriter() {

        informationProviderDouble.testCurrentLicenseInformation = .onTrial(irrelevantTrialPeriod)

        service.unregister()

        XCTAssert(writerDouble.didRemove)
    }

    func testUnregister_CurrentlyOnTrial_DoesNotInvokeCallback() {

        informationProviderDouble.testCurrentLicenseInformation = .onTrial(irrelevantTrialPeriod)

        service.unregister()

        XCTAssertNil(licenseChangeCallback.didReceiveWith)
    }

    func testUnregister_CurrentlyTrialIsUp_RemovesLicenseFromWriter() {

        informationProviderDouble.testCurrentLicenseInformation = .trialUp

        service.unregister()

        XCTAssert(writerDouble.didRemove)
    }

    func testUnregister_CurrentlyTrialIsUp_DoesNotInvokeCallback() {

        informationProviderDouble.testCurrentLicenseInformation = .trialUp

        service.unregister()

        XCTAssertNil(licenseChangeCallback.didReceiveWith)
    }


    // MARK: -
    
    class TestWriter: LicenseWriter {
        
        var didStoreWith: (licenseCode: String, name: String)?
        override func store(licenseCode: String, forName name: String) {
            
            didStoreWith = (licenseCode, name)
        }

        var didRemove = false
        override func removeLicense() {
            didRemove = true
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

    class TestTrialProvider: TrialProvider {

        var testCurrentTrialPeriod: TrialPeriod? = nil
        override var currentTrialPeriod: TrialPeriod? {
            return testCurrentTrialPeriod
        }

        var testCurrentTrial: Trial? = nil
        var didRequestCurrentTrial: KnowsTimeAndDate?
        override func currentTrial(clock: KnowsTimeAndDate) -> Trial? {
            didRequestCurrentTrial = clock
            return testCurrentTrial
        }
    }

    class TestLicenseInformationProvider: LicenseInformationProvider {

        convenience init() {
            self.init(configuration: LicenseConfiguration.init(appName: "irrelevant", publicKey: "irrelevant"))
        }

        var testIsLicenseInvalid = false
        override var isLicenseInvalid: Bool { return testIsLicenseInvalid }

        var testCurrentLicenseInformation: LicenseInformation = .trialUp
        override var currentLicenseInformation: LicenseInformation { return testCurrentLicenseInformation }
    }

    class LicenseChangeCallbackDouble {
        
        var didReceiveWith: LicenseInformation?
        func receive(licenseInformation: LicenseInformation) {
            
            didReceiveWith = licenseInformation
        }
    }

    class InvalidLicenseCallbackDouble {

        var didReceiveWith: (name: String, licenseCode: String)?
        func receive(name: String, licenseCode: String) {

            didReceiveWith = (name, licenseCode)
        }
    }
}
