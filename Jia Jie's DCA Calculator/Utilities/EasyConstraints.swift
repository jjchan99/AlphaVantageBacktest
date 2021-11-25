//
//  ConstraintProtocol.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 20/9/21.
//

import Foundation
import UIKit

extension UIView {
internal enum Constraints {
    case top(constant: CGFloat = 0, equalTo: ReferenceYAnchors = .top)
    case leading(constant: CGFloat = 0, equalTo: ReferenceXAnchors = .leading)
    case trailing(constant: CGFloat = 0, equalTo: ReferenceXAnchors = .trailing)
    case bottom(constant: CGFloat = 0, equalTo: ReferenceYAnchors = .bottom)
    
    internal enum ReferenceYAnchors {
        case top
        case bottom
    }
    
    internal enum ReferenceXAnchors {
        case leading
        case trailing
    }
}
}


protocol EasyConstraints {}

extension EasyConstraints where Self: UIView {
    func activateConstraints(reference: UIView, constraints: [Constraints], identifier: String) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.forEach { constraints in
            
            switch constraints {
            
             case let .top(constant, equalTo):
                if equalTo == .top {
                  let constraint = self.topAnchor.constraint(equalTo: reference.topAnchor, constant: constant)
                  constraint.identifier = "top\(identifier)"
                  constraint.isActive = true
                } else {
                  let constraint = self.topAnchor.constraint(equalTo: reference.bottomAnchor, constant: constant)
                  constraint.identifier = "top\(identifier)"
                  constraint.isActive = true
                }
                
             case let .leading(constant, equalTo):
                if equalTo == .leading {
                   let constraint = self.leadingAnchor.constraint(equalTo: reference.leadingAnchor, constant: constant)
                    constraint.identifier = "leading\(identifier)"
                    constraint.isActive = true
                } else {
                   let constraint = leadingAnchor.constraint(equalTo: reference.trailingAnchor, constant: constant)
                   constraint.identifier = "leading\(identifier)"
                   constraint.isActive = true
                }
                
             case let .trailing(constant, equalTo):
                if equalTo == .trailing {
                   let constraint = self.trailingAnchor.constraint(equalTo: reference.trailingAnchor, constant: constant)
                   constraint.identifier = "trailing\(identifier)"
                   constraint.isActive = true
                } else {
                   let constraint = self.trailingAnchor.constraint(equalTo: reference.leadingAnchor, constant: constant)
                   constraint.identifier = "trailing\(identifier)"
                   constraint.isActive = true
                }
             case let .bottom(constant, equalTo):
                if equalTo == .bottom {
                   let constraint = self.bottomAnchor.constraint(equalTo: reference.bottomAnchor, constant: constant)
                   constraint.identifier = "bottom\(identifier)"
                   constraint.isActive = true
                } else {
                   let constraint = self.bottomAnchor.constraint(equalTo: reference.topAnchor, constant: constant)
                   constraint.identifier = "bottom\(identifier)"
                   constraint.isActive = true
                }
            }
        }
    }
    
    func activateConstraints(reference: UILayoutGuide, constraints: [Constraints], identifier: String) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        constraints.forEach { constraints in
            
            switch constraints {
            
             case let .top(constant, equalTo):
                if equalTo == .top {
                  let constraint = self.topAnchor.constraint(equalTo: reference.topAnchor, constant: constant)
                  constraint.identifier = "top\(identifier)"
                  constraint.isActive = true
                } else {
                  let constraint = self.topAnchor.constraint(equalTo: reference.bottomAnchor, constant: constant)
                  constraint.identifier = "top\(identifier)"
                  constraint.isActive = true
                }
                
             case let .leading(constant, equalTo):
                if equalTo == .leading {
                   let constraint = self.leadingAnchor.constraint(equalTo: reference.leadingAnchor, constant: constant)
                    constraint.identifier = "leading\(identifier)"
                    constraint.isActive = true
                } else {
                   let constraint = leadingAnchor.constraint(equalTo: reference.trailingAnchor, constant: constant)
                   constraint.identifier = "leading\(identifier)"
                   constraint.isActive = true
                }
                
             case let .trailing(constant, equalTo):
                if equalTo == .trailing {
                   let constraint = self.trailingAnchor.constraint(equalTo: reference.trailingAnchor, constant: constant)
                   constraint.identifier = "trailing\(identifier)"
                   constraint.isActive = true
                } else {
                   let constraint = self.trailingAnchor.constraint(equalTo: reference.leadingAnchor, constant: constant)
                   constraint.identifier = "trailing\(identifier)"
                   constraint.isActive = true
                }
             case let .bottom(constant, equalTo):
                if equalTo == .bottom {
                   let constraint = self.bottomAnchor.constraint(equalTo: reference.bottomAnchor, constant: constant)
                   constraint.identifier = "bottom\(identifier)"
                   constraint.isActive = true
                } else {
                   let constraint = self.bottomAnchor.constraint(equalTo: reference.topAnchor, constant: constant)
                   constraint.identifier = "bottom\(identifier)"
                   constraint.isActive = true
                }
            }
        }
    }
    
    func updateConstraints(reference: UIView, constraints: [Constraints], identifier: String) {
        let currentTop = reference.constraints.filter { $0.identifier == "top\(identifier)" }.first
        let currentBottom = reference.constraints.filter { $0.identifier == "bottom\(identifier)" }.first
        let currentTrailing = reference.constraints.filter { $0.identifier == "trailing\(identifier)" }.first
        let currentLeading = reference.constraints.filter { $0.identifier == "leading\(identifier)" }.first
        constraints.forEach { constraints in
            
            switch constraints {
             case let .top(constant, _):
                currentTop!.constant = constant
             case let .leading(constant, _):
                currentLeading?.constant = constant
             case let .trailing(constant, _):
                currentTrailing?.constant = constant
             case let .bottom(constant, _):
                currentBottom?.constant = constant
            }
        }
    }
}

extension UIView: EasyConstraints {}

extension UIView {
    
}




