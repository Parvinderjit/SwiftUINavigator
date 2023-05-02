//
//  NavigatorKey.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import SwiftUI

struct NavigatorKey: EnvironmentKey {
    static var defaultValue: Navigator {
        return navigatorKey()
    }
    internal static var navigatorKey: (() -> Navigator)!
    typealias Value = Navigator
}

extension EnvironmentValues {
    public var navigator: Navigator {
        get {
            self[NavigatorKey.self]
        }
    }
}
