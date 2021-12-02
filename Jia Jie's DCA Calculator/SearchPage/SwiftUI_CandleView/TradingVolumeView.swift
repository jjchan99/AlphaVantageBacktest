//
//  TradingVolumeView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/11/21.
//

import Foundation
import SwiftUI

struct TradingVolumeView: View {
    
    @EnvironmentObject var viewModel: CandleViewModel
    var render: Path?

    
    var body: some View {
        ZStack {
        if viewModel.charts != nil {
            Color.gray
                .mask(viewModel.charts!.volumeChart)
        }
        }
    }
}
