//
//  ViewId.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import Foundation

struct ViewId: Equatable, Hashable {
    static func == (lhs: ViewId, rhs: ViewId) -> Bool {
        return lhs.id == rhs.id
    }
    
    let id: String
    let arguments: RoutingArguments?
 
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}
