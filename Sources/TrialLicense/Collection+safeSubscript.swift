// Copyright (c) 2015-2019 Christian Tietze
//
// See the file LICENSE for copying permission.

extension Collection {
    subscript (safe index: Self.Index) -> Self.Iterator.Element? {
        return index < endIndex ? self[index] : nil
    }
}
