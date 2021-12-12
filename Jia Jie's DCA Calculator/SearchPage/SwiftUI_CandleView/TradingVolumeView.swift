//
//  TradingVolumeView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/11/21.
//

import Foundation
import SwiftUI

struct TradingVolumeView: View {
    
    @EnvironmentObject var viewModel: CandleViewModel<OHLCCloudElement>
    var render: Path?

    
    var body: some View {
        ZStack {
        if viewModel.chartsOutput != nil {
            Color.gray
                .mask(viewModel.chartsOutput!.bars["volume"]!)
        }
        }
    }
}
