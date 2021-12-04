//
//  SingleCandleView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 18/11/21.
//

import Foundation
import SwiftUI

struct SingleCandleView: View {
    @EnvironmentObject var viewModel: CandleViewModel
    
    let green: Color = .init(#colorLiteral(red: 0.1223538027, green: 0.7918281948, blue: 0.5171614195, alpha: 1))
    let red: Color = .init(#colorLiteral(red: 1, green: 0.001286943396, blue: 0.07415488759, alpha: 1))
    
    private func getOffset(idx: Int) -> CGPoint {
    let candles: [Candle] = viewModel.charts!.candles
    let ultimateRange = viewModel.charts!.analysis.ultimateMaxMinRange.range
    let ultimateMax = viewModel.charts!.analysis.ultimateMaxMinRange.max
        
    let shareOfHeight = CGFloat(candles[idx].data.range()) / CGFloat(ultimateRange) * viewModel.height
    let columns: CGFloat = viewModel.charts!.columns
    let xPosition = idx == 0 ? viewModel.padding : (columns * CGFloat(idx)) + viewModel.padding
    let scaleFactor = viewModel.height / shareOfHeight
    let x: CGFloat = -1 * xPosition
    let y = scaleFactor * -CGFloat((abs(candles[idx].data.high - ultimateMax)) / ultimateRange) * viewModel.height
        return .init(x: x, y: y)
    }
    
    private func transform(idx: Int) -> CGPoint {
        let candles: [Candle] = viewModel.charts!.candles
        let range = viewModel.charts!.analysis.ultimateMaxMinRange.range
        let shareOfHeight = CGFloat(candles[idx].data.range()) / CGFloat(range) * viewModel.height
        let scaleFactor = viewModel.height / shareOfHeight
        let xStretch: CGFloat = 20 / viewModel.charts!.spacing
        return .init(x: xStretch, y: scaleFactor)
    }
    
    
    @ViewBuilder func buildCandle(candle: Candle, idx: Int) -> some View {
      
        let candles: [Candle] = viewModel.charts!.candles
        let color: Color = candles[idx].data.green() ? green : red
        let transform = transform(idx: idx)
        let getOffset = getOffset(idx: idx)
        let x = transform.x * getOffset.x + (viewModel.width - viewModel.padding)
        let y = getOffset.y

        let stick = candle.stick.applying(.init(scaleX: transform.x, y: transform.y))
        let body = candle.body.applying(.init(scaleX: transform.x, y: transform.y))
        
        color
            .mask(body)
            .offset(x: x)
            .offset(y: y)
        body
            .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .fill(color)
            .offset(x: x)
            .offset(y: y)
        stick
            .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .fill(color)
            .offset(x: x)
            .offset(y: y)
        
    }
    
    
    var body: some View {
        if viewModel.charts != nil {
        ZStack {
            let candles = viewModel.charts!.candles
            let idx = viewModel.selectedIndex
            if idx != nil {
                buildCandle(candle: candles[idx!], idx: idx!)
                VStack(alignment: .trailing) {
                    Text("stamp: \(candles[idx!].data.stamp)")
                    Text("open: \(candles[idx!].data.open)")
                    Text("high: \(candles[idx!].data.high)")
                    Text("low: \(candles[idx!].data.low)")
                    Text("close: \(candles[idx!].data.close)")
                    Text("change: \(candles[idx!].data.percentageChange ?? 0)")
                    Text("movingAverage: \(candles[idx!].data.movingAverage)")
                    }
                }
            }
           .position(x: viewModel.width)
        }
        }
    }
