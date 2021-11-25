//
//  PieChartRenderer.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 8/11/21.
//

import Foundation
import CoreGraphics
import SwiftUI

struct PieChartRenderer {
    let data: [Double]
    let height: CGFloat
    let width: CGFloat
    
    init(data: [Double], height: CGFloat, width: CGFloat) {
        self.data = data
        self.height = height
        self.width = width
    }
    
    func render() -> [(slice1: Path, slice2: Path)] {
        var pathArray: [(slice1: Path, slice2: Path)] = []
        for index in data.indices {
    
        let denominator: Double = data[index] >= 1 ? 1 + data[index] : 1
        let startAngle: Angle = .init(degrees: 0)
        let endAngle: Angle = Angle(degrees: (360 * (data[index]/denominator)) - 90)
//            print("endAngle: \(endAngle.degrees). debt to equity is \(data[index])")
        var slice1 = Path()
            slice1.addArc(center: .init(x: width/2, y: height/2), radius: height / 2, startAngle: .init(degrees: -90), endAngle: endAngle, clockwise: false)
            slice1.addLine(to: CGPoint(x: width/2, y: height/2))
            slice1.addLine(to: CGPoint(x: width/2, y: 0))
            slice1.closeSubpath()
            
        var slice2 = Path()
            slice2.addArc(center: .init(x: width/2, y: height/2), radius: height / 2, startAngle: .init(degrees: -90), endAngle: endAngle, clockwise: true)
            slice2.addLine(to: CGPoint(x: width/2, y: height/2))
            slice2.addLine(to: CGPoint(x: width/2, y: 0))
            slice2.closeSubpath()
            
        pathArray.append((slice1, slice2))
        }
        return pathArray
    }
    
    
}
