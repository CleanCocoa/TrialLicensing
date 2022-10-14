// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial
@_implementationOnly import Shared

typealias LicenseChangeCallback = (_ licenseInformation:LicenseInformation) -> Void

/// Central licensing configuration object.
///
/// Exposes `currentLicensingInformation` as a means to query for the
/// active mode of the app.
///
/// The `delegate` will receive notifications about license changes proactively.
public class AppLicensing {

    public static private(set) var sharedInstance: AppLicensing?

    /// - returns: `nil` if the `AppLicensing` module wasn't set up prior to accessing the value, or the up-to date information otherwise.
    public static var currentLicenseInformation: LicenseInformation? {
        return sharedInstance?.currentLicenseInformation
    }

    public static var isLicenseInvalid: Bool? {
        return sharedInstance?.isLicenseInvalid
    }

    public static var registerApplication: HandlesRegistering? {
        return sharedInstance?.register
    }

    @available(*, deprecated, message: "Use invalidLicenseInformationBlock of type (RegistrationPayload) -> Void")
    public static func startUp(
        configuration: LicenseConfiguration,
        initialTrialDuration: Days,
        licenseChangeBlock: @escaping ((LicenseInformation) -> Void),
        invalidLicenseInformationBlock: @escaping ((String, String) -> Void),
        clock: KnowsTimeAndDate = Clock(),
        userDefaults: UserDefaults = UserDefaults.standard,
        fireInitialState: Bool = false) {

        startUp(
            configuration: configuration,
            initialTrialDuration: initialTrialDuration,
            licenseChangeBlock: licenseChangeBlock,
            invalidLicenseInformationBlock: { (payload) in
                invalidLicenseInformationBlock(payload.name ?? "", payload.licenseCode)
            },
            licensingScheme: .personalizedLicense,
            clock: clock,
            userDefaults: userDefaults,
            fireInitialState: fireInitialState)
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
    /// - parameter licenseChangeBlock: Invoked on license state changes.
    /// - parameter invalidLicenseInformationBlock: Invoked when license details
    ///   used to register are invalid.
    /// - parameter registrationStrategy: Which parameters to use to verify licenses.
    ///   Default is `.personalizedLicense`.
    /// - parameter clock: Testing seam so you can see what happens if the
    ///   trial is up with manual or integration tests.
    /// - parameter userDefaults: The UserDefaults instance you want to store the
    ///   trial info in. Default is `standard`.
    /// - parameter fireInitialState: Pass `true` to have the end of the
    ///   setup routine immediately call `licenseChangeBlock`.
    ///
    ///   Default is `false`.
    ///
    ///   The callback is dispatched asynchronously on the main queue.
    public static func startUp(
        configuration: LicenseConfiguration,
        initialTrialDuration: Days,
        licenseChangeBlock: @escaping ((LicenseInformation) -> Void),
        invalidLicenseInformationBlock: @escaping ((_ payload: RegistrationPayload) -> Void),
        licensingScheme: LicensingScheme = .personalizedLicense,
        clock: KnowsTimeAndDate = Clock(),
        userDefaults: UserDefaults = UserDefaults.standard,
        fireInitialState: Bool = false) {

        guard !hasValue(AppLicensing.sharedInstance)
            else { preconditionFailure("AppLicensing.startUp was called twice") }

        AppLicensing.sharedInstance = {

            let appLicensing = AppLicensing(
                configuration: configuration,
                initialTrialDuration: initialTrialDuration,
                licenseChangeBlock: licenseChangeBlock,
                invalidLicenseInformationBlock: invalidLicenseInformationBlock,
                licensingScheme: licensingScheme,
                clock: clock,
                userDefaults: userDefaults)

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

        guard !trialPeriodReader.isConfigured else { return }

        let trialPeriod = TrialPeriod(numberOfDays: initialTrialDuration,
                                      clock: self.clock)
        TrialWriter(userDefaults: userDefaults).store(trialPeriod: trialPeriod)
    }

    fileprivate func configureTrialRunner() {
        // TODO: change `configureTrialRunner` and `TrialRunner.startTrialTimer` to accept `TrialPeriod` parameter.

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


    // MARK: App license cycle convenience methods

    /// Try to validate a license from `payload` and change the state
    /// of the app; will fire a change event if things go well.
    ///
    /// See the callbacks or `AppLicensingDelegate` methods.
    ///
    /// - important: Set up licensing with `setUp` first or the app will crash here.
    /// - parameter payload: The information to attempt a registration with.
    ///
    /// See also for convenience:
    /// - `register(name:licenseCode:)`
    /// - `register(licenseCode:)`
    public static func register(payload: RegistrationPayload) {

        guard let registerApplication = registerApplication else {
            preconditionFailure("Call setUp first")
        }

        registerApplication.register(payload: payload)
    }

    /// Try to validate a license with a personalized `RegistrationPayload`
    /// and change the state of the app; will fire a change event if
    /// things go well.
    ///
    /// See the callbacks or `AppLicensingDelegate` methods.
    ///
    /// - important: Set up licensing with `setUp` first or the app will crash here.
    /// - parameter name: Licensee name.
    /// - parameter licenseCode: License code for validation.
    ///
    /// See also:
    /// - `register(payload:)`
    /// - `register(licenseCode:)`
    public static func register(name: String, licenseCode: String) {

        register(payload: RegistrationPayload(name: name, licenseCode: licenseCode))
    }

    /// Try to validate a license with a non-personalized `RegistrationPayload`
    /// and change the state of the app; will fire a change event if
    /// things go well.
    ///
    /// See the callbacks or `AppLicensingDelegate` methods.
    ///
    /// - important: Set up licensing with `setUp` first or the app will crash here.
    /// - parameter licenseCode: License code for validation.
    ///
    /// See also:
    /// - `register(payload:)`
    /// - `register(name:licenseCode)`
    public static func register(licenseCode: String) {

        register(payload: RegistrationPayload(licenseCode: licenseCode))
    }

    /// Registers a license owner from an incoming URL Scheme query.
    ///
    /// The parser expects requests of the format:
    ///
    ///     ://activate?name=ENC_NAME&licenseCode=CODE
    ///
    /// Where `ENC_NAME` is a base64-encoded version of the
    /// licensee name and `CODE` is the regularly encoded
    /// license code.
    ///
    /// You can create a supported URL from the incoming event like this:
    ///
    /// ```
    /// if let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
    ///     let url = URL(string: urlString) {
    ///     AppLicensing.register(fromURL: url)
    /// }
    /// ```
    ///
    /// - parameter url: Complete query URL.
    @available(macOS, introduced: 10.10)
    public static func register(urlComponents: Foundation.URLComponents) {

        URLQueryRegistration().register(urlComponents: urlComponents)
    }

    @available(macOS, deprecated: 10.10, message: "use register(urlComponents:) instead")
    public static func register(fromUrl url: URL) {

        URLQueryRegistration().register(fromUrl: url)
    }

    /// Unregisters from whatever state the app is in;
    /// only makes sense to call this when the app is `.registered`
    /// or the state won't change and no event will
    /// be fired.
    ///
    /// See the callbacks or `AppLicensingDelegate` methods.
    ///
    /// - important: Set up licensing with  `setUp` first or the app will crash here.
    public static func unregister() {

        guard let registerApplication = registerApplication
            else { preconditionFailure("Call setUp first") }

        registerApplication.unregister()
    }

    // MARK: -

    public let clock: KnowsTimeAndDate
    public let userDefaults: UserDefaults
    internal let trialPeriodReader: UserDefaultsTrialPeriodReader
    public let trialProvider: ProvidesTrial
    public let licenseInformationProvider: ProvidesLicenseInformation
    fileprivate(set) var register: RegisterApplication!
    fileprivate(set) var trialRunner: TrialRunner!
    let licensingScheme: LicensingScheme

    fileprivate(set) var licenseChangeBlock: (LicenseInformation) -> Void
    fileprivate(set) var invalidLicenseInformationBlock: (_ payload: RegistrationPayload) -> Void

    init(
        configuration: LicenseConfiguration,
        initialTrialDuration: Days,
        licenseChangeBlock: @escaping ((LicenseInformation) -> Void),
        invalidLicenseInformationBlock: @escaping ((_ payload: RegistrationPayload) -> Void),
        licensingScheme: LicensingScheme,
        clock: KnowsTimeAndDate = Clock(),
        userDefaults: UserDefaults = UserDefaults.standard) {

        self.clock = clock
        self.userDefaults = userDefaults
        self.licenseChangeBlock = licenseChangeBlock
        self.invalidLicenseInformationBlock = invalidLicenseInformationBlock
        self.licensingScheme = licensingScheme

        let licenseVerifier = LicenseVerifier(configuration: configuration)
        let licenseProvider = UserDefaultsLicenseProvider(userDefaults: userDefaults)
        self.trialPeriodReader = UserDefaultsTrialPeriodReader(userDefaults: userDefaults)
        self.trialProvider = TrialProvider(trialPeriodReader: trialPeriodReader)
        self.licenseInformationProvider = LicenseInformationProvider(
            trialProvider: trialProvider,
            licenseProvider: licenseProvider,
            licenseVerifier: licenseVerifier,
            registrationStrategy: licensingScheme.registrationStrategy,
            configuration: configuration,
            clock: clock)

        self.trialRunner = TrialRunner(
            trialProvider: trialProvider,
            licenseChangeCallback: { [weak self] in
                self?.licenseDidChange(licenseInformation: $0)
            })

        let licenseWriter = UserDefaultsLicenseWriter(userDefaults: userDefaults)
        self.register = RegisterApplication(
            licenseVerifier: licenseVerifier,
            licenseWriter: licenseWriter,
            licenseInformationProvider: licenseInformationProvider,
            trialProvider: trialProvider,
            registrationStrategy: licensingScheme.registrationStrategy,
            configuration: configuration,
            licenseChangeCallback: { [weak self] in
                self?.licenseDidChange(licenseInformation: $0)
            },
            invalidLicenseCallback: { [weak self] in
                self?.didEnterInvalidLicense(payload: $0)
            })
    }

    public var isLicenseInvalid: Bool {
        return self.licenseInformationProvider.isLicenseInvalid
    }

    public var currentLicenseInformation: LicenseInformation {

        return self.licenseInformationProvider.currentLicenseInformation
    }


    // MARK: Delegate adapters

    fileprivate func licenseDidChange(licenseInformation: LicenseInformation) {

        switch licenseInformation {
        case .onTrial: self.configureTrialRunner()
        case .registered: self.stopTrialRunner()
        case .trialUp: break
        }

        DispatchQueue.main.async {

            self.licenseChangeBlock(licenseInformation)
        }
    }

    fileprivate func didEnterInvalidLicense(payload: RegistrationPayload) {

        DispatchQueue.main.async {
            
            self.invalidLicenseInformationBlock(payload)
        }
    }
}
