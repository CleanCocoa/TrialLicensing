// Copyright (c) 2015-2018 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

public enum LicenseInformation {

    case registered(License)
    case onTrial(TrialPeriod)
    case trialUp
}

typealias UserInfo = [AnyHashable : Any]

extension LicenseInformation {

    func userInfo() -> UserInfo {

        switch self {
        case let .onTrial(trialPeriod):
            return [
                "registered" : false,
                "on_trial" : true,
                "trial_start_date"  : trialPeriod.startDate,
                "trial_end_date" : trialPeriod.endDate,
            ]
        case let .registered(license):
            return [
                "registered" : true,
                "on_trial" : false,
                "name" : license.name,
                "licenseCode"  : license.licenseCode
            ]
        case .trialUp:
            return [
                "registered" : false,
                "on_trial" : false
            ]
        }
    }

    static func fromUserInfo(userInfo: UserInfo) -> LicenseInformation? {

        guard let registered = userInfo["registered"] as? Bool else {
            return nil
        }

        if let onTrial = userInfo["on_trial"] as? Bool,
            !registered {

            guard onTrial else { return .trialUp }

            if let startDate = userInfo["trial_start_date"] as? Date,
                let endDate = userInfo["trial_end_date"] as? Date {

                return .onTrial(TrialPeriod(startDate: startDate, endDate: endDate))
            }
        }

        guard let name = userInfo["name"] as? String,
            let licenseCode = userInfo["licenseCode"] as? String
            else { return nil }

        return .registered(License(name: name, licenseCode: licenseCode))
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
