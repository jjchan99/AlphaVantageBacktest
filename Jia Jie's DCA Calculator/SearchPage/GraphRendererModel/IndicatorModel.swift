//
//  IndicatorModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 19/10/21.
//

import Foundation
import CoreGraphics

struct Indicator {
    
    let graphPoints: [CGPoint]
    let height: CGFloat
    let width: CGFloat
    let meta: DCAResultMeta
    let mode: Mode
    let metaAnalysis: MetaAnalysis
    
    init(graphPoints: [CGPoint], height: CGFloat, width: CGFloat, meta: DCAResultMeta, mode: Mode) {
        self.graphPoints = graphPoints
        self.height = height
        self.width = width
        self.meta = meta
        self.mode = mode
        self.metaAnalysis = MetaAnalysis(meta: meta, mode: mode)
    }
    
    func updateIndicator(xPos: CGFloat) -> (selectedIndex: Int, currentPlot: String, selectedYPos: CGFloat) {
            var selectedYPos: CGFloat = 0
          
            guard xPos >= 0 && xPos <= width else { fatalError() }
            let sections = width/CGFloat(graphPoints.count-1)
            let index = xPos / sections
            if index >= 0 && index <= CGFloat(graphPoints.count - 1) {
                selectedYPos = getYPos(index: index)
            }
        
            let range = metaAnalysis.getRange()
            let getMetaType = metaAnalysis.getMetaType
            let maxY = getMetaType == .allPositive || getMetaType == .negativePositive ? metaAnalysis.maxY : metaAnalysis.minY
           
            let scaledY = getMetaType == .allPositive || getMetaType == .negativePositive ? CGFloat(maxY) - (CGFloat(range)/height) * selectedYPos : 0 - (CGFloat(range)/height) * selectedYPos
            let currentPlot = mode.format(float: scaledY)
        
            guard Int(index) < graphPoints.count else { fatalError() }
            let selectedIndex = Int(index)
   
    return (selectedIndex, currentPlot, selectedYPos)
    }
    
    func getYPos(index: CGFloat) -> CGFloat {
        let indexToInt = Int(index) == graphPoints.count - 1 ? graphPoints.count - 2 : Int(index)
        let m = (graphPoints[indexToInt + 1].y - graphPoints[indexToInt].y)
        let selectedYPos = CGFloat(m) * index.truncatingRemainder(dividingBy: 1) + CGFloat(graphPoints[Int(index)].y)
        return selectedYPos
    }
}
