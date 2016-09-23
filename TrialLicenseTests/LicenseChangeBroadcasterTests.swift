// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Cocoa
import XCTest
@testable import TrialLicense
import Trial

fileprivate func ==(lhs: UserInfo, rhs: UserInfo) -> Bool {
    
    if lhs.count != rhs.count { return false }
    
    return lhs["registered"] as? Bool == rhs["registered"] as? Bool
        && lhs["name"] as? String == rhs["name"] as? String
        && lhs["licenseCode"] as? String == rhs["licenseCode"] as? String
}

class LicenseChangeBroadcasterTests: XCTestCase {

    var broadcaster: LicenseChangeBroadcaster!
    let notificationCenterDouble = TestNotificationCenter()
    
    override func setUp() {
        
        super.setUp()
        
        broadcaster = LicenseChangeBroadcaster(notificationCenter: notificationCenterDouble)
    }
    
    func testBroadcast_TrialUp_PostsNotification() {
        
        let licenseInfo = LicenseInformation.trialUp
        
        broadcaster.broadcast(licenseInfo)
        
        let values = notificationCenterDouble.didPostNotificationNameWith
        XCTAssert(hasValue(values))
        
        if let values = values {
            XCTAssertEqual(values.name, Events.licenseChanged.notificationName)
            XCTAssert(values.object as? LicenseChangeBroadcaster === broadcaster)
            
            XCTAssert(hasValue(values.userInfo))
            if let userInfo = values.userInfo {
                XCTAssert(userInfo == licenseInfo.userInfo())
            }
        }
    }
    
    func testBroadcast_OnTrial_PostsNotification() {
        
        let licenseInfo = LicenseInformation.onTrial(TrialPeriod(startDate: Date(), endDate: Date()))
        
        broadcaster.broadcast(licenseInfo)
        
        let values = notificationCenterDouble.didPostNotificationNameWith
        XCTAssert(hasValue(values))
        
        if let values = values {
            XCTAssertEqual(values.name, Events.licenseChanged.notificationName)
            XCTAssert(values.object as? LicenseChangeBroadcaster === broadcaster)
            
            XCTAssert(hasValue(values.userInfo))
            if let userInfo = values.userInfo {
                XCTAssert(userInfo == licenseInfo.userInfo())
            }
        }
    }

    func testBroadcast_Registered_PostsNotification() {
        
        let licenseInfo = LicenseInformation.registered(License(name: "the name", licenseCode: "a license"))
        
        broadcaster.broadcast(licenseInfo)
        
        let values = notificationCenterDouble.didPostNotificationNameWith
        XCTAssert(hasValue(values))
        
        if let values = values {
            XCTAssertEqual(values.name, Events.licenseChanged.notificationName)
            XCTAssert(values.object as? LicenseChangeBroadcaster === broadcaster)
            
            XCTAssert(hasValue(values.userInfo))
            if let userInfo = values.userInfo {
                XCTAssert(userInfo == licenseInfo.userInfo())
            }
        }
    }
    
    
    // MARK: -
    
    class TestNotificationCenter: NullNotificationCenter {
        
        var didPostNotificationNameWith: (name: Notification.Name, object: Any?, userInfo: UserInfo?)?
        override func post(name aName: Notification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable: Any]?) {
            
            didPostNotificationNameWith = (aName, anObject, aUserInfo)
        }
    }
}
