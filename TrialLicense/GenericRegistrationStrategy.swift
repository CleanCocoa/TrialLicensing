// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

struct GenericRegistrationStrategy: RegistrationStrategy {

    func isValid(payload: RegistrationPayload,
                 configuration: LicenseConfiguration,
                 licenseVerifier: LicenseCodeVerification)
        -> Bool
    {
        let licenseCode = payload.licenseCode
        let registrationName = LicensingScheme.generic.registrationName(
            appName: configuration.appName,
            payload: payload)
        return licenseVerifier.isValid(
            licenseCode: licenseCode,
            registrationName: registrationName)
    }
}
