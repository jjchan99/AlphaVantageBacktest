//
//  ScaleFactor.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/11/21.
//

import Foundation
import UIKit

fileprivate struct ScaleFactor {
    
    //MARK: where Ref = iPhone 12 pro max
    
    static private let w = UIScreen.main.bounds.width
    static private let h = UIScreen.main.bounds.height
    static private let hRef: CGFloat = 926
    static private let wRef: CGFloat = 428
    
    static func hScaled(_ value: CGFloat) -> CGFloat {
        return value * (h/hRef)
    }
    static func wScaled(_ value: CGFloat) -> CGFloat {
        return value * (w/wRef)
    }
}

extension CGFloat {
    func hScaled() -> Self {
        return ScaleFactor.hScaled(self)
    }
    
    func wScaled() -> Self {
        return ScaleFactor.wScaled(self)
    }
}
