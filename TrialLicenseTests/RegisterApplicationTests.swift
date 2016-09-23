// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense

class RegisterApplicationTests: XCTestCase {

    var service: RegisterApplication!

    let verifierDouble = TestVerifier()
    let writerDouble = TestWriter()
    let broadcasterDouble = TestBroadcaster()
    let invalidLicenseCallback = InvalidLicenseCallback()

    override func setUp() {
        
        super.setUp()
        
        service = RegisterApplication(licenseVerifier: verifierDouble, licenseWriter: writerDouble, changeBroadcaster: broadcasterDouble, invalidLicenseCallback: invalidLicenseCallback.receive)
    }
    
    let irrelevantName = "irrelevant"
    let irrelevantLicenseCode = "irrelevant"
    
    func testRegister_DelegatesToVerifier() {
        
        let name = "a name"
        let licenseCode = "123-456"
        
        service.register(name: name, licenseCode: licenseCode)
        
        XCTAssert(hasValue(verifierDouble.didCallIsValidWith))
        if let values = verifierDouble.didCallIsValidWith {
            
            XCTAssertEqual(values.name, name)
            XCTAssertEqual(values.licenseCode, licenseCode)
        }
    }
    
    func testRegister_InvalidLicense_DoesntTryToStore() {
        
        verifierDouble.testValidity = false
        
        service.register(name: irrelevantName, licenseCode: irrelevantLicenseCode)
        
        XCTAssertFalse(hasValue(writerDouble.didStoreWith))
    }
    
    func testRegister_InvalidLicense_DoesntBroadcastChange() {
        
        verifierDouble.testValidity = false
        
        service.register(name: irrelevantName, licenseCode: irrelevantLicenseCode)
        
        XCTAssertFalse(hasValue(broadcasterDouble.didBroadcastWith))
    }
    
    func testRegister_ValidLicense_DelegatesToStore() {
        
        let name = "It's Me"
        let licenseCode = "0900-ACME"
        verifierDouble.testValidity = true
        
        service.register(name: name, licenseCode: licenseCode)
        
        XCTAssert(hasValue(writerDouble.didStoreWith))
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
        
        XCTAssert(hasValue(broadcasterDouble.didBroadcastWith))
        if let licenseInfo = broadcasterDouble.didBroadcastWith {
            
            switch licenseInfo {
            case let .registered(license):
                XCTAssertEqual(license.name, name)
                XCTAssertEqual(license.licenseCode, licenseCode)
            default: XCTFail("should be registered")
            }
        }
    }


    // MARK: -
    
    class TestWriter: LicenseWriter {
        
        var didStoreWith: (licenseCode: String, name: String)?
        override func store(licenseCode: String, forName name: String) {
            
            didStoreWith = (licenseCode, name)
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
    
    class TestBroadcaster: LicenseChangeBroadcaster {
        
        convenience init() {
            
            self.init(notificationCenter: NullNotificationCenter())
        }
        
        var didBroadcastWith: LicenseInformation?
        override func broadcast(_ licenseInformation: LicenseInformation) {
            
            didBroadcastWith = licenseInformation
        }
    }

    class InvalidLicenseCallback {

        var didReceiveWith: (name: String, licenseCode: String)?
        func receive(name: String, licenseCode: String) {

            didReceiveWith = (name, licenseCode)
        }
    }
}
