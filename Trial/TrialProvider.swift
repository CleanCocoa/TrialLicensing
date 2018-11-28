// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

open class TrialProvider {

    let trialReader: ReadsTrialPeriod

    public init(trialReader: ReadsTrialPeriod = UserDefaultsTrialPeriodReader()) {
        self.trialReader = trialReader
    }

    public var isConfigured: Bool { return hasValue(currentTrialPeriod) }

    open var currentTrialPeriod: TrialPeriod? {
        return trialReader.currentTrialPeriod
    }
    
    open func currentTrial(clock: KnowsTimeAndDate) -> Trial? {
        guard let trialPeriod = currentTrialPeriod else { return nil }
        return Trial(trialPeriod: trialPeriod, clock: clock)
    }
}
