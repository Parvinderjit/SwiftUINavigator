//
//  File.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import SwiftUI
import UIKit

public struct NavigatorView<RootView: View>: View {
    @ObservedObject var navigator: Navigator
    @ViewBuilder
    var rootView: RootView
    
    public init(navigator: Navigator,
                @ViewBuilder rootView: @escaping  () -> RootView) {
        _navigator =  ObservedObject(wrappedValue: navigator)
        self.rootView = rootView()
        NavigatorKey.navigatorKey = {
            navigator
        }
    }
    
    public var body: some View {
        if #available(iOS 16.0, *) {
            _NavigationStack(navigator: navigator) {
                rootView
                    .navigationBarTitleDisplayMode(.inline)
            }.onAppear {
                navigator.popToRoot()
            }
        } else {
            _NavigatorView(navigator: navigator) { _ in
                rootView
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

@available(iOS 16.0, *)
private struct _NavigationStack<Root: View>: View {
    @State private var navigationPath = NavigationPath()
    @ObservedObject var navigator: Navigator
    @ViewBuilder
    var rootView: () -> Root
    
    var body: some View {
        NavigationStack(path: $navigationPath ) {
            rootView()
                .navigationDestination(for: String.self) { value in
                    AnyView(navigator.router.viewFor(value))
                }
        }.onAppear {
            navigationPath = .init(navigator.viewIds.map({ $0.id }))
        }.onDisappear {
            print("Disappearing")
        }
        .onChange(of: navigationPath, perform: { newValue in
            if newValue.count < navigator.viewIds.count {
                let diff = navigator.viewIds.count - newValue.count
                navigator.viewIds.removeLast(diff)
            }
        })
        .onReceive(navigator.$viewIds) { newValue in
            if newValue.count > navigationPath.count {
                navigationPath.append(newValue.last!.id)
            } else if newValue.count < navigationPath.count {
                let diff = navigationPath.count - newValue.count
                navigationPath.removeLast(diff)
            }
        }
    }
}

public struct _NavigatorView<RootView: View> : UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = UINavigationController
    
    var rootView: RootView
    
    public init(navigator: Navigator,
         @ViewBuilder rootView: @escaping (Navigator) -> RootView) {
        self.rootView = rootView(navigator)
    }
    
    public func makeUIViewController(context: Context) -> UINavigationController {
        
        return context.environment.navigator.navigationController
    }
    
    public func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        let navigator = context.environment.navigator
        let v = rootView
        navigator.navigationController.setViewControllers([UIHostingController(rootView: v)], animated: true)
        print("update")
    }
    
    public static func dismantleUIViewController(_ uiViewController: UINavigationController, coordinator: ()) {
        print("Dismantle")
    }
    
}
