//
//  CandleModeView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/11/21.
//

import Foundation
import SwiftUI

struct CandleModeView: View {
    @EnvironmentObject var viewModel: CandleViewModel<OHLCCloudElement>
    
    var body: some View {
  
        HStack {
            Button(action: {
                viewModel.modeChanged!(.days5)
            }, label: {
                Text("5D")
            })
            Button(action: {
                viewModel.modeChanged!(.months1)
            }, label: {
                Text("1M")
            })
            Button(action: {
                viewModel.modeChanged!(.months3)
            }, label: {
                Text("3M")
            })
            Button(action: {
                viewModel.modeChanged!(.months6)
            }, label: {
                Text("6M")
            })
        }
        .frame(width: viewModel.width)
    }
   
}
