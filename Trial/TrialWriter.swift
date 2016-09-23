// Copyright (c) 2015-2016 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

class TrialWriter {
    
    init() { }
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    
    func store(trialPeriod: TrialPeriod) {
        
        userDefaults.set(trialPeriod.startDate, forKey: TrialPeriod.UserDefaultsKeys.startDate)
        userDefaults.set(trialPeriod.endDate, forKey: TrialPeriod.UserDefaultsKeys.endDate)
    }
}
