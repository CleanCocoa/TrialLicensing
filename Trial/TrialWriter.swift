// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public class TrialWriter {
    
    public init() { }
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    
    public func store(trialPeriod: TrialPeriod) {
        
        userDefaults.set(trialPeriod.startDate, forKey: TrialPeriod.UserDefaultsKeys.startDate)
        userDefaults.set(trialPeriod.endDate, forKey: TrialPeriod.UserDefaultsKeys.endDate)
    }
}
