//
//  BackgroundOverlay.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//

import Foundation
import SwiftUI

struct BackgroundView: View {
    
    @EnvironmentObject var viewModel: CandleViewModel<OHLCCloudElement>
    
    var body: some View {
        ForEach(0..<4) { idx in
                Line().path(in: CGRect(x: viewModel.padding * 0.5, y: viewModel.height/4 * CGFloat(idx), width: viewModel.width, height: 0))
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                .frame(height: 1)
                .opacity(0.2)
            }
            .position(x: viewModel.width * 0.5, y: 0)
    }
    
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.minY))
        return path
    }
}
