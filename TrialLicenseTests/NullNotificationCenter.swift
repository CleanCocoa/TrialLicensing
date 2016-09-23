// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

class NullNotificationCenter: NotificationCenter {

    override class var `default`: NotificationCenter {
        return NullNotificationCenter()
    }

    override func addObserver(forName name: Notification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {

        return NSObject()
    }

    override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: Notification.Name?, object anObject: Any?) {  }

    override func removeObserver(_ observer: Any) { }
    override func removeObserver(_ observer: Any, name aName: Notification.Name?, object anObject: Any?) { }

    override func post(_ notification: Notification) { }
    override func post(name aName: Notification.Name, object anObject: Any?) { }
    override func post(name aName: Notification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable: Any]?) { }
}
