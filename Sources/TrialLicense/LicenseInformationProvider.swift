// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

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
    let licenseVerifier: LicenseVerifier
    let registrationStrategy: RegistrationStrategy
    let configuration: LicenseConfiguration
    let clock: KnowsTimeAndDate

    init(trialProvider: ProvidesTrial,
         licenseProvider: ProvidesLicense,
         licenseVerifier: LicenseVerifier,
         registrationStrategy: RegistrationStrategy,
         configuration: LicenseConfiguration,
         clock: KnowsTimeAndDate = Clock()) {
        
        self.trialProvider = trialProvider
        self.licenseProvider = licenseProvider
        self.licenseVerifier = licenseVerifier
        self.registrationStrategy = registrationStrategy
        self.configuration = configuration
        self.clock = clock
    }
    
    var isLicenseInvalid: Bool {
        
        guard let license = self.license() else {
            return false
        }

        return !self.isLicenseValid(license)
    }

    var currentLicenseInformation: LicenseInformation {
        
        if let license = self.license(),
            isLicenseValid(license) {
            
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

    private func isLicenseValid(_ license: License) -> Bool {
        return registrationStrategy.isValid(
            payload: license.payload,
            configuration: self.configuration,
            licenseVerifier: self.licenseVerifier)
    }
}
