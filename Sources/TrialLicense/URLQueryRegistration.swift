// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

@usableFromInline
struct URLQueryRegistration {
    @usableFromInline
    init() { }

    @usableFromInline
    func register(
        urlComponents: Foundation.URLComponents
    ) {
        let queryParser = URLQueryLicenseParser()
        guard urlComponents.host == TrialLicense.URLComponents.host,
              let queryItems = urlComponents.queryItems,
              let license = queryParser.parse(queryItems: queryItems)
        else { return }
        AppLicensing.register(payload: license.payload)
    }
}
