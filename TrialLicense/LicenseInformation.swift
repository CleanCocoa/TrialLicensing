// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

public enum LicenseInformation {

    case registered(License)
    case onTrial(TrialPeriod)
    case trialUp
}

extension LicenseInformation {

    public typealias UserInfo = [AnyHashable : Any]

    public var userInfo: UserInfo {

        switch self {
        case let .onTrial(trialPeriod):
            return [
                "registered" : false,
                "on_trial" : true,
                "trial_start_date"  : trialPeriod.startDate,
                "trial_end_date" : trialPeriod.endDate,
            ]
        case let .registered(license):
            var result: UserInfo = [
                "registered" : true,
                "on_trial" : false,
                "licenseCode" : license.licenseCode
            ]
            result["name"] = license.name
            return result
        case .trialUp:
            return [
                "registered" : false,
                "on_trial" : false
            ]
        }
    }

    public init?(userInfo: UserInfo) {
        guard let registered = userInfo["registered"] as? Bool else { return nil }

        if let onTrial = userInfo["on_trial"] as? Bool,
            !registered {

            if !onTrial {
                self = .trialUp
                return
            }

            if let startDate = userInfo["trial_start_date"] as? Date,
                let endDate = userInfo["trial_end_date"] as? Date {

                self = .onTrial(TrialPeriod(startDate: startDate, endDate: endDate))
                return
            }
        }

        guard let licenseCode = userInfo["licenseCode"] as? String else { return nil }
        let name = userInfo["name"] as? String

        self = .registered(License(name: name, licenseCode: licenseCode))
    }

    /// Uses `userInfo` of `notification` to try to initialize a `LicenseInformation` object.
    public init?(notification: Notification) {
        guard let userInfo = notification.userInfo else { return nil }
        self.init(userInfo: userInfo)
    }
}

extension LicenseInformation: Equatable { }

public func ==(lhs: LicenseInformation, rhs: LicenseInformation) -> Bool {

    switch (lhs, rhs) {
    case (.trialUp, .trialUp): return true
    case let (.onTrial(lPeriod), .onTrial(rPeriod)): return lPeriod == rPeriod
    case let (.registered(lLicense), .registered(rLicense)): return lLicense == rLicense
    default: return false
    }
}
