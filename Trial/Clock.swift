// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public protocol KnowsTimeAndDate: class {
    
    func now() -> Date
}

public class Clock: KnowsTimeAndDate {
    
    public init() { }
    
    public func now() -> Date {
        
        return Date()
    }
}

public class StaticClock: KnowsTimeAndDate {
    
    let date: Date
    
    public init(clockDate: Date) {
        
        date = clockDate
    }
    
    public func now() -> Date {
        
        return date
    }
}
