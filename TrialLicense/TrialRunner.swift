// Copyright (c) 2015-2018 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

class TrialRunner {

    let licenseChangeCallback: LicenseChangeCallback
    let trialProvider: TrialProvider

    init(trialProvider: TrialProvider, licenseChangeCallback: @escaping LicenseChangeCallback) {

        self.licenseChangeCallback = licenseChangeCallback
        self.trialProvider = trialProvider
    }

    fileprivate var trialTimer: TrialTimer?

    func startTrialTimer() {

        stopTrialTimer()

        guard let trialPeriod = trialProvider.currentTrialPeriod
            else { return }

        let trialTimer = TrialTimer(trialPeriod: trialPeriod) { [weak self] in
            self?.licenseChangeCallback(.trialUp)
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
