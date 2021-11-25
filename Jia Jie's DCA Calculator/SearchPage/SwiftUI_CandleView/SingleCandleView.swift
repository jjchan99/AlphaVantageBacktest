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
        let maxWidth = 0.03 * viewModel.width
        var spacing = (1/3) * (viewModel.width / CGFloat(viewModel.candles!.count - 1)) > maxWidth ? maxWidth : (1/3) * (viewModel.width / CGFloat(viewModel.candles!.count - 1))
        spacing = (viewModel.width / CGFloat(viewModel.candles!.count - 1)) <= 5.0 ? 1 : spacing
//        print("spacing: \(spacing)")
        return spacing
    }
    
    @ViewBuilder func buildCandle(candle: Candle, idx: Int) -> some View {
       
        let candles = viewModel.candles
        let color: Color = candles![idx].data.green ? Color.green : Color.red
        let range = viewModel.renderer!.dependencies.analysis.range
        let shareOfHeight = CGFloat(candles![idx].data.range) / CGFloat(range) * viewModel.height
        let scaleFactor = viewModel.height / shareOfHeight
        
        let candles = viewModel.candles
        let pillars = viewModel.width / CGFloat(viewModel.candles!.count - 1)
        let xPosition = idx == 0 ? viewModel.padding : (pillars * CGFloat(idx)) + viewModel.padding
        let x: CGFloat = 0
        let y: CGFloat = 0
//        let xStretch: CGFloat = 20 / getSpacing()
     
       
      
        let y = scaleFactor * -CGFloat((abs(candles![idx].data.high - viewModel.renderer!.dependencies.analysis.max)) / viewModel.renderer!.dependencies.analysis.range) * viewModel.height
        
        let stick = candle.stick.applying(.init(scaleX: 1, y: scaleFactor))
        let body = candle.body.applying(.init(scaleX: 1, y: scaleFactor))
        
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
        if viewModel.candles != nil {
        ZStack {
            let candles = viewModel.candles!
            let idx = viewModel.selectedIndex
            if idx != nil {
                buildCandle(candle: candles[idx!], idx: idx!)
                VStack(alignment: .trailing) {
                    Text("stamp: \(candles[idx!].data.stamp)")
                    Text("open: \(candles[idx!].data.open)")
                    Text("high: \(candles[idx!].data.high)")
                    Text("low: \(candles[idx!].data.low)")
                    Text("close: \(candles[idx!].data.close)")
                    }
                }
            }
           .position(x: viewModel.width)
        }
        }
    }
