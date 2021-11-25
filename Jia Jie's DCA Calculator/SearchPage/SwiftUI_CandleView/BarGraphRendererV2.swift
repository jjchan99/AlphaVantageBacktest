//
//  BarGraphRendererV2.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/11/21.
//

import Foundation
import CoreGraphics
import SwiftUI

struct BarGraphRendererV2 {
    
    let data: [OHLC]
    let height: CGFloat
    let width: CGFloat
    let max: Double
    let min: Double
    let range: Double
    let padding: CGFloat
    
    
    init(data: [OHLC], height: CGFloat, width: CGFloat, min: Double, max: Double) {
        self.data = data
        self.height = height
        self.width = width
        self.max = max
        self.min = min
        self.range = max - min
        padding = 0.05 * width
    }
    
    func getYPosition(index: Int) -> CGFloat {
        let value = CGFloat((max - Double(data[index].volume!)!) / range) * height
        return value - (0.1 * height)
    }
    
    func render() -> Path {
        var path = Path()
        for index in 0..<data.count {
            let width = width - (2 * padding)
            let maxWidth = 0.03 * width
            let yPosition = getYPosition(index: index)
            let pillars = width / CGFloat(data.count - 1)
            
            var spacing = (1/3) * pillars > maxWidth ? maxWidth : (1/3) * pillars
            let xPosition = index == 0 ? padding : (pillars * CGFloat(index)) + padding
            spacing = pillars <= 5.0 ? 1 : spacing
            
            path.move(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
            path.addLine(to: .init(x: xPosition + (0.5 * spacing), y: yPosition))
            path.addLine(to: .init(x: xPosition + (0.5 * spacing), y: height))
            path.addLine(to: .init(x: xPosition - (0.5 * spacing), y: height))
            path.addLine(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
            path.closeSubpath()
        }
        
        return path
    }
    
    
    
}
