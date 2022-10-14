// Copyright (c) 2015-2019 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public class TrialWriter {

    public let userDefaults: UserDefaults

    public init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public func store(trialPeriod: TrialPeriod) {
        
        userDefaults.set(trialPeriod.startDate, forKey: TrialPeriod.UserDefaultsKeys.startDate)
        userDefaults.set(trialPeriod.endDate, forKey: TrialPeriod.UserDefaultsKeys.endDate)
    }
}
