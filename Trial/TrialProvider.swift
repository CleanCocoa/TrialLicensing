// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

open class TrialProvider {
    
    public init() { }
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard

    public var isConfigured: Bool { return hasValue(currentTrialPeriod) }

    open var currentTrialPeriod: TrialPeriod? {
        
        if let startDate = userDefaults.object(forKey: TrialPeriod.UserDefaultsKeys.startDate) as? Date,
            let endDate = userDefaults.object(forKey: TrialPeriod.UserDefaultsKeys.endDate) as? Date {
                
            return TrialPeriod(startDate: startDate, endDate: endDate)
        }
        
        return .none
    }
    
    open func currentTrial(clock: KnowsTimeAndDate) -> Trial? {
        
        if let trialPeriod = currentTrialPeriod {
            
            return Trial(trialPeriod: trialPeriod, clock: clock)
        }
        
        return .none
    }
}
