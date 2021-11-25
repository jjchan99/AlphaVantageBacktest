//
//  GraphRendererModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 18/10/21.
//
import Foundation
import SwiftUI
import CoreGraphics

struct GraphRenderer {
    
    let width: CGFloat
    let height: CGFloat
    let data: [DCAResult]
    let meta: DCAResultMeta
    let mode: Mode
    let metaAnalysis: MetaAnalysis
    
    init(width: CGFloat, height: CGFloat, data: [DCAResult], meta: DCAResultMeta, mode: Mode) {
        self.width = width
        self.height = height
        self.data = data
        self.meta = meta
        self.mode = mode
        self.metaAnalysis = MetaAnalysis(meta: meta, mode: mode)
    }
    
    func getYPosition(range: Double, index: Int) -> CGFloat {
        let getMetaType = metaAnalysis.getMetaType
        let minY = metaAnalysis.minY
        let maxY = metaAnalysis.maxY
        switch getMetaType {
        case .allPositive:
            let untranslated = (1 - (CGFloat((data[index].mode(mode: mode) - minY) / range))) * height
            let minShareOfHeight = (CGFloat(minY/maxY)) * height
        return untranslated - minShareOfHeight
        case .negativePositive:
        return (1 - (CGFloat((data[index].mode(mode: mode) - minY) / range))) * height
        case .allNegative:
            let minShareOfHeight = CGFloat(maxY/minY) * height
            let shareOfRange = CGFloat((maxY - data[index].mode(mode: mode))) / CGFloat(range)
            let untranslated = (shareOfRange) * height
            return untranslated + minShareOfHeight
    }
    }
    
    
    
    func render() -> (path: Path, area: Path, points: [CGPoint]) {
        let zeroPosition = ZeroPosition(meta: meta, mode: mode, height: height).getZeroPosition()
        let minY = meta.mode(mode: mode, min: true)
        let range: Double = metaAnalysis.getRange()
        var pointArray: [CGPoint] = []
        var path = Path()
        var area = Path()
        
        for index in 0...data.count {
        
        let xPosition: CGFloat = width / CGFloat(data.count) * CGFloat(index)
        let yPosition = index == 0 ? zeroPosition : getYPosition(range: range, index: index - 1)

        if index == 0 {
            pointArray.append(CGPoint(x: 0, y: yPosition))
            path.move(to: CGPoint(x: 0, y: yPosition))
            area.move(to: CGPoint(x: 0, y: yPosition))
        } else {
            pointArray.append(CGPoint(x: xPosition, y: yPosition))
            path.addLine(to: CGPoint(x: xPosition, y: yPosition))

            area.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }

        if index == data.count {
            area.addLine(to: CGPoint(x: xPosition, y: zeroPosition))
            area.addLine(to: CGPoint(x: 0, y: zeroPosition))
            area.addLine(to: CGPoint(x: 0, y: (1 - (CGFloat((data[0].mode(mode: mode) - minY) / range))) * height))
            
            area.closeSubpath()
        }
    }
    return (path, area, pointArray)
    }
}
