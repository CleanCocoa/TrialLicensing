// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation
import Trial

public enum Events: String {
    
    case licenseChanged = "License Changed"

    public var notificationName: Notification.Name {
        return Notification.Name(rawValue: self.rawValue)
    }
}

open class LicenseChangeBroadcaster {
    
    let notificationCenter: NotificationCenter
    
    public init(notificationCenter: NotificationCenter) {
        
        self.notificationCenter = notificationCenter
    }
    
    open func broadcast(_ licenseInformation: LicenseInformation) {
        
        notificationCenter.post(name: Events.licenseChanged.notificationName, object: self, userInfo: licenseInformation.userInfo())
    }
}
