//
//  CandleView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

struct CandleView: View {
    @EnvironmentObject var viewModel: CandleViewModel
    
    let darkGreen: Color = .init(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
    let darkRed: Color = .init(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1))
    let lightGreen: Color = .init(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1))
    let lightRed: Color = .init(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
    
    func scaleFactor(_ a: CGFloat) -> CGFloat {
        let sf = a / (CGFloat(viewModel.sorted!.count) / 5)
        return sf < 1 ? 1 : sf
    }
 
    var body: some View {
        ZStack {
        if viewModel.charts != nil {
            
            VStack {
            CandleModeView().environmentObject(viewModel)

                ZStack {
                ForEach(0..<viewModel.sorted!.count, id: \.self) { idx in
                    let candles = viewModel.charts!.candles
                    let color: Color = candles[idx].data.green() ? darkGreen : darkRed
                    let selectedColor: Color = candles[idx].data.green() ? lightGreen : lightRed
                    let selected: Bool = idx == viewModel.selectedIndex
              
                if !selected {
                    color
                        .mask(candles[idx].body)
                    candles[idx].body
                        .strokedPath(StrokeStyle(lineWidth: scaleFactor(2.5), lineCap: .round, lineJoin: .round))
                        .fill(color)
                    candles[idx].stick
                        .strokedPath(StrokeStyle(lineWidth: scaleFactor(2.5), lineCap: .round, lineJoin: .round))
                        .fill(color)
                } else {
                    selectedColor
                        .mask(candles[idx].body)
                    candles[idx].body
                        .strokedPath(StrokeStyle(lineWidth: scaleFactor(2.5), lineCap: .round, lineJoin: .round))
                        .fill(selectedColor)
                    candles[idx].stick
                        .strokedPath(StrokeStyle(lineWidth: scaleFactor(2.5), lineCap: .round, lineJoin: .round))
                        .fill(selectedColor)
                }
                
                }
               .overlay(
                MovingAverageView().environmentObject(viewModel)
                )

            SingleCandleView()
                .environmentObject(viewModel)
                .frame(width: viewModel.width, height: viewModel.height, alignment: .center)
                .position(y: viewModel.height * 2)
            }

            TradingVolumeView().environmentObject(viewModel)
                .frame(width: viewModel.width, height: viewModel.height)
                .overlay(CandleIndicatorView()
                    .environmentObject(viewModel)
                )
            }
        } else {
            Text("Nothing to show...")
        }
        }
       
       
    }
}

extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .trailing)
    }
}

