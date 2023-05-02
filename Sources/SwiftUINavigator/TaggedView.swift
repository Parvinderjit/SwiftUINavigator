//
//  File.swift
//  
//
//  Created by Parvinderjit Singh on 26/04/23.
//

import UIKit

protocol TaggedView: UIViewController {
    associatedtype Tag = RawRepresentable
    var tag: Tag? { get }
}
