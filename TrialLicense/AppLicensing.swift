// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

public protocol AppLicensingDelegate: class {

    func licenseDidChange(licenseInformation: LicenseInformation)
    func didEnterInvalidLicenseCode(name: String, licenseCode: String)
}

typealias LicenseChangeCallback = (_ licenseInformation:LicenseInformation) -> Void

/// Central licensing configuration object.
///
/// Exposes `currentLicensingInformation` as a means to query for the
/// active mode of the app.
///
/// The `delegate` will receive notifications about license changes proactively.
public class AppLicensing {

    let licenseInformationProvider: LicenseInformationProvider
    fileprivate(set) var register: RegisterApplication!
    fileprivate(set) var trialRunner: TrialRunner!

    public weak fileprivate(set) var delegate: AppLicensingDelegate?

    /// - parameter configuration: Settings used to verify licenses for 
    ///   this app.
    /// - parameter delegate: Optionally, provide the `AppLicensingDelegate` 
    ///   upon initialization already.
    public init(configuration: LicenseConfiguration, delegate: AppLicensingDelegate? = nil) {

        let licenseVerifier = LicenseVerifier(configuration: configuration)
        let licenseProvider = LicenseProvider()
        let trialProvider = TrialProvider()
        self.licenseInformationProvider = LicenseInformationProvider(
            trialProvider: trialProvider,
            licenseProvider: licenseProvider,
            licenseVerifier: licenseVerifier)

        self.trialRunner = TrialRunner(
            trialProvider: trialProvider,
            licenseChangeCallback: { [weak self] in
                self?.licenseDidChange(licenseInformation: $0)
            })

        let licenseWriter = LicenseWriter()
        self.register = RegisterApplication(
            licenseVerifier: licenseVerifier,
            licenseWriter: licenseWriter,
            licenseChangeCallback: { [weak self] in
                self?.licenseDidChange(licenseInformation: $0)
            },
            invalidLicenseCallback: { [weak self] in
                self?.didEnterInvalidLicense(name: $0, licenseCode: $1)
            })

        self.delegate = delegate
    }

    public var currentLicenseInformation: LicenseInformation {

        return licenseInformationProvider.currentLicenseInformation
    }


    // MARK: Delegate adapters

    fileprivate func licenseDidChange(licenseInformation: LicenseInformation) {

        self.delegate?.licenseDidChange(licenseInformation: licenseInformation)
    }

    fileprivate func didEnterInvalidLicense(name: String, licenseCode: String) {

        self.delegate?.didEnterInvalidLicenseCode(name: name, licenseCode: licenseCode)
    }
}
