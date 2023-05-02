//
//  File.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import UIKit
import SwiftUI

var isiOS16OrAbove : Bool {
    if #available(iOS 16, *) {
        return true
    }
    return false
}

final public class Navigator : NSObject, ObservableObject {
    @MainActor
    @Published var viewIds = [ViewId]()
    
    fileprivate(set) var navigationController: UINavigationController
    internal var router: any Router
    fileprivate var push: ((any View) -> Void)!
    
    private lazy var delgate = NavigationControllerDelegate(navigator: self)
    
    public init(router: any Router)  {
        let nav = UINavigationController(navigationBarClass: UINavigationBar.self, toolbarClass: nil)
        self.navigationController = nav
        self.router = router
        super.init()
        self.setupDelegate()
    }
    
    private func setupDelegate() {
        navigationController.delegate = delgate
    }
    
    @MainActor public func push(_ id: String, arguments: RoutingArguments? = nil) {
        let v = router.viewFor(id)
        if !isiOS16OrAbove {
            let animated = arguments?.animate ?? true
            let title = arguments?.title
            let vc = MHostViewController(tag: id, rootView: AnyView(v))
            vc.title = title
            navigationController.pushViewController(vc, animated: animated)
        }
        viewIds.append(ViewId(id: id, arguments: arguments))
        Swift.print("pushed" , viewIds)
    }
    
    @MainActor public func pop(animated: Bool = true) {
        if isiOS16OrAbove {
            viewIds.removeLast()
        } else {
            navigationController.popViewController(animated: animated)
        }
    }
    
    @MainActor public func popToRoot() {
        if isiOS16OrAbove {
            viewIds.removeAll(keepingCapacity: true)
        } else {
            self.navigationController.popToRootViewController(animated: true)
        }
    }
    
    @MainActor public func popUntil( _ until: (String) -> Bool ) {
        var counter = 0
        for id in viewIds.reversed() {
            if until(id.id) {
                break
            }
            counter += 1
        }
        if isiOS16OrAbove {
            viewIds.removeLast(counter)
        } else {
            var newVCs = navigationController.viewControllers
            newVCs.removeLast(counter)
            navigationController.setViewControllers(newVCs, animated: true)
        }
    }
    
    private func disableSwipeAction(_ disable: Bool) {
        navigationController.interactivePopGestureRecognizer?.isEnabled = !disable
    }
    
}





private class NavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    private var lastcount: Int = -100
    
    private weak var navigator: Navigator!
    init(navigator: Navigator) {
        self.navigator = navigator
    }
    
    private var viewIds: [ViewId] {
        get {
            navigator.viewIds
        }
        set {
            navigator.viewIds = newValue
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        Swift.print("did show", navigationController.viewControllers.count)
        let latestCount = navigationController.viewControllers.count
        if lastcount > latestCount {
            //pop operation
            let diff = lastcount - latestCount
            viewIds.removeLast(diff)
            print("Poped", viewIds)
        } else if lastcount < latestCount {
            // push operation
        }
        
        lastcount = navigationController.viewControllers.count
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let latestCount = navigationController.viewControllers.count
        if lastcount < 0 {
            lastcount = latestCount
        }
        let isPoping = lastcount > latestCount
        if isPoping {
            let canPop = viewIds.last?.arguments?.shouldPopInteractively ?? true
            navigationController.interactivePopGestureRecognizer?.isEnabled = canPop
        }
        
        Swift.print( "will show", navigationController.viewControllers.count, "poped" , lastcount > latestCount)
    }
}
