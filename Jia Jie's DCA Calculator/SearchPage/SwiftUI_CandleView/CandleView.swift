//
//  CandleView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

struct CandleView: View {
    @EnvironmentObject var viewModel: CandleViewModel<OHLCCloudElement>
    
    let green: Color = .init(#colorLiteral(red: 0.1223538027, green: 0.7918281948, blue: 0.5171614195, alpha: 1))
    let red: Color = .init(#colorLiteral(red: 1, green: 0.001286943396, blue: 0.07415488759, alpha: 1))
    
    func scaleFactor(_ a: CGFloat) -> CGFloat {
        let sf = a / (CGFloat(viewModel.chartsOutput!.candles["daily"]!.count) / 5)
        return sf < 1 ? 1 : sf
    }
 
    var body: some View {
        ZStack {
        BackgroundView().environmentObject(viewModel)
        if viewModel.RC != nil {
            
            VStack(spacing: 0) {
            CandleModeView().environmentObject(viewModel)
              
            viewModel.RC!.render["dailyTicker"]!.view()
            viewModel.RC!.render["movingAverage"]!.view()
                    
                
            viewModel.RC!.render["volume"]!.view()
            SingleCandleView()
                .environmentObject(viewModel)
                .frame(width: viewModel.width, height: viewModel.height, alignment: .center)
                .position(y: viewModel.height * 2)
            }

//            TradingVolumeView().environmentObject(viewModel)
//                .frame(width: viewModel.width, height: viewModel.height)
//                .overlay(CandleIndicatorView()
//                    .environmentObject(viewModel)
//                )
            
            }
        }
        }
       
       
}


extension AnyTransition {
    static var moveAndFade: AnyTransition {
        AnyTransition.move(edge: .trailing)
    }
}

