//
//  File.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import SwiftUI

public protocol Router {
    func viewFor(_ id: String, argument: RoutingArguments? ) -> any View
}

public extension Router {
    func viewFor(_ id: String ) -> any View {
        return self.viewFor(id, argument: nil)
    }
}
