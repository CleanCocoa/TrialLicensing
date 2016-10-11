// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class URLQueryRegistration {

    public lazy var queryParser: URLQueryLicenseParser = URLQueryLicenseParser()

    @available(macOS, introduced: 10.10)
    public func register(urlComponents: Foundation.URLComponents) {

        guard urlComponents.host == URLQueryRegistration.expectedHost,
            let queryItems = urlComponents.queryItems,
            let license = queryParser.parse(queryItems: queryItems)
            else { return }

        register(license: license)
    }

    fileprivate func register(license: License) {

        AppLicensing.register(name: license.name, licenseCode: license.licenseCode)
    }

    static var expectedHost: String { return TrialLicense.URLComponents.host }

    @available(macOS, deprecated: 10.10, message: "use register(urlComponents:) instead")
    public func register(fromUrl url: URL) {
        
        guard let query = query(url: url),
            let license = queryParser.parse(query: query)
            else { return }
        
        register(license: license)
    }
    
    fileprivate func query(url: URL) -> String? {
        
        guard let host = url.host,
            let query = url.query,
            host == URLComponents.host
            else { return nil }
            
        return query
    }
}
