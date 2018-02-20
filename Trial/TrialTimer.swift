// Copyright (c) 2015-2018 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class TrialTimer {
    
    let trialEndDate: Date
    let trialExpirationBlock: () -> Void

    public convenience init(trialPeriod: TrialPeriod, trialExpirationBlock: @escaping () -> Void) {

        self.init(trialEndDate: trialPeriod.endDate, trialExpirationBlock: trialExpirationBlock)
    }

    public init(trialEndDate: Date, trialExpirationBlock: @escaping () -> Void) {
        
        self.trialEndDate = trialEndDate
        self.trialExpirationBlock = trialExpirationBlock
    }
    
    public var isRunning: Bool {
        
        return hasValue(delayedBlock)
    }
    
    var delayedBlock: CancelableDispatchBlock?
    
    public func start() {
        
        guard !isRunning else {
            assertionFailure("invalid re-starting of a running timer")
            return
        }
        
        guard let delayedBlock = dispatch(cancelableBlock: timerDidFire, atDate: trialEndDate) else {
            fatalError("Cannot create a cancellable timer.")
        }
        
//        NSLog("Starting trial timer for: \(trialEndDate)")
        self.delayedBlock = delayedBlock
    }
    
    fileprivate func timerDidFire() {
        
        trialExpirationBlock()
    }

    /// - note: Try to stop a non-running timer raises an assertion failure.
    public func stop() {
        
        guard isRunning else {
            assertionFailure("attempting to stop non-running timer")
            return
        }
        
        cancelBlock(delayedBlock)
    }
}
