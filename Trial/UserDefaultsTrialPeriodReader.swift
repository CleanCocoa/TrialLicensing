// Copyright (c) 2015-2018 Christian Tietze
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

    public init(startDateKey: String = TrialPeriod.UserDefaultsKeys.startDate,
                endDateKey: String = TrialPeriod.UserDefaultsKeys.endDate) {
        self.startDateKey = startDateKey
        self.endDateKey = endDateKey
    }

    open lazy var userDefaults: UserDefaults = UserDefaults.standard

    open var currentTrialPeriod: TrialPeriod? {
        guard let startDate = userDefaults.object(forKey: TrialPeriod.UserDefaultsKeys.startDate) as? Date else { return nil }
        guard let endDate = userDefaults.object(forKey: TrialPeriod.UserDefaultsKeys.endDate) as? Date else { return nil }

        return TrialPeriod(startDate: startDate, endDate: endDate)
    }
}
