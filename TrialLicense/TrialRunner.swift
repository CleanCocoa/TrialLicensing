// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

class TrialRunner {

    let licenseChangeBroadcaster: LicenseChangeBroadcaster
    let trialProvider: TrialProvider

    init(licenseChangeBroadcaster: LicenseChangeBroadcaster, trialProvider: TrialProvider) {

        self.licenseChangeBroadcaster = licenseChangeBroadcaster
        self.trialProvider = trialProvider
    }

    fileprivate var trialTimer: TrialTimer?

    func startTrialTimer() {

        stopTrialTimer()

        guard let trialPeriod = trialProvider.currentTrialPeriod
            else { return }

        let trialTimer = TrialTimer(trialPeriod: trialPeriod) { [weak self] in
            self?.licenseChangeBroadcaster.broadcast(.trialUp)
        }
        trialTimer.start()
        self.trialTimer = trialTimer
    }

    func stopTrialTimer() {

        if let trialTimer = trialTimer, trialTimer.isRunning {

            trialTimer.stop()
        }
        
        self.trialTimer = nil
    }
}
