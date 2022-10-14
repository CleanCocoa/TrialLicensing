// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

/// The supported license generation template you use.
public enum LicensingScheme {

    /// Template `"APPNAME"`.
    case generic

    /// Template `"APPNAME,LICENSEE_NAME"`.
    case personalizedLicense

    func registrationName(appName: String, payload: RegistrationPayload) -> String {
        switch self {
        case .generic:
            return appName

        case .personalizedLicense:
            let licenseeName = payload.name ?? ""
            return "\(appName),\(licenseeName)"
        }
    }

    internal var registrationStrategy: RegistrationStrategy {
        switch self {
        case .generic:
            return GenericRegistrationStrategy()

        case .personalizedLicense:
            return PersonalizedLicenseRegistrationStrategy()
        }
    }
}
