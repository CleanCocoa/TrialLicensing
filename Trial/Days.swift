// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public struct Days {
    
    public static func timeInterval(amount: Double) -> TimeInterval {
        return amount * 60 * 60 * 24
    }
    
    public static func amount(timeInterval: TimeInterval) -> Double {
        return timeInterval / 60 / 60 / 24
    }
    
    public let amount: Double
    
    /// Rounded to the next integer.
    public var userFacingAmount: Int {
        
        return Int(ceil(amount))
    }
    
    public init(timeInterval: TimeInterval) {
        amount = fabs(Days.amount(timeInterval: timeInterval))
    }
    
    public init(_ anAmount: Double) {
        amount = anAmount
    }
    
    public var timeInterval: TimeInterval {
        return Days.timeInterval(amount: amount)
    }
    
    public var isPast: Bool {
        return amount < 0
    }
}

extension Days: CustomStringConvertible {
    
    public var description: String {
        return "\(amount)"
    }
}

extension Days: Equatable { }

public func ==(lhs: Days, rhs: Days) -> Bool {
    
    return lhs.amount == rhs.amount
}
