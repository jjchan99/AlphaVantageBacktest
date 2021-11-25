//
//  FinancialsView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import SwiftUI
import CoreGraphics
import Foundation

struct ROEView: View {
    
    let purple: Color = Color(#colorLiteral(red: 0.6751086167, green: 0.5308660938, blue: 1, alpha: 1))
    
    @EnvironmentObject var viewModel: FinancialsViewModel
    
    var body: some View {
        if viewModel.bs != nil && viewModel.pl != nil {
            let financials = FinancialModel(balanceSheet: viewModel.bs!, incomeStatement: viewModel.pl!, earnings: nil)
            let ROERender = BarGraphRenderer.init(width: viewModel.width, height: viewModel.height, data: financials.getROE().ROE).render()
            let debtToEquity = PieChartRenderer.init(data: financials.getDebtToEquity().debtToEquity, height: viewModel.height, width: viewModel.width).render()
            let workingCapitalRatio = SingleBarRenderer(data: financials.getWorkingCapitalRatio().workingCapital, height: viewModel.height * 0.8, width: .init(0.3 * viewModel.width)).render()[0]
            VStack(spacing: CGFloat(375).hScaled()) {
            
                ZStack {
                    purple
                        .mask(workingCapitalRatio.battery)
                        .offset(x: 20)
                    Color.black
                        .mask(workingCapitalRatio.topHalf)
                        .offset(x: 20)
//            Color.blue
//                .mask(ROERender.area)
//                .opacity(0.5)
//                .offset(x: (CGFloat(15).wScaled()))
                }
            TabView {
            Group {
            ForEach(debtToEquity.indices) { idx in
            ZStack {
            debtToEquity[idx].slice1
                .fill(Color.pink)
            debtToEquity[idx].slice2
                .fill(Color.blue)
            }
            .overlay(Circle().frame(width: viewModel.width/2, height: viewModel.height/2).foregroundColor(.white))
            }
            }
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(width: viewModel.width, height: viewModel.height)
        }
        }
    }
}
