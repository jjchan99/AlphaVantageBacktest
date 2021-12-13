//
//  DragGestureModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 13/12/21.
//

import Foundation
import CoreGraphics

struct YDragGesture<T: CustomNumeric> {
    
    let graphPoints: [CGPoint]
    let height: CGFloat
    let width: CGFloat
    let spec: Specifications<T>

    init(graphPoints: [CGPoint], spec: Specifications<T>) {
        self.graphPoints = graphPoints
        self.spec = spec
    }
    
    func updateIndicator(xPos: CGFloat) -> (selectedIndex: Int, currentPlot: String, selectedYPos: CGFloat) {
            var selectedYPos: CGFloat = 0
          
        guard xPos >= 0 && xPos <= spec.width else { fatalError() }
            let sections = spec.columns
            let index = xPos / sections
            if index >= 0 && index <= CGFloat(graphPoints.count - 1) {
                selectedYPos = getYPos(index: index)
            }
        
            let range = spec.max - spec.min
            let getMetaType = type(min: spec.min, max: spec.max)
            let maxY = getMetaType == .allPositive || getMetaType == .negativePositive ? spec.max : spec.min
           
            let scaledY = getMetaType == .allPositive || getMetaType == .negativePositive ? CGFloat(maxY) - (CGFloat(range)/height) * selectedYPos : 0 - (CGFloat(range)/height) * selectedYPos
            let currentPlot = scaledY
        
            guard Int(index) < graphPoints.count else { fatalError() }
            let selectedIndex = Int(index)
   
    return (selectedIndex, currentPlot, selectedYPos)
    }
    
    func updateIndicator(xPos: CGFloat) -> Int {
            let index: CGFloat = xPos / (width / CGFloat(graphPoints.count + 1))
            return Int(floor(index))
    }
    
    private func getYPos(index: CGFloat) -> CGFloat {
        let indexToInt = Int(index) == graphPoints.count - 1 ? graphPoints.count - 2 : Int(index)
        let m = (graphPoints[indexToInt + 1].y - graphPoints[indexToInt].y)
        let selectedYPos = CGFloat(m) * index.truncatingRemainder(dividingBy: 1) + CGFloat(graphPoints[Int(index)].y)
        return selectedYPos
    }
    
    private func type<T: CustomNumeric>(min: T, max: T) -> ChartType {
        let allNegativeOrAllPositive: ChartType = min < 0 && max < 0 ? .allNegative : .allPositive
        let chartType: ChartType = min < 0 && max >= 0 ? .negativePositive : allNegativeOrAllPositive
        return chartType
    }
}
