//
//  Charts.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/1/22.
//

import Foundation
import CoreGraphics
import SwiftUI

//MARK: Render Client: This is similar to a composite with flat hierarchy.

struct Frame {
    init(count: Int, height: CGFloat, width: CGFloat, padding: CGFloat) {
        self.height = height
        self.width = width
        self.padding = padding
    
        adjustedWidth = width - (2 * padding)
        horizontalJumpPerIndex = adjustedWidth / (count == 1 ? CGFloat(1) : CGFloat(count - 1))
        print("horizontalJumpPerIndex: \(horizontalJumpPerIndex)")
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
    init?(max: T, min: T) {
        guard max > min else { return nil }
        self.max = max
        self.min = min
    }
    
    let max: T
    let min: T
    var range: T {
        abs(max - min)
    }
}

protocol RenderState {
    var frame: Frame { get }
    func updateState(index: Int)
    func view() -> DraggableView
    func getY(index: Int) -> CGFloat
    func getY(index: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat)
    func testVariance(index: Int)
}

extension RenderState {
    func getY(index: Int) -> CGFloat {
        return 1
    }
    func getY(index: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        return (1, 1, 1, 1)
    }
    
    func testVariance(index: Int) {
        
    }
}

protocol OpHLC: Plottable {
//    associatedtype T where T: CustomNumeric
    var open: T { get }
    var high: T { get }
    var low: T { get }
    var close: T { get }
}

struct Y {
    static func cgf<T: CustomNumeric>(_ value: T) -> CGFloat {
        return CGFloat(fromNumeric: value)
    }
    
    static func get<T: CustomNumeric>(point: T, mmr: MMR<T>, frame: Frame) -> CGFloat {
        let deviation = abs(point - mmr.max)
        let share = cgf(deviation / mmr.range)
        let scaled = share * frame.height
        return scaled
    }
    
    static func reverseGet<T: CustomNumeric>(scaled: CGFloat, mmr: MMR<T>, frame: Frame) -> CGFloat {
        let share = scaled / frame.height
        let deviation = share * cgf(mmr.range)
        let point = deviation - cgf(mmr.max)
        return abs(point)
    }
    
    static func get<T: OpHLC>(point: T, mmr: MMR<T.T>, frame: Frame) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let open = point.open
        let high = point.high
        let low = point.low
        let close = point.close
//        let yOpen = (abs(cgf(open - mmr.max)) / cgf(mmr.range)) * frame.height
//        let yHigh = (abs(cgf(high - mmr.max)) / cgf(mmr.range)) * frame.height
//        let yLow = (abs(cgf(low - mmr.max)) / cgf(mmr.range)) * frame.height
//        let yClose = (abs(cgf(close - mmr.max)) / cgf(mmr.range)) * frame.height
        
        let yOpen = get(point: open, mmr: mmr, frame: frame)
        let yHigh = get(point: high, mmr: mmr, frame: frame)
        let yLow = get(point: low, mmr: mmr, frame: frame)
        let yClose = get(point: close, mmr: mmr, frame: frame)
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
    
    func startRender(completion: () -> Void) {
        for (index, data) in data.enumerated() {
            for (_, state) in render {
                state.updateState(index: index)
            }
        }
        completion()
    }
}

class LineState<Object: Plottable>: RenderState {
    func getY(index: Int) -> CGFloat {
        Y.get(point: data[index][keyPath: keyPath], mmr: mmr, frame: frame)
    }
    
    let data: [Object]
    let frame: Frame
    let mmr: MMR<Object.T>
    let keyPath: KeyPath<Object, Object.T>
    let color: Color = .init(#colorLiteral(red: 0.1223538027, green: 0.7918281948, blue: 0.5171614195, alpha: 1))
    
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
        if index > 0 {
            path.addLine(to: point)
            area.addLine(to: point)
        }
        path.move(to: point)
        area.move(to: point)
    }
    
    func view() -> DraggableView {
        let copy = self
        return DraggableView(state: self) {
            AnyView(
            copy.path
                .strokedPath(StrokeStyle(lineWidth: 0.5, lineCap: .round, lineJoin: .round))
                .fill(copy.color)
            )
        }
    }
    
    func testVariance(index: Int) {
        let scaled = Y.get(point: data[index][keyPath: self.keyPath], mmr: self.mmr, frame: self.frame)
        let y = Y.reverseGet(scaled: scaled, mmr: self.mmr, frame: self.frame)
        let variance = Y.cgf(data[index][keyPath: self.keyPath]) - y
        guard variance < 0.01 else {
            print("""
                  scaled: \(scaled)
                  reverseGet: \(y)
                  y: \(data[index][keyPath: self.keyPath])
                  variance: \(Y.cgf(data[index][keyPath: self.keyPath]) - y)
                  """)
        fatalError()
        }
    }
}

class CandleState<Object: OpHLC & Plottable>: RenderState {
    func getY(index: Int) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        Y.get(point: data[index], mmr: mmr, frame: frame)
    }
   
