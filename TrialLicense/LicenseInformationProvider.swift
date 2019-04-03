// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

fileprivate extension License {
    
    func isValid(licenseVerifier: LicenseVerifier) -> Bool {
        
        return licenseVerifier.isValid(licenseCode: licenseCode, forName: name)
    }
}

public protocol ProvidesLicenseInformation {
    var isLicenseInvalid: Bool { get }
    var currentLicenseInformation: LicenseInformation { get }
}

public protocol ProvidesLicense {
    /// `Nil` when the info couldn't be found; a `License` from the source otherwise.
    var currentLicense: License? { get }
}

class LicenseInformationProvider: ProvidesLicenseInformation {
    
    let trialProvider: ProvidesTrial
    let licenseProvider: ProvidesLicense
    let clock: KnowsTimeAndDate
    let licenseVerifier: LicenseVerifier

    init(trialProvider: ProvidesTrial, licenseProvider: ProvidesLicense, licenseVerifier: LicenseVerifier, clock: KnowsTimeAndDate = Clock()) {
        
        self.trialProvider = trialProvider
        self.licenseProvider = licenseProvider
        self.licenseVerifier = licenseVerifier
        self.clock = clock
    }
    
    var isLicenseInvalid: Bool {
        
        guard let license = self.license() else {
            return false
        }
        
        return !license.isValid(licenseVerifier: licenseVerifier)
    }
    
    var currentLicenseInformation: LicenseInformation {
        
        if let license = self.license(),
            license.isValid(licenseVerifier: licenseVerifier) {
            
            return .registered(license)
        }
        
        if let trial = self.trial(),
            trial.isActive {
            
            return .onTrial(trial.trialPeriod)
        }
        
        return .trialUp
    }
    
    private func license() -> License? {
        
        return licenseProvider.currentLicense
    }
    
    private func trial() -> Trial? {
        
        return trialProvider.currentTrial(clock: clock)
    }
}
