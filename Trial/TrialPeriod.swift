// Copyright (c) 2015-2018 Christian Tietze
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

    public func ended(clock: KnowsTimeAndDate = Clock()) -> Bool {
        
        let now = clock.now()
        return endDate < now
    }

    public func userFacingDaysLeft(clock: KnowsTimeAndDate = Clock()) -> Int {

        return daysLeft(clock: clock).userFacingAmount
    }

    public func daysLeft(clock: KnowsTimeAndDate = Clock()) -> Days {
        
        let now = clock.now()
        let timeUntil = now.timeIntervalSince(endDate)
        
        return Days(timeInterval: timeUntil)
    }
}

extension TrialPeriod {
    
    public enum UserDefaultsKeys {
        
        public static let startDate = "trial_starting"
        public static let endDate = "trial_ending"
    }
}

extension TrialPeriod: Equatable { }

public func ==(lhs: TrialPeriod, rhs: TrialPeriod) -> Bool {
    
    return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate
}
