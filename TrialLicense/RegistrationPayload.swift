// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

/// User data to be processed for registration.
/// See `License` for the counterpart of a valid license.
public struct RegistrationPayload: Equatable {

    public let name: String?
    public let licenseCode: String

    public init(name: String, licenseCode: String) {
        self.name = name
        self.licenseCode = licenseCode
    }

    public init(licenseCode: String) {
        self.name = nil
        self.licenseCode = licenseCode
    }
}
