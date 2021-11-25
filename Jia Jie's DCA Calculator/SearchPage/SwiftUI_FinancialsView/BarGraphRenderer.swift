//
//  LineGraphRenderer.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import Foundation
import CoreGraphics
import SwiftUI

enum metaType {
    case allNegative
    case allPositive
    case negativePositive
}

struct BarGraphRenderer {

    let width: CGFloat
    let height: CGFloat
    let data: [Double]
    let metaAnalysis: BarMetaAnalysis
    
    init(width: CGFloat, height: CGFloat, data: [Double]) {
        self.width = width
        self.height = height
        self.data = data
        self.metaAnalysis = .init(data: data)
    }
    
    func getYPosition(range: Double, index: Int) -> CGFloat {
        let getMetaType: metaType = metaAnalysis.getMetaType
        let minY = metaAnalysis.minY
        let maxY = metaAnalysis.maxY
        switch getMetaType {
        case .allPositive:
//            Log.queue(action: "All Positive")
            let untranslated = (1 - (CGFloat((data[index] - minY) / range))) * height
            let minShareOfHeight = (CGFloat(minY/maxY)) * height
        return untranslated - minShareOfHeight
        case .negativePositive:
        return (1 - (CGFloat((data[index] - minY) / range))) * height
        case .allNegative:
            let minShareOfHeight = CGFloat(maxY/minY) * height
            let shareOfRange = CGFloat((maxY - data[index])) / CGFloat(range)
            let untranslated = (shareOfRange) * height
            return untranslated + minShareOfHeight
    }
    }
    
    func render() -> (path: Path, area: Path) {
        let zeroPosition: CGFloat = BarZeroPosition.init(metaAnalysis: metaAnalysis, height: height).getZeroPosition()
        let minY = metaAnalysis.minY
        let range: Double = metaAnalysis.getRange()
        var pointArray: [CGPoint] = []
        var path = Path()
        var area = Path()
        let spacing: CGFloat = CGFloat(30).wScaled()
        let type = metaAnalysis.getMetaType
        
        for index in data.indices {
//            print("You should see \(data.count) bars: \(data)")
        
        let xPosition: CGFloat = (width / CGFloat(data.count)) * CGFloat(index + 1)
        let yPosition = getYPosition(range: range, index: index)
        let height = type == .allPositive ? height : zeroPosition
        
        if index == 0 {
            path.move(to: CGPoint(x: 0, y: zeroPosition))
            path.addLine(to: CGPoint(x: width - spacing, y: zeroPosition))
            path.move(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: 0, y: yPosition))
            path.addLine(to: CGPoint(x: xPosition - spacing, y: yPosition))
            path.addLine(to: CGPoint(x: xPosition - spacing, y: height))
            
//            print("x width is: \((xPosition - (spacing)) - (0))")
            
            area.move(to: CGPoint(x: 0, y: height))
            area.addLine(to: CGPoint(x: 0, y: yPosition))
            area.addLine(to: CGPoint(x: xPosition - spacing, y: yPosition))
            area.addLine(to: CGPoint(x: xPosition - spacing, y: height))
            area.addLine(to: CGPoint(x: spacing, y: height))
            area.closeSubpath()
        } else {
            let referencePoint = path.currentPoint!.x + spacing
            
            path.move(to: CGPoint(x: path.currentPoint!.x + spacing, y: height))
            path.addLine(to: CGPoint(x: path.currentPoint!.x, y: yPosition))
            path.addLine(to: CGPoint(x: xPosition - spacing, y: yPosition))
            path.addLine(to: CGPoint(x: xPosition - spacing, y: height))
            
//            print("x width is: \((xPosition - spacing) - referencePoint)")
            
            area.move(to: CGPoint(x: referencePoint, y: height))
            area.addLine(to: CGPoint(x: referencePoint, y: yPosition))
            area.addLine(to: CGPoint(x: xPosition - spacing, y: yPosition))
            area.addLine(to: CGPoint(x: xPosition - spacing, y: height))
            area.addLine(to: CGPoint(x: referencePoint, y: height))
            area.closeSubpath()
        }
//            print("x endpoint is: \(path.currentPoint!.x + spacing)")
    }
    return (path, area)
    }
    
   
}

struct BarMetaAnalysis {

    init(data: [Double]) {
        self.data = data
    }

    let data: [Double]

    var maxY: Double {
        data.max()!
    }

    var minY: Double {
        data.min()!
    }

    var getMetaType: metaType {
        let allNegativeOrAllPositive: metaType = minY < 0 && maxY < 0 ? .allNegative : .allPositive
        let metaType: metaType = minY < 0 && maxY >= 0 ? .negativePositive : allNegativeOrAllPositive
        return metaType
    }

    func getRange() -> Double {
        switch getMetaType {
        case .allNegative:
            return abs(minY)
        case .allPositive:
            return maxY
        case .negativePositive:
            return maxY - minY
        }
    }
}

struct BarZeroPosition {
    private let metaAnalysis: BarMetaAnalysis

    let height: CGFloat

    init(metaAnalysis: BarMetaAnalysis, height: CGFloat) {
        self.metaAnalysis = metaAnalysis
        self.height = height
    }

    func getZeroPosition() -> CGFloat {
        let metaType = metaAnalysis.getMetaType
        let range = metaAnalysis.getRange()
        let minY = metaAnalysis.minY
        switch metaType {
        case .allNegative:
            return 0
        case .allPositive:
            return height
        case .negativePositive:
            return ( CGFloat((range + minY)/range) * height )
        }
    }

}
