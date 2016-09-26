// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.
import Foundation

extension Collection where Self.Index : Comparable {

    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
