//
//  SubviewProtocol.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 26/9/21.
//

import UIKit
import Foundation

protocol ViewFactory {
    mutating func configureView(parent: UIView)
    mutating func addSubviews(parent view: UIView)
    mutating func setViewConstraints(parent view: UIView)
}
