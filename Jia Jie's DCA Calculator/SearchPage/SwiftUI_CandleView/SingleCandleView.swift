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
    
    func getSpacing() -> CGFloat {
        viewModel.charts!.spacing
    }
    
    func offsetX(idx: Int) -> CGFloat {
    let columns: CGFloat = viewModel.charts!.columns
    let xPosition = idx == 0 ? viewModel.padding : (columns * CGFloat(idx)) + viewModel.padding
        
    let x: CGFloat = -1 * xPosition + (0.05 * viewModel.width)
    return x
    }
    
    
    @ViewBuilder func buildCandle(candle: Candle, idx: Int) -> some View {
      
        let candles: [Candle] = viewModel.charts!.candles
        let color: Color = candles[idx].data.green() ? Color.green : Color.red
//        let range = viewModel.charts!.analysis.ultimateMaxMinRange.range
//        let shareOfHeight = CGFloat(candles[idx].data.range()) / CGFloat(range) * viewModel.height
//        let scaleFactor = viewModel.height / shareOfHeight
//        let xStretch: CGFloat = 20 / getSpacing()
//        let pillars = viewModel.charts!.columns
//
//        let xPosition = idx == 0 ? viewModel.padding : (pillars * CGFloat(idx)) + viewModel.padding
//
//        let x: CGFloat = -1 * xPosition * xStretch + (0.05 * viewModel.width)
//        let y = scaleFactor * -CGFloat((abs(Double(candles[idx].data.high!)! - range)) / range) * viewModel.height

        let stick = candle.stick
        let body = candle.body
        
      
        color
            .mask(body)
            .offset(x: offsetX(idx: idx))
//            .offset(y: y)
        body
            .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .fill(color)
            .offset(x: offsetX(idx: idx))
//            .offset(y: y)
        stick
            .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            .fill(color)
            .offset(x: offsetX(idx: idx))
//            .offset(y: y)
        
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
                    Text("high: \(candles[idx!].data.high!)")
                    Text("low: \(candles[idx!].data.low!)")
                    Text("close: \(candles[idx!].data.close)")
                    }
                }
            }
           .position(x: viewModel.width)
        }
        }
    }
