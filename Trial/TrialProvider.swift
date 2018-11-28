// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

public protocol ProvidesTrial {
    var currentTrialPeriod: TrialPeriod? { get }
    func currentTrial(clock: KnowsTimeAndDate) -> Trial?
}

open class TrialProvider: ProvidesTrial {

    let trialPeriodReader: ReadsTrialPeriod

    public init(trialPeriodReader: ReadsTrialPeriod) {
        self.trialPeriodReader = trialPeriodReader
    }

    open var currentTrialPeriod: TrialPeriod? {
        return trialPeriodReader.currentTrialPeriod
    }
    
    open func currentTrial(clock: KnowsTimeAndDate) -> Trial? {
        guard let trialPeriod = currentTrialPeriod else { return nil }
        return Trial(trialPeriod: trialPeriod, clock: clock)
    }
}
