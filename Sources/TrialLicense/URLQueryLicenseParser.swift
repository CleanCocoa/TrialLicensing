// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class URLQueryLicenseParser {
    
    public init() { }

    public func parse(queryItems: [Foundation.URLQueryItem]) -> License? {
        let nameQueryItem: URLQueryItem? = queryItems
            .filter { $0.name == TrialLicense.URLComponents.licensee }
            .first

        let licenseCodeQueryItem: URLQueryItem? = queryItems
            .filter { $0.name == TrialLicense.URLComponents.licenseCode }
            .first

        guard let licenseCode = licenseCodeQueryItem?.value else { return nil }

        let name = nameQueryItem?.value.flatMap { string -> String? in
            guard let decodedData = Data(base64Encoded: string) else { return nil }
            return String(data: decodedData, encoding: .utf8)
        }

        return License(name: name, licenseCode: licenseCode)
    }
}
