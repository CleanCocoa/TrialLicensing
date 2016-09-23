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

    public static private(set) var sharedInstance: AppLicensing?

    public static var currentLicenseInformation: LicenseInformation? {
        return sharedInstance?.currentLicenseInformation
    }

    public static var isLicenseInvalid: Bool? {
        return sharedInstance?.licenseInformationProvider.isLicenseInvalid
    }

    public static var registerApplication: HandlesRegistering? {
        return sharedInstance?.register
    }
    
    /// Performs initial licensing setup:
    /// 
    /// 1. Sets up the `sharedInstance`,
    /// 2. starts the trial timer,
    /// 3. optionally reports back the current `LicenseInformation`.
    ///
    /// - parameter configuration: Settings used to verify licenses for 
    ///   this app.
    /// - parameter initialTrialDuration: Number of `Days` the time-based
    ///   trial should run beginning at the first invocation. (Consecutive
    ///   initialization calls will not alter the expiration date.)
    /// - parameter delegate: Receiver of license state changes.
    /// - parameter clock: Testing seam so you can see what happens if the 
    ///   trial is up with manual or integration tests.
    /// - parameter fireInitialState: Pass `true` to have the end of the 
    ///   setup routine immediately call `delegate.licenseDidChange`.
    ///
    ///   Default is `false`.
    ///
    ///   The callback is dispatched asynchronously on the main queue.
    public static func startUp(
        configuration: LicenseConfiguration,
        initialTrialDuration: Days,
        delegate: AppLicensingDelegate,
        clock: KnowsTimeAndDate = Clock(),
        fireInitialState: Bool = false) {

        guard !hasValue(AppLicensing.sharedInstance)
            else { preconditionFailure("AppLicensing.startUp was called twice") }

        AppLicensing.sharedInstance = {

            let appLicensing = AppLicensing(configuration: configuration, initialTrialDuration: initialTrialDuration, delegate: delegate, clock: clock)

            appLicensing.setupTrial(initialTrialDuration: initialTrialDuration)
            appLicensing.configureTrialRunner()

            return appLicensing
        }()

        if fireInitialState {
            AppLicensing.reportCurrentLicenseInformation()
        }
    }

    fileprivate static func reportCurrentLicenseInformation() {

        guard let instance = AppLicensing.sharedInstance else { return }

        instance.licenseDidChange(licenseInformation: instance.currentLicenseInformation)
    }

    public static func tearDown() {

        guard let sharedInstance = AppLicensing.sharedInstance else { return }

        sharedInstance.stopTrialRunner()

        AppLicensing.sharedInstance = nil
    }

    fileprivate func setupTrial(initialTrialDuration: Days) {

        guard !trialProvider.isConfigured else { return }

        let trialPeriod = TrialPeriod(numberOfDays: initialTrialDuration,
                                      clock: self.clock)
        TrialWriter().store(trialPeriod: trialPeriod)
    }

    fileprivate func configureTrialRunner() {

        guard shouldStartTrialRunner else { return }

        self.trialRunner.startTrialTimer()
    }

    fileprivate var shouldStartTrialRunner: Bool {

        if case .registered = self.currentLicenseInformation {
            return false
        }

        return true
    }

    fileprivate func stopTrialRunner() {

        self.trialRunner.stopTrialTimer()
    }


    // MARK: -

    let clock: KnowsTimeAndDate
    let trialProvider: TrialProvider
    let licenseInformationProvider: LicenseInformationProvider
    fileprivate(set) var register: RegisterApplication!
    fileprivate(set) var trialRunner: TrialRunner!

    public weak fileprivate(set) var delegate: AppLicensingDelegate?

    init(
        configuration: LicenseConfiguration,
        initialTrialDuration: Days,
        delegate: AppLicensingDelegate? = nil,
        clock: KnowsTimeAndDate = Clock()) {

        self.clock = clock

        let licenseVerifier = LicenseVerifier(configuration: configuration)
        let licenseProvider = LicenseProvider()
        self.trialProvider = TrialProvider()
        self.licenseInformationProvider = LicenseInformationProvider(
            trialProvider: trialProvider,
            licenseProvider: licenseProvider,
            licenseVerifier: licenseVerifier,
            clock: clock)

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

        return self.licenseInformationProvider.currentLicenseInformation
    }


    // MARK: Delegate adapters

    fileprivate func licenseDidChange(licenseInformation: LicenseInformation) {

        DispatchQueue.main.async {

            self.delegate?.licenseDidChange(licenseInformation: licenseInformation)
        }
    }

    fileprivate func didEnterInvalidLicense(name: String, licenseCode: String) {

        DispatchQueue.main.async {
            
            self.delegate?.didEnterInvalidLicenseCode(name: name, licenseCode: licenseCode)
        }
    }
}
