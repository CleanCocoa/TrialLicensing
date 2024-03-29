// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

/// Implemented by `RegisterApplication`; use this for delegates
/// or view controller callbacks.
public protocol HandlesRegistering: AnyObject {

    func register(payload: RegistrationPayload)
    func unregister()
}

protocol RegistrationStrategy {
    func isValid(payload: RegistrationPayload, configuration: LicenseConfiguration, licenseVerifier: LicenseCodeVerification) -> Bool
}

public protocol WritesLicense {
    func store(license: License)
    func store(licenseCode: String, forName name: String?)
    func removeLicense()
}

extension WritesLicense {
    func store(license: License) {
        self.store(licenseCode: license.licenseCode, forName: license.name)
    }
}

class RegisterApplication: HandlesRegistering {

    let licenseVerifier: LicenseVerifier
    let licenseWriter: WritesLicense
    let licenseInformationProvider: ProvidesLicenseInformation
    let trialProvider: ProvidesTrial
    let registrationStrategy: RegistrationStrategy
    let configuration: LicenseConfiguration

    let licenseChangeCallback: LicenseChangeCallback

    typealias InvalidLicenseCallback = (_ payload: RegistrationPayload) -> Void
    let invalidLicenseCallback: InvalidLicenseCallback

    init(licenseVerifier: LicenseVerifier,
         licenseWriter: WritesLicense,
         licenseInformationProvider: ProvidesLicenseInformation,
         trialProvider: ProvidesTrial,
         registrationStrategy: RegistrationStrategy,
         configuration: LicenseConfiguration,
         licenseChangeCallback: @escaping LicenseChangeCallback,
         invalidLicenseCallback: @escaping InvalidLicenseCallback) {

        self.licenseVerifier = licenseVerifier
        self.licenseWriter = licenseWriter
        self.licenseInformationProvider = licenseInformationProvider
        self.trialProvider = trialProvider
        self.registrationStrategy = registrationStrategy
        self.configuration = configuration
        self.licenseChangeCallback = licenseChangeCallback
        self.invalidLicenseCallback = invalidLicenseCallback
    }

    func register(payload: RegistrationPayload) {

        guard payloadIsValid(payload) else {
            invalidLicenseCallback(payload)
            return
        }

        let license = License(name: payload.name, licenseCode: payload.licenseCode)
        let licenseInformation = LicenseInformation.registered(license)

        licenseWriter.store(license: license)
        licenseChangeCallback(licenseInformation)
    }

    private func payloadIsValid(_ payload: RegistrationPayload) -> Bool {
        return self.registrationStrategy.isValid(
            payload: payload,
            configuration: self.configuration,
            licenseVerifier: self.licenseVerifier)
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
