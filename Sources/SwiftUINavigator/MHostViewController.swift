//
//  File.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import SwiftUI

class MHostViewController<RootView: View>: UIHostingController<RootView>, TaggedView {
    
    var tag: String?
    
    @MainActor init( tag: String, rootView: RootView) {
        self.tag = tag
        super.init(rootView: rootView)
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
