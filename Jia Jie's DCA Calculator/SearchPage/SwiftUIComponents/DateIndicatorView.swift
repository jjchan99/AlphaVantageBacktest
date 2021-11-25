//
//  DateIndicatorView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 30/10/21.
//

import Foundation
import SwiftUI

struct DateIndicatorView: View {
    @EnvironmentObject var viewModel: GraphViewModel
    
    var body: some View {
        if viewModel.shouldDrawGraph ?? false {
            let dateDisplay = DateIndicator(selectedIndex: viewModel.selectedIndex ?? 0, mostRecentDate: viewModel.results.last!.month, result: viewModel.results).showDate()
            Text("\(dateDisplay)")
                .font(.system(size: CGFloat(15).hScaled()))
                .bold()
                .onChange(of: viewModel.id) { _ in
                    viewModel.selectedIndex = nil
                }
        }
    }
}
