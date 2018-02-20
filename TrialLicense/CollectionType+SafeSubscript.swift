// Copyright (c) 2015-2018 Christian Tietze
//
// See the file LICENSE for copying permission.

import Foundation

extension Collection {

    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
