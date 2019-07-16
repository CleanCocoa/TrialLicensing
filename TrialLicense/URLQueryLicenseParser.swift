// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

public class URLQueryLicenseParser {
    
    public init() { }

    @available(macOS, introduced: 10.10)
    public func parse(queryItems: [Foundation.URLQueryItem]) -> License? {

        let nameQueryItem: URLQueryItem? = queryItems
            .filter { $0.name == TrialLicense.URLComponents.licensee }
            .first

        let licenseCodeQueryItem: URLQueryItem? = queryItems
            .filter { $0.name == TrialLicense.URLComponents.licenseCode }
            .first

        guard let encodedName = nameQueryItem?.value,
            let licenseCode = licenseCodeQueryItem?.value
            else { return nil }

        let name = decode(string: encodedName)
        return License(name: name, licenseCode: licenseCode)
    }

    @available(macOS, deprecated: 10.10, message: "use parse(queryItems:) instead")
    public func parse(query: String) -> License? {
        
        let queryDictionary = dictionary(fromQuery: query)
        
        guard let licenseCode = queryDictionary[URLComponents.licenseCode]
            else { return nil }

        let name = decode(string: queryDictionary[URLComponents.licensee])
        return License(name: name, licenseCode: licenseCode)
    }
    
    func dictionary(fromQuery query: String) -> [String : String] {
        
        let parameters = query.components(separatedBy: "&")
        
        return parameters.mapDictionary() { param -> (String, String)? in
            
            guard let queryKey = self.queryKey(fromParameter: param),
                let queryValue = self.queryValue(fromParameter: param)
                else { return nil }
                
            return (queryKey, queryValue)
        }
    }
    
    fileprivate func queryKey(fromParameter parameter: String) -> String? {
        
        return parameter.components(separatedBy: "=")[safe: 0]
    }
    
    fileprivate func queryValue(fromParameter parameter: String) -> String? {
        
        return escapedQueryValue(parameter: parameter)
            >>- unescapeQueryValue
    }
    
    fileprivate func unescapeQueryValue(queryValue: String) -> String? {
        
        return queryValue
            .replacingOccurrences(of: "+", with: " ")
            .removingPercentEncoding
    }
    
    fileprivate func escapedQueryValue(parameter: String) -> String? {
        
        // Assume only one `=` is the separator and concatenate 
        // the rest back into the value.
        // (base64-encoded Strings often end with `=`.)
        return parameter.components(separatedBy: "=")
            .dropFirst()
            .joined(separator: "=")
    }
    
    fileprivate func decode(string: String?) -> String? {
        
        guard let string = string,
            let decodedData = Data(base64Encoded: string)
            else { return nil }
            
        return String(data: decodedData, encoding: .utf8)
    }
    
}
