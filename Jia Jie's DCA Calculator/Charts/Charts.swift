//
//  Charts.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/1/22.
//

import Foundation
import CoreGraphics
import SwiftUI

struct Frame {
    init(count: Int, height: CGFloat, width: CGFloat, padding: CGFloat) {
        self.height = height
        self.width = width
        self.padding = padding
    
        adjustedWidth = width - (2 * padding)
        horizontalJumpPerIndex = adjustedWidth / CGFloat(count - 1)
        maxWidth = 0.06 * adjustedWidth
        spacing = horizontalJumpPerIndex <= 5.0 ? 1 : (0.5) * horizontalJumpPerIndex > maxWidth ? maxWidth : (0.5) * horizontalJumpPerIndex
    }
    
    let height: CGFloat
    let width: CGFloat
    let padding: CGFloat
    
    var maxWidth: CGFloat
    var spacing: CGFloat
    var adjustedWidth: CGFloat
    var horizontalJumpPerIndex: CGFloat
}

struct MMR<T: CustomNumeric> {
    let max: T
    let min: T
    var range: T {
        abs(max - min)
    }
}

protocol RenderState {
    func updateState(index: Int)
}

struct Y {
    static private func cgf<T: CustomNumeric>(_ value: T) -> CGFloat {
        return CGFloat(fromNumeric: value)
    }
    
    static func get<T: CustomNumeric>(point: T, mmr: MMR<T>, frame: Frame) -> CGFloat {
        let deviation = abs(point - mmr.max)
        let share = cgf(deviation / mmr.range)
        let scaled = share * frame.height
        return scaled
    }
}

struct X {
    static func get(index: Int, frame: Frame) -> CGFloat {
        return index == 0 ? frame.padding : (frame.horizontalJumpPerIndex * CGFloat(index)) + frame.padding
    }
}

protocol Plottable {
    associatedtype T where T: CustomNumeric
    static var keyPath: KeyPath<Self, T>? { get set }
}

class RenderClient {
    
}

class LineState<Object: Plottable>: RenderState {
    
    let data: [Object]
    let frame: Frame
    let mmr: MMR<Object.T>
    
    init(data: [Object], frame: Frame, mmr: MMR<Object.T>, setKeyPath: KeyPath<Object, Object.T>) {
        self.data = data
        self.frame = frame
        self.mmr = mmr
        Object.keyPath = setKeyPath
    }
    
    var path = Path()
    var area = Path()
    
    func getXPosition() {
        
    }
    
    func getYPosition() {
        
    }
    
    func updateState(index: Int) {
        let x = X.get(index: index, frame: frame)
        let y = Y.get(point: data[index][keyPath: Object.keyPath!], mmr: mmr, frame: frame)
    }
}
