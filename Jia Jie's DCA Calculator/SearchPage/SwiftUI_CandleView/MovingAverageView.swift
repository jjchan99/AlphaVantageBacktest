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
    let color: Color = .init(#colorLiteral(red: 0.1223538027, green: 0.7918281948, blue: 0.5171614195, alpha: 1))
    var body: some View {
        if viewModel.charts != nil {
            viewModel.charts!.movingAverageChart.path
                .strokedPath(StrokeStyle(lineWidth: 0.5, lineCap: .round, lineJoin: .round))
                .fill(color)
        }
    }
}
