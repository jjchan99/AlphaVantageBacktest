//
//  SingleBarRenderer.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 9/11/21.
//

import Foundation
import SwiftUI
import CoreGraphics


struct SingleBarRenderer {
    
    let width: CGFloat
    let height: CGFloat
    let data: [Double]
    
    init(data: [Double], height: CGFloat, width: CGFloat) {
        self.width = width
        self.height = height
        self.data = data
    }
    
    func render() -> [(battery: Path, topHalf: Path)] {
        var path = Path()
        var topHalf = Path()
        let cornerRadius: CGFloat = width * 0.2
        
        var pathArray: [(Path, Path)] = []
        for index in data.indices {
           
            let denominator: Double = data[index] >= 1 ? 1 + data[index] : 1
            let yPosition = ((1 - (CGFloat(data[index] / denominator))) * (height - (2 * cornerRadius))) + cornerRadius
            let waveOffset: CGFloat = 0.1 * height
           
//            let yPosition = (0 * (height - (2 * cornerRadius))) + cornerRadius
            print("y position: \(yPosition)")
            path.move(to: CGPoint(x: 0, y: height - cornerRadius))
            path.addLine(to: CGPoint(x: 0, y: yPosition))
            path.addCurve(to: CGPoint(x: width, y: yPosition), control1: CGPoint(x: width * (2 / 4), y: yPosition + waveOffset), control2: CGPoint(x: width * (2 / 4), y: yPosition - waveOffset))
            path.addLine(to: CGPoint(x: width, y: height - cornerRadius))
            path.addArc(tangent1End: .init(x: width, y: height), tangent2End: .init(x: width - cornerRadius, y: height), radius: cornerRadius)
            path.move(to: .init(x: width - cornerRadius, y: height))
            path.addLine(to: CGPoint(x: cornerRadius, y: height))
            path.addArc(tangent1End: .init(x: 0, y: height), tangent2End: .init(x: 0, y: height - cornerRadius), radius: cornerRadius)
            
            //MARK: TOP HALF
            topHalf.move(to: .init(x: 0, y: yPosition))
            topHalf.addLine(to: .init(x: 0, y: cornerRadius))
            topHalf.addArc(tangent1End: .init(x: 0, y: 0), tangent2End: .init(x: cornerRadius, y: 0), radius: cornerRadius)
            topHalf.addLine(to: CGPoint(x: width - cornerRadius, y: 0))
            topHalf.addArc(tangent1End: .init(x: width, y: 0), tangent2End: .init(x: width, y: cornerRadius), radius: cornerRadius)
            topHalf.addLine(to: .init(x: width, y: yPosition))
            topHalf.addCurve(to: CGPoint(x: 0, y: yPosition), control1: CGPoint(x: width * (2 / 4), y: yPosition - waveOffset), control2:  CGPoint(x: width * (2 / 4), y: yPosition + waveOffset))
            topHalf.closeSubpath()
            pathArray.append((path, topHalf))
        }
        return pathArray
    }
    
    
}
