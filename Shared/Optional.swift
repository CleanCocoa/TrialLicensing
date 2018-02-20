// Copyright (c) 2015-2018 Christian Tietze
// 
// See the file LICENSE for copying permission.

import Foundation

func hasValue<T>(_ value: T?) -> Bool {
    switch (value) {
    case .some(_): return true
    case .none: return false
    }
}

/// Super-useful as `>>-` operator to chain function 
/// calls which take optionals:
///     
///     foo() >>- bar >>- baz
///
/// `.None` will cascade, `.Some(_:T)` will be passed 
/// on to the next in chain.
func bind<T, U>(_ optional: T?, f: (T) -> U?) -> U? {
    
    if let x = optional {
        return f(x)
    } else {
        return .none
    }
}

precedencegroup BindingPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator >>- : BindingPrecedence

func >>-<T, U>(optional: T?, f: (T) -> U?) -> U? {
    
    return bind(optional, f: f)
}