    let data: [Object]
    let frame: Frame
    let mmr: MMR<Object.T>
    let keyPath: KeyPath<Object, Object.T>
    let green: Color = .init(#colorLiteral(red: 0.1223538027, green: 0.7918281948, blue: 0.5171614195, alpha: 1))
    let red: Color = .init(#colorLiteral(red: 1, green: 0.001286943396, blue: 0.07415488759, alpha: 1))
    
    init(data: [Object], frame: Frame, mmr: MMR<Object.T>, setKeyPath keyPath: KeyPath<Object, Object.T>) {
        self.data = data
        self.frame = frame
        self.mmr = mmr
        self.keyPath = keyPath
    }
    
    var stick: [Path] = []
    var body: [Path] = []
    
    func scaledToDataCount(_ cgf: CGFloat) -> CGFloat {
        cgf.wScaled() / (CGFloat(1) + (CGFloat(data.count) * CGFloat(0.01)))
    }
    
    func updateState(index: Int) {
        var stick = Path()
        var body = Path()
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
        
        self.stick.append(stick)
        self.body.append(body)
    }
    
    func view() -> DraggableView {
        let copy = self
        return DraggableView(state: self) {
            AnyView(
            ZStack {
                ForEach(0..<copy.data.count, id: \.self) { index in
                let color = copy.data[index].close > copy.data[index].open ? copy.green : copy.red
                color
                    .mask(copy.body[index])
                copy.body[index]
                        .strokedPath(StrokeStyle(lineWidth: copy.scaledToDataCount(2.5), lineCap: .round, lineJoin: .round))
                    .fill(color)
                copy.stick[index]
                        .strokedPath(StrokeStyle(lineWidth: copy.scaledToDataCount(2.5), lineCap: .round, lineJoin: .round))
                    .fill(color)
            }
            }
            )
    }
}
}

class BarState<Object: Plottable>: RenderState {
    
    func getY(index: Int) -> CGFloat {
        Y.get(point: data[index][keyPath: keyPath], mmr: mmr, frame: frame)
    }
    
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
    
    func updateState(index: Int) {
        let x = X.get(index: index, frame: frame)
        let y = Y.get(point: data[index][keyPath: keyPath], mmr: mmr, frame: frame)
        path.move(to: .init(x: x - frame.spacing(), y: y))
        path.addLine(to: .init(x: x + frame.spacing(), y: y))
        path.addLine(to: .init(x: x + frame.spacing(), y: frame.height))
        path.addLine(to: .init(x: x - frame.spacing(), y: frame.height))
        path.addLine(to: .init(x: x - frame.spacing(), y: y))
        path.closeSubpath()
    }
    
    func view() -> DraggableView {
        let copy = self
        return DraggableView(state: self) {
        AnyView(
            Color.gray
            .mask(copy.path)
        )
        }
    }
}

struct Draggable: ViewModifier {
    let state: RenderState
    
    
    func updateLocation(_ value: DragGesture.Value) {
        guard value.location.x >= state.frame.padding && value.location.x <= state.frame.width - state.frame.padding else { return }
//        print("xPos: \(value.location.x - state.frame.padding)")
        let sectionWidth: CGFloat = state.frame.horizontalJumpPerIndex
        let index = Int(floor((value.location.x - state.frame.padding) / sectionWidth))
        
//        print("index: \(index)")
        
//        guard index == 0 else {
//            fatalError()
//        }
        
        state.testVariance(index: index)
        
        let y: CGFloat = state.getY(index: index)
        xPos = value.location.x
        
        let m = (state.getY(index: index + 1) - y)
        yPos = CGFloat(m) * CGFloat(index).truncatingRemainder(dividingBy: 1) + y
        
        //MARK: TO DO - Quadratic curve for draggable 
    }
    
    @State var xPos: CGFloat = 0
    @State var yPos: CGFloat = 0
    
    func body(content: Content) -> some View {
        ZStack {
            content
        
            Circle()
                .fill(Color.black)
                .frame(width: 22, height: 22)
                .overlay (
                Circle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
                )
                .position(x: xPos + state.frame.padding, y: yPos)
                .gesture(DragGesture().onChanged({ value in
                   updateLocation(value)
                })
                    
                
                
                
                )
        }
    }
}

extension DraggableView {
    func draggable() -> some View {
        modifier(
            Draggable(state: self.state)
        )
    }
}

struct DraggableView: View {
    
    let state: RenderState
    let content: () -> AnyView
    init(state: RenderState, content: @escaping () -> AnyView) {
        self.state = state
        self.content = content
    }
    
    var body: some View {
        content()
    }
}
