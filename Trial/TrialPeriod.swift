// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public struct TrialPeriod {
    
    public let startDate: Date
    public let endDate: Date
    
    public init(startDate aStartDate: Date, endDate anEndDate: Date) {
        
        startDate = aStartDate
        endDate = anEndDate
    }
    
    public init(numberOfDays daysLeft: Days, clock: KnowsTimeAndDate) {
        
        startDate = clock.now()
        endDate = startDate.addingTimeInterval(daysLeft.timeInterval)
    }
}

extension TrialPeriod {

    public func ended(clock: KnowsTimeAndDate) -> Bool {
        
        let now = clock.now()
        return endDate < now
    }
    
    public func daysLeft(clock: KnowsTimeAndDate) -> Days {
        
        let now = clock.now()
        let timeUntil = now.timeIntervalSince(endDate)
        
        return Days(timeInterval: timeUntil)
    }
}

extension TrialPeriod {
    
    enum UserDefaultsKeys: String, CustomStringConvertible {
        
        case startDate = "trial_starting"
        case endDate = "trial_ending"
        
        public var description: String { return rawValue }
    }
}

extension TrialPeriod: Equatable { }

public func ==(lhs: TrialPeriod, rhs: TrialPeriod) -> Bool {
    
    return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
}
