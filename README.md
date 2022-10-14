# Time-Based Trial App Licensing

Adds time-based trial and easy license verification using [CocoaFob](https://github.com/glebd/cocoafob) to your macOS app.

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

**For setup instructions of your own store and app preparation with FastSpring, have a look at my book [_Make Money Outside the Mac App Store_](https://christiantietze.de/books/make-money-outside-mac-app-store-fastspring/)!**

## Installation

### Swift Package Manager

```swift
dependencies: [
  .package(url: "https://github.com/CleanCocoa/TrialLicense.git", .upToNextMinor(from: "2.1")),
]
```

Add package depencency via Xcode by using this URL: `https://github.com/CleanCocoa/TrialLicense.git`

CocoaFob is automatically linked statically for you, no need to do anything.

### Carthage

* Include the `Trial` and `TrialLicense` libraries in your project.
* Include the [CocoaFob (Swift 5)](https://github.com/glebd/cocoafob/tree/master/swift5) library in your project, too. (You have to link this in the app because a library cannot embed another library.)

## Usage

* Create an `AppLicensing` instance with `licenseChangeBlock` and `invalidLicenseInformationBlock` handling change events.
* Set up and start the trial.

Example:

```swift
import TrialLicense

let publicKey = [
        "-----BEGIN DSA PUBLIC KEY-----\n",
        // ...
        "-----END DSA PUBLIC KEY-----\n"
    ].join("")
let configuration = LicenseConfiguration(appName: "AmazingApp!", publicKey: publicKey)

class MyApp: AppLicensingDelegate {

    init() {

        AppLicensing.setUp(
            configuration: configuration,
            initialTrialDuration: Days(30),

            // Set up the callbacks:
            licenseChangeBlock: self.licenseDidChange(licenseInfo:),
            invalidLicenseInformationBlock: self.didEnterInvalidLicenseCode(name:licenseCode:),

            // Get notified about initial state to unlock the app immediately:
            fireInitialState: true)
    }

    func licenseDidChange(licenseInformation: LicenseInformation) {

        switch licenseInformation {
        case .onTrial(_):
            // Changing back to trial may be possible if you support unregistering
            // form the app (and the trial period is still good.)
            return

        case .registered(_):
            // For example:
            //   displayThankYouAlert()
            //   unlockApp()

        case .trialUp:
            // For example:
            //   displayTrialUpAlert()
            //   lockApp()
            //   showRegisterApp()
        }
    }

    func didEnterInvalidLicenseCode(name: String, licenseCode: String) {

        // For example:
        //   displayInvalidLicenseAlert()
        // -- or show an error label in the license window.
    }
}

let myApp = MyApp()
```

## Components

`LicenseInformation` reveals the state your app is in:

```swift
enum LicenseInformation {
    case registered(License)
    case onTrial(TrialPeriod)
    case trialUp
}
```

The associated types provide additional information, for example to display details in a settings window or show remaining trial days in the title bar of your app.

`License` represents a valid name--license code pair:

```swift
struct License {
    let name: String
    let licenseCode: String
}
```

`TrialPeriod` encapsulates the duration of the trial.

```swift
struct TrialPeriod {
    let startDate: Date
    let endDate: Date
}
```

`TrialPeriod` also provides these convenience methods:

* `ended() -> Bool`
* `daysLeft() -> Days`

... where `Days` encapsulates the remainder for easy conversion to `TimeInterval` and exposing `userFacingAmount: Int` for display.

## License

Copyright (c) 2016 by [Christian Tietze](http://christiantietze.de/). Distributed under the MIT License. See the LICENSE file for details.
