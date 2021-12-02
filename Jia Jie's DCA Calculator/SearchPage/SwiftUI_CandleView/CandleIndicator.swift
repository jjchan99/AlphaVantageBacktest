//
//  CandleIndicator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/11/21.
//

import Foundation
import CoreGraphics

struct CandleIndicator {
    
    let height: CGFloat
    let width: CGFloat
    let dataToDisplay: [Candle]
    
    init(height: CGFloat, width: CGFloat, dataToDisplay: [Candle]) {
        self.height = height
        self.width = width
        self.dataToDisplay = dataToDisplay
    }
    
    func updateIndicator(xPos: CGFloat) -> Int {
            let index: CGFloat = xPos / (width / CGFloat(dataToDisplay.count + 1))
            return Int(floor(index))
    }
}
