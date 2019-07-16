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

        XCTAssertEqual(scheme.registrationName(appName: appName, payload: [:]),
                       "\(appName),")
        XCTAssertEqual(scheme.registrationName(appName: appName, payload: [.name : name]),
                       "\(appName),\(name)")
        XCTAssertEqual(scheme.registrationName(appName: appName, payload: [.licenseCode : "irrelevant"]),
                       "\(appName),")
        XCTAssertEqual(scheme.registrationName(appName: appName, payload: [.name : name, .licenseCode: "irrelevant"]),
                       "\(appName),\(name)")
    }

}
