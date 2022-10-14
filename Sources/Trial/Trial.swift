// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public struct Trial {
    
    public let trialPeriod: TrialPeriod
    public let clock: KnowsTimeAndDate
    
    public init(trialPeriod: TrialPeriod, clock: KnowsTimeAndDate) {
        
        self.trialPeriod = trialPeriod
        self.clock = clock
    }
    
    public var daysLeft: Int {
        return trialPeriod.daysLeft(clock: clock).userFacingAmount
    }
    
    public var ended: Bool {
        return trialPeriod.ended(clock: clock)
    }
    
    public var isActive: Bool {
        return !ended
    }
}
