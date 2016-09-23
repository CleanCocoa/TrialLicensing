// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation
import Trial

fileprivate extension License {
    
    func isValid(licenseVerifier: LicenseVerifier) -> Bool {
        
        return licenseVerifier.isValid(licenseCode: licenseCode, forName: name)
    }
}

public class LicenseInformationProvider {
    
    let trialProvider: TrialProvider
    let licenseProvider: LicenseProvider
    let clock: KnowsTimeAndDate
    let licenseVerifier: LicenseVerifier

    public convenience init(configuration: LicenseConfiguration) {

        self.init(trialProvider: TrialProvider(),
                  licenseProvider: LicenseProvider(),
                  licenseVerifier: LicenseVerifier(configuration: configuration))
    }

    init(trialProvider: TrialProvider, licenseProvider: LicenseProvider, licenseVerifier: LicenseVerifier, clock: KnowsTimeAndDate = Clock()) {
        
        self.trialProvider = trialProvider
        self.licenseProvider = licenseProvider
        self.licenseVerifier = licenseVerifier
        self.clock = clock
    }
    
    public var isLicenseInvalid: Bool {
        
        guard let license = self.license() else {
            return false
        }
        
        return !license.isValid(licenseVerifier: licenseVerifier)
    }
    
    public var currentLicenseInformation: LicenseInformation {
        
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
    
    func license() -> License? {
        
        return licenseProvider.currentLicense
    }
    
    func trial() -> Trial? {
        
        return trialProvider.currentTrial(clock: clock)
    }
}
