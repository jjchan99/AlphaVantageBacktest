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
    }
    
    let height: CGFloat
    let width: CGFloat
    let padding: CGFloat
    var adjustedWidth: CGFloat
    var horizontalJumpPerIndex: CGFloat
}

extension Frame {
    func spacing() -> CGFloat {
        horizontalJumpPerIndex <= 5.0 ? 1 : (0.5) * horizontalJumpPerIndex > maxWidth() ? maxWidth() : (0.5) * horizontalJumpPerIndex
    }
    
    func maxWidth() -> CGFloat {
        0.06 * adjustedWidth
    }
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

protocol OpHLC {
    associatedtype T where T: CustomNumeric
    var open: T { get }
    var high: T { get }
    var low: T { get }
    var close: T { get }
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
    
    static func get<T: OpHLC>(point: T, mmr: MMR<T.T>, frame: Frame) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let open = point.open
        let high = point.high
        let low = point.low
        let close = point.close
        let yOpen = (abs(cgf(open - mmr.max)) / cgf(mmr.range)) * frame.height
        let yHigh = (abs(cgf(high - mmr.max)) / cgf(mmr.range)) * frame.height
        let yLow = (abs(cgf(low - mmr.max)) / cgf(mmr.range)) * frame.height
        let yClose = (abs(cgf(close - mmr.max)) / cgf(mmr.range)) * frame.height
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
}

struct X {
    static func get(index: Int, frame: Frame) -> CGFloat {
        return index == 0 ? frame.padding : (frame.horizontalJumpPerIndex * CGFloat(index)) + frame.padding
    }
}

protocol Plottable {
    associatedtype T where T: CustomNumeric
}

class RenderClient<Object: Plottable> {
    let data: [Object]
    
    init(data: [Object]) {
        self.data = data
    }
    
    var render: [String: RenderState] = [:]
    
    func add(title: String, state: RenderState) {
        render[title] = state
    }
    
    func startRender() {
        for (index, data) in data.enumerated() {
            for (_, state) in render {
                state.updateState(index: index)
            }
        }
    }
}

class LineState<Object: Plottable>: RenderState {
    
    let data: [Object]
    let frame: Frame
    let mmr: MMR<Object.T>
    let keyPath: KeyPath<Object, Object.T>
    
    init(data: [Object], frame: Frame, mmr: MMR<Object.T>, setKeyPath keyPath: KeyPath<Object, Object.T>) {
        self.data = data
        self.frame = frame
        self.mmr = mmr
        self.keyPath = keyPath
    }
    
    var path = Path()
    var area = Path()
    
    func updateState(index: Int) {
        let x = X.get(index: index, frame: frame)
        let y = Y.get(point: data[index][keyPath: keyPath], mmr: mmr, frame: frame)
        let point = CGPoint(x: x, y: y)
        path.move(to: point)
        area.move(to: point)
    }
}

class CandleState<Object: OpHLC & Plottable>: RenderState {
    
    let data: [Object]
    let frame: Frame
    let mmr: MMR<Object.T>
    let keyPath: KeyPath<Object, Object.T>
    
    init(data: [Object], frame: Frame, mmr: MMR<Object.T>, setKeyPath keyPath: KeyPath<Object, Object.T>) {
        self.data = data
        self.frame = frame
        self.mmr = mmr
        self.keyPath = keyPath
    }
    
    var stick = Path()
    var body = Path()
    
    func updateState(index: Int) {
        let green = data[index].close > data[index].open
        let x = X.get(index: index, frame: frame)
        let y = Y.get(point: data[index], mmr: mmr, frame: frame)
        body.move(to: .init(x: x - (0.5 * frame.spacing()), y: green ? y.close : y.open))
        body.addLine(to: .init(x: x + (0.5 * frame.spacing()), y: green ? y.close : y.open))
        body.addLine(to: .init(x: x + (0.5 * frame.spacing()), y: green ? y.open : y.close))
        body.addLine(to: .init(x: x - (0.5 * frame.spacing()), y: green ? y.open : y.close))
        body.addLine(to: .init(x: x - (0.5 * frame.spacing()), y: green ? y.close : y.open))
     
        stick.move(to: .init(x: x, y: y.high))
        stick.addLine(to: .init(x: x, y: y.low))
      
    }
}
