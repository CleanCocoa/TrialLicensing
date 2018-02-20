// Copyright (c) 2015-2018 Christian Tietze
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
