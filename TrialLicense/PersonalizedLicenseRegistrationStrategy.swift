// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

struct PersonalizedLicenseRegistrationStrategy: RegistrationStrategy {

    func isValid(payload: RegistrationPayload,
                 configuration: LicenseConfiguration,
                 licenseVerifier: LicenseCodeVerification)
        -> Bool
    {
        let licenseCode = payload.licenseCode
        let registrationName = LicensingScheme.personalizedLicense.registrationName(
            appName: configuration.appName,
            payload: payload)
        return licenseVerifier.isValid(
            licenseCode: licenseCode,
            registrationName: registrationName)
    }
}
