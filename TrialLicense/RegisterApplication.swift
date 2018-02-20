// Copyright (c) 2015-2018 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

/// Implemented by `RegisterApplication`; use this for delegates
/// or view controller callbacks.
public protocol HandlesRegistering: class {

    func register(name: String, licenseCode: String)
    func unregister()
}

class RegisterApplication: HandlesRegistering {

    let licenseVerifier: LicenseVerifier
    let licenseWriter: LicenseWriter
    let licenseInformationProvider: LicenseInformationProvider
    let trialProvider: TrialProvider

    let licenseChangeCallback: LicenseChangeCallback

    typealias InvalidLicenseCallback = (_ name: String, _ licenseCode: String) -> Void
    let invalidLicenseCallback: InvalidLicenseCallback

    init(licenseVerifier: LicenseVerifier,
         licenseWriter: LicenseWriter,
         licenseInformationProvider: LicenseInformationProvider,
         trialProvider: TrialProvider,
         licenseChangeCallback: @escaping LicenseChangeCallback,
         invalidLicenseCallback: @escaping InvalidLicenseCallback) {

        self.licenseVerifier = licenseVerifier
        self.licenseWriter = licenseWriter
        self.licenseInformationProvider = licenseInformationProvider
        self.trialProvider = trialProvider
        self.licenseChangeCallback = licenseChangeCallback
        self.invalidLicenseCallback = invalidLicenseCallback
    }

    func register(name: String, licenseCode: String) {

        guard licenseVerifier.isValid(licenseCode: licenseCode, forName: name) else {

            invalidLicenseCallback(name, licenseCode)
            return
        }

        let license = License(name: name, licenseCode: licenseCode)
        let licenseInformation = LicenseInformation.registered(license)

        licenseWriter.store(license: license)
        licenseChangeCallback(licenseInformation)
    }

    func unregister() {

        let currentLicenseInformation = licenseInformationProvider.currentLicenseInformation

        licenseWriter.removeLicense()

        // Pass through when there was no registration info.
        guard case .registered = currentLicenseInformation else { return }

        guard let trialPeriod = trialProvider.currentTrialPeriod else {
            licenseChangeCallback(.trialUp)
            return
        }

        licenseChangeCallback(.onTrial(trialPeriod))
    }
}
