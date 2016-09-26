// Copyright (c) 2015-2016 Christian Tietze
//
// See the file LICENSE for copying permission.
import Foundation

extension Sequence {

    func mapDictionary<K, V>(_ transform: (Self.Iterator.Element) throws -> (K, V)) rethrows -> [K : V] {

        var result = [K : V]()

        for element in self {
            let (key, value) = try transform(element)
            result[key] = value
        }

        return result
    }

    func mapDictionary<K, V>(_ transform: (Self.Iterator.Element) throws -> (K, V)?) rethrows -> [K : V] {

        var result = [K : V]()

        for element in self {
            if let (key, value) = try transform(element) {
                result[key] = value
            }
        }

        return result
    }

    func flatMapDictionary<K, V>(_ transform: (Self.Iterator.Element) throws -> (K, V)?) rethrows -> [K : V] {

        var result = [K : V]()

        for element in self {
            if let (key, value) = try transform(element) {
                result[key] = value
            }
        }

        return result
    }
}
