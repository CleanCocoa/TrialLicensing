// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public protocol ReadsTrialPeriod {
    /// `Nil` when the info couldn't be found; a `TrialPeriod` of the source otherwise.
    var currentTrialPeriod: TrialPeriod? { get }
}

open class UserDefaultsTrialPeriodReader: ReadsTrialPeriod {

    public let startDateKey: String
    public let endDateKey: String
    public let userDefaults: UserDefaults

    public init(startDateKey: String = TrialPeriod.UserDefaultsKeys.startDate,
                endDateKey: String = TrialPeriod.UserDefaultsKeys.endDate,
                userDefaults: UserDefaults) {
        self.startDateKey = startDateKey
        self.endDateKey = endDateKey
        self.userDefaults = userDefaults
    }

    open var isConfigured: Bool { currentTrialPeriod != nil }
    
    open var currentTrialPeriod: TrialPeriod? {
        guard let startDate = userDefaults.object(forKey: TrialPeriod.UserDefaultsKeys.startDate) as? Date,
              let endDate = userDefaults.object(forKey: TrialPeriod.UserDefaultsKeys.endDate) as? Date
        else { return nil }

        return TrialPeriod(startDate: startDate, endDate: endDate)
    }
}
