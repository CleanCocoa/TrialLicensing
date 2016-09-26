// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class URLQueryRegistration {

    public lazy var queryParser: URLQueryLicenseParser = URLQueryLicenseParser()
    
    public func register(fromUrl url: URL) {
        
        guard let query = query(url: url),
            let license = queryParser.parse(query: query)
            else { return }
        
        AppLicensing.register(name: license.name, licenseCode: license.licenseCode)
    }
    
    fileprivate func query(url: URL) -> String? {
        
        guard let host = url.host,
            let query = url.query,
            host == URLComponents.host
            else { return nil }
            
        return query
    }
}
