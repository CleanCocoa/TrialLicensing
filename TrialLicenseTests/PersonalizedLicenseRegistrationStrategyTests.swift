// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense

class PersonalizedLicenseRegistrationStrategyTests: XCTestCase {

    var verifierDouble: TestVerifier!

    override func setUp() {
        super.setUp()
        verifierDouble = TestVerifier()
    }

    override func tearDown() {
        verifierDouble = nil
        super.tearDown()
    }


    // MARK: -

    func testIsValid_PassesDataToVerifier() {

        let appName = "AmazingAppName2000"
        let name = "a person"
        let licenseCode = "supposed to be a license code"
        let payload = RegistrationPayload(name: name, licenseCode: licenseCode)

        _ = PersonalizedLicenseRegistrationStrategy().isValid(
            payload: payload,
            configuration: LicenseConfiguration(appName: appName, publicKey: "irrelevant"),
            licenseVerifier: verifierDouble)

        XCTAssertNotNil(verifierDouble.didCallIsValidWith)
        if let values = verifierDouble.didCallIsValidWith {
            let expectedRegistrationName = LicensingScheme.personalizedLicense.registrationName(appName: appName, payload: payload)
            XCTAssertEqual(values.registrationName, expectedRegistrationName)
            XCTAssertEqual(values.licenseCode, licenseCode)
        }
    }

    func testIsValid_ReturnsVerifierResult() {

        let irrelevantPayload = RegistrationPayload(name: "irrelevant", licenseCode: "irrelevant")
        let irrelevantConfiguration = LicenseConfiguration(appName: "irrelevant", publicKey: "irrelevant")

        verifierDouble.testValidity = true
        XCTAssertTrue(PersonalizedLicenseRegistrationStrategy().isValid(
            payload: irrelevantPayload,
            configuration: irrelevantConfiguration,
            licenseVerifier: verifierDouble))

        verifierDouble.testValidity = false
        XCTAssertFalse(PersonalizedLicenseRegistrationStrategy().isValid(
            payload: irrelevantPayload,
            configuration: irrelevantConfiguration,
            licenseVerifier: verifierDouble))
    }


    // MARK: -

    class TestVerifier: LicenseVerifier {

        init() {
            super.init(configuration: LicenseConfiguration(appName: "irrelevant app name", publicKey: "irrelevant key"))
        }

        var testValidity = false
        var didCallIsValidWith: (licenseCode: String, registrationName: String)?
        override func isValid(licenseCode: String, registrationName: String) -> Bool {

            didCallIsValidWith = (licenseCode, registrationName)

            return testValidity
        }
    }
}
