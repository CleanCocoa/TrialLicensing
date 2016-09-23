// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

typealias CancelableDispatchBlock = (_ cancel: Bool) -> Void

func dispatch(cancelableBlock block: @escaping () -> Void, atDate date: Date) -> CancelableDispatchBlock? {
    
    // Use two pointers for the same block handle to make
    // the block reference itself.
    var cancelableBlock: CancelableDispatchBlock? = nil
    
    let delayBlock: CancelableDispatchBlock = { cancel in
        
        if !cancel {
            DispatchQueue.main.async(execute: block)
        }
        
        cancelableBlock = nil
    }
    
    cancelableBlock = delayBlock
    
    let delay = Int(date.timeIntervalSinceNow)
    DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + .seconds(delay)) {
        
        guard case let .some(cancelableBlock) = cancelableBlock else { return }

        cancelableBlock(false)
    }
    
    return cancelableBlock
}

func cancelBlock(_ block: CancelableDispatchBlock?) {
    
    guard case let .some(block) = block else { return }

    block(true)
}

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
            NSLog("invalid re-starting of a running timer")
            return
        }
        
        guard let delayedBlock = dispatch(cancelableBlock: timerDidFire, atDate: trialEndDate) else {
            fatalError("Cannot create a cancellable timer.")
        }
        
        NSLog("Starting trial timer for: \(trialEndDate)")
        self.delayedBlock = delayedBlock
    }
    
    fileprivate func timerDidFire() {
        
        trialExpirationBlock()
    }
    
    public func stop() {
        
        guard isRunning else {
            NSLog("attempting to stop non-running timer")
            return
        }
        
        cancelBlock(delayedBlock)
    }
}
