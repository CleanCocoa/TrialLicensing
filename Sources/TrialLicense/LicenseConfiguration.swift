// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

/// Configuration for the app's license generator and verifier
/// using CocoaFob.
public struct LicenseConfiguration: Equatable {

    public let appName: String
    public let publicKey: String
    public let removeWhitespaceFromLicenseCodes: Bool

    /// - Parameters:
    ///   - appName: Name of the product as it is used by the license generator.
    ///   - publicKey: Complete public key PEM, including the header and footer lines.
    ///
    ///     Example:
    ///
    ///         -----BEGIN DSA PUBLIC KEY-----\n
    ///         MIHwMIGoBgcqhkjOOAQBMI...
    ///         GcAkEAoKLaPXkgAPng5YtV...
    ///         -----END DSA PUBLIC KEY-----\n
    ///   - removeWhitespaceFromLicenseCodes: Determines whether writing and reading license codes
    ///     from `UserDefaults` will remove any whitespace from license codes. This can make pasting
    ///     license codes easier for end users.
    public init(
        appName: String,
        publicKey: String,
        removingWhitespaceFromLicenseCodes: Bool = true
    ) {
        self.appName = appName
        self.publicKey = publicKey
        self.removeWhitespaceFromLicenseCodes = removingWhitespaceFromLicenseCodes
    }
}
