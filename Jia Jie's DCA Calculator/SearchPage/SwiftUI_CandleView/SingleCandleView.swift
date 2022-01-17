//
//  SingleCandleView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 18/11/21.
//

import Foundation
import SwiftUI

//struct SingleCandleView: View {
//    @EnvironmentObject var viewModel: CandleViewModel
//
//    let green: Color = .init(#colorLiteral(red: 0.1223538027, green: 0.7918281948, blue: 0.5171614195, alpha: 1))
//    let red: Color = .init(#colorLiteral(red: 1, green: 0.001286943396, blue: 0.07415488759, alpha: 1))
//
//    @ViewBuilder func buildCandle(candle: Candle<OHLCCloudElement>, idx: Int) -> some View {
//
//        let candles: [Candle<OHLCCloudElement>] = viewModel.chartsOutput!.candles["daily"]!
//        let color: Color = candles[idx].data.green() ? green : red
//        let transform = viewModel.singleCandleRenderer!.transform(idx: idx)
//        let getOffset = viewModel.singleCandleRenderer!.getOffset(idx: idx)
//        let x = transform.x * getOffset.x + (viewModel.width - viewModel.padding)
//        let y = getOffset.y
//
//        let stick = candle.stick.applying(.init(scaleX: transform.x, y: transform.y))
//        let body = candle.body.applying(.init(scaleX: transform.x, y: transform.y))
//
//        color
//            .mask(body)
//            .offset(x: x)
//            .offset(y: y)
//        body
//            .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
//            .fill(color)
//            .offset(x: x)
//            .offset(y: y)
//        stick
//            .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
//            .fill(color)
//            .offset(x: x)
//            .offset(y: y)
//
//    }
//
//
//    var body: some View {
//        if viewModel.chartsOutput != nil {
//        ZStack {
//            let candles = viewModel.chartsOutput!.candles["daily"]!
//            let idx = viewModel.selectedIndex
//            if idx != nil {
//                buildCandle(candle: candles[idx!], idx: idx!)
//                VStack(alignment: .trailing) {
//                    Text("stamp: \(candles[idx!].data.stamp)")
//                    Text("open: \(candles[idx!].data.open)")
//                    Text("high: \(candles[idx!].data.high)")
//                    Text("low: \(candles[idx!].data.low)")
//                    Text("close: \(candles[idx!].data.close)")
//                    Text("change: \(candles[idx!].data.percentageChange ?? 0)")
//                    Text("movingAverage: \(candles[idx!].data.movingAverage[200]!)")
//                    }
//                }
//            }
//           .position(x: viewModel.width)
//        }
//        }
//}
