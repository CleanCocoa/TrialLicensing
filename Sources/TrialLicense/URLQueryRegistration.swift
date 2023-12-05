// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class URLQueryRegistration {
    fileprivate static var expectedHost: String { return TrialLicense.URLComponents.host }

    public lazy var queryParser: URLQueryLicenseParser = URLQueryLicenseParser()

    public func register(urlComponents: Foundation.URLComponents) {
        guard urlComponents.host == URLQueryRegistration.expectedHost,
              let queryItems = urlComponents.queryItems,
              let license = queryParser.parse(queryItems: queryItems)
        else { return }
        AppLicensing.register(payload: license.payload)
    }
}
