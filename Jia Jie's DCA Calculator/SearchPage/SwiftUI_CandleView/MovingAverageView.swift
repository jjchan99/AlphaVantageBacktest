//
//  MovingAverageView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/11/21.
//

import Foundation
import SwiftUI

struct MovingAverageView: View {
    
    @EnvironmentObject var viewModel: CandleViewModel
    
    var body: some View {
        if viewModel.charts != nil {
            viewModel.charts!.movingAverageChart.path
                .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
    }
}
