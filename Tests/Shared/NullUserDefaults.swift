// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

open class NullUserDefaults: UserDefaults {

    open override func register(defaults registrationDictionary: [String : Any]) {  }
    open override func value(forKey key: String) -> Any? { return nil }
    open override func setValue(_ value: Any?, forKey key: String) {  }
}
