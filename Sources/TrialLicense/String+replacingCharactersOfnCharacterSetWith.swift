// Copyright (c) 2015-2022 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

extension String {
    func replacingCharacters(
        of characterSet: CharacterSet,
        with replacement: String
    ) -> String {
        return self.components(separatedBy: characterSet)
            .joined(separator: replacement)
    }
}
