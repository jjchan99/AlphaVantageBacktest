//
//  Animations.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 27/9/21.
//

import Foundation
import UIKit

public extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> ()) {
        isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: {
            [weak self] in self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { (done) in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: { [weak self] in
                self?.transform =
                    CGAffineTransform(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
}
