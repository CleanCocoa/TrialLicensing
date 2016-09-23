// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class TrialTimer {
    
    let trialEndDate: Date
    let trialExpirationBlock: () -> Void
    
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
    
    public func stop() {
        
        guard isRunning else {
            assertionFailure("attempting to stop non-running timer")
            return
        }
        
        cancelBlock(delayedBlock)
    }
}
