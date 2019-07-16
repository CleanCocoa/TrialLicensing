// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense

class LicensingSchemeTests: XCTestCase {

    func testPersonalizedRegistrationName() {
        let appName = "foobar"
        let name = "person"
        let scheme = LicensingScheme.personalizedLicense

        XCTAssertEqual(
            "\(appName),\(name)",
            scheme.registrationName(
                appName: appName,
                payload: RegistrationPayload(name: name, licenseCode: "irrelevant")))
        XCTAssertEqual(
            "\(appName),",
            scheme.registrationName(
                appName: appName,
                payload: RegistrationPayload(licenseCode: "irrelevant")))
    }

    func testGenericRegistrationName() {
        let appName = "foobar"
        let scheme = LicensingScheme.generic

        XCTAssertEqual(
            "\(appName)",
            scheme.registrationName(
                appName: appName,
                payload: RegistrationPayload(name: "irrelevant", licenseCode: "irrelevant")))
        XCTAssertEqual(
            "\(appName)",
            scheme.registrationName(
                appName: appName,
                payload: RegistrationPayload(licenseCode: "irrelevant")))
    }

}
