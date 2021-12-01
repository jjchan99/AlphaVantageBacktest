//
//  ControlPoints.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 1/12/21.
//

import Foundation
import CoreGraphics

struct ControlPoint {
    
    let scaleFactor: CGFloat = 0.7
    
    init(centerPoint: CGPoint, previousPoint: CGPoint, nextPoint: CGPoint) {
        self.centerPoint = centerPoint
        self.previousPoint = previousPoint
        self.nextPoint = nextPoint
    }
    
    let centerPoint: CGPoint
    let previousPoint: CGPoint
    let nextPoint: CGPoint
    
    func staticControlPoints() -> (staticPoint1: CGPoint, staticPoint2: CGPoint) {
        let x1 = previousPoint.x + (centerPoint.x - previousPoint.x) * (1 - scaleFactor)
        let y1 = previousPoint.y + (centerPoint.y - previousPoint.y) * (1 - scaleFactor)
        let controlPoint1: CGPoint = .init(x: x1, y: y1)
        
        let x2 = centerPoint.x + (nextPoint.x - centerPoint.x) * (scaleFactor)
        let y2 = centerPoint.y + (nextPoint.y - centerPoint.y) * (scaleFactor)
        let controlPoint2: CGPoint = .init(x: x2, y: y2)
        return (controlPoint1, controlPoint2)
    }
    
    private func getControlPoints() -> (controlPoint1: CGPoint, controlPoint2: CGPoint) {
        let x1 = previousPoint.x + (centerPoint.x - previousPoint.x) * scaleFactor
        let y1 = previousPoint.y + (centerPoint.y - previousPoint.y) * scaleFactor
        let controlPoint1: CGPoint = .init(x: x1, y: y1)
        
        let x2 = centerPoint.x + (nextPoint.x - centerPoint.x) * (1 - scaleFactor)
        let y2 = centerPoint.y + (nextPoint.y - centerPoint.y) * (1 - scaleFactor)
        let controlPoint2: CGPoint = .init(x: x2, y: y2)
        return (controlPoint1, controlPoint2)
    }
    
    func translateControlPoints() -> (controlPoint1: CGPoint, controlPoint2: CGPoint) {
        let cp = getControlPoints()
        let MM: CGPoint = .init(x: 2 * centerPoint.x - cp.controlPoint1.x, y: 2 * centerPoint.y - cp.controlPoint1.y)
        let NN: CGPoint = .init(x: 2 * centerPoint.x - cp.controlPoint2.x, y: 2 * centerPoint.y - cp.controlPoint2.y)
        
        let translatedControlPoint1 = CGPoint(x: (NN.x + cp.controlPoint1.x)/2, y: (NN.y + cp.controlPoint1.y)/2)
        let translatedControlPoint2 = CGPoint(x: (MM.x + cp.controlPoint2.x)/2, y: (MM.y + cp.controlPoint2.y)/2)
        
        return ((controlPoint1: translatedControlPoint1, controlPoint2: translatedControlPoint2))
    }
    
}
