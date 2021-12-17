//
//  Coordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/9/21.
//

import Foundation
import UIKit

protocol Coordinator: AnyObject {
   
}

extension Coordinator {
    func start() {}
}

extension Coordinator where Self: PageCoordinator {
    func start(name: String, symbol: String, type: String) {}
}


