// Copyright (c) 2015-2019 Christian Tietze
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
    var registrationStrategyDouble: TestRegistrationStrategy!

    var configuration: LicenseConfiguration {
        return LicenseConfiguration(appName: "theAppName", publicKey: "irrelevant")
    }

    override func setUp() {
        
        super.setUp()

        verifierDouble = TestVerifier()
        writerDouble = TestWriter()
        licenseChangeCallback = LicenseChangeCallbackDouble()
        invalidLicenseCallback = InvalidLicenseCallbackDouble()
        informationProviderDouble = TestLicenseInformationProvider()
        trialProviderDouble = TestTrialProvider()
        registrationStrategyDouble = TestRegistrationStrategy()

        service = RegisterApplication(
            licenseVerifier: verifierDouble,
            licenseWriter: writerDouble,
            licenseInformationProvider: informationProviderDouble,
            trialProvider: trialProviderDouble,
            registrationStrategy: registrationStrategyDouble,
            configuration: configuration,
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
        registrationStrategyDouble = nil
        super.tearDown()
    }

    var irrelevantName: String { return "irrelevant" }
    var irrelevantLicenseCode: String { return "irrelevant" }
    var irrelevantLicense: License { return License(name: "irrelevant", licenseCode: "irrelevant") }
    var irrelevantTrialPeriod: TrialPeriod { return TrialPeriod(startDate: Date(timeIntervalSince1970: 1234), endDate: Date(timeIntervalSince1970: 9999)) }
    var irrelevantPayload: RegistrationPayload { return [.name : irrelevantName, .licenseCode: irrelevantLicenseCode]}


    // MARK: - Register

    func testRegister_VerifiesWithStrategy() {
        
        let name = "a name"
        let licenseCode = "123-456"
        
        service.register(payload: [.name : name, .licenseCode: licenseCode])

        XCTAssertNotNil(registrationStrategyDouble.didTestValidity)
        if let values = registrationStrategyDouble.didTestValidity {

            XCTAssertEqual(values.payload, [.name : name, .licenseCode: licenseCode])
            XCTAssert(values.licenseVerifier === verifierDouble)
            XCTAssertEqual(values.configuration, configuration)
        }
    }

    func testRegister_InvalidLicense_DoesntTryToStore() {
        
        registrationStrategyDouble.testIsValid = false
        
        service.register(payload: irrelevantPayload)
        
        XCTAssertNil(writerDouble.didStoreWith)
    }

    func testRegister_InvalidLicense_DoesntBroadcastChange() {
        
        verifierDouble.testValidity = false
        
        service.register(payload: irrelevantPayload)

        XCTAssertNil(licenseChangeCallback.didReceiveWith)
    }

    func testRegister_InvalidLicense_TriggersInvalidLicenseCallback() {

        let name = "the name"
        let licenseCode = "the code"
        registrationStrategyDouble.testIsValid = false

        service.register(payload: [.name : name, .licenseCode : licenseCode])

        XCTAssertEqual(invalidLicenseCallback.didReceivePayload, [.name : name, .licenseCode : licenseCode])
    }

    func testRegister_ValidLicense_DelegatesToStore() {
        
        let name = "It's Me"
        let licenseCode = "0900-ACME"
        registrationStrategyDouble.testIsValid = true

        service.register(payload: [.name : name, .licenseCode : licenseCode])

        XCTAssertNotNil(writerDouble.didStoreWith)
        if let values = writerDouble.didStoreWith {
            
            XCTAssertEqual(values.name, name)
            XCTAssertEqual(values.licenseCode, licenseCode)
        }
    }

    func testRegister_ValidLicense_BroadcastsChange() {
        
        let name = "Hello again"
        let licenseCode = "fr13nd-001"
        registrationStrategyDouble.testIsValid = true

        service.register(payload: [.name : name, .licenseCode : licenseCode])

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
    
    class TestWriter: WritesLicense {

        var didStoreWith: (licenseCode: String, name: String?)?
        func store(licenseCode: String, forName name: String?) {
            didStoreWith = (licenseCode, name)
        }

        var didRemove = false
        func removeLicense() {
            didRemove = true
        }
    }
    
    class TestVerifier: LicenseVerifier {
        
        init() {
            super.init(configuration: LicenseConfiguration(appName: "irrelevant app name", publicKey: "irrelevant key"))
        }
        
        var testValidity = false
        override func isValid(licenseCode: String, registrationName: String) -> Bool {
            return false
        }
    }

    class TestTrialProvider: ProvidesTrial {

        var testCurrentTrialPeriod: TrialPeriod? = nil
        var currentTrialPeriod: TrialPeriod? {
            return testCurrentTrialPeriod
        }

        var testCurrentTrial: Trial? = nil
        var didRequestCurrentTrial: KnowsTimeAndDate?
        func currentTrial(clock: KnowsTimeAndDate) -> Trial? {
            didRequestCurrentTrial = clock
            return testCurrentTrial
        }
    }

    class TestLicenseInformationProvider: ProvidesLicenseInformation {

        init() { }

        var testIsLicenseInvalid = false
        var isLicenseInvalid: Bool { return testIsLicenseInvalid }

        var testCurrentLicenseInformation: LicenseInformation = .trialUp
        var currentLicenseInformation: LicenseInformation { return testCurrentLicenseInformation }
    }

    class LicenseChangeCallbackDouble {
        
        var didReceiveWith: LicenseInformation?
        func receive(licenseInformation: LicenseInformation) {
            
            didReceiveWith = licenseInformation
        }
    }

    class InvalidLicenseCallbackDouble {

        var didReceivePayload: RegistrationPayload?
        func receive(payload: RegistrationPayload) {

            didReceivePayload = (payload)
        }
    }

    class TestRegistrationStrategy: RegistrationStrategy {

        var testIsValid = false
        var didTestValidity: (payload: RegistrationPayload, configuration: LicenseConfiguration, licenseVerifier: LicenseCodeVerification)?
        func isValid(payload: RegistrationPayload, configuration: LicenseConfiguration, licenseVerifier: LicenseCodeVerification) -> Bool {
            didTestValidity = (payload, configuration, licenseVerifier)
            return testIsValid
        }
    }
}
