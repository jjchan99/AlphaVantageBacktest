//
//  YAxisView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 5/10/21.
//

import Foundation
import SwiftUI

struct YAxisView: View {
    
    @EnvironmentObject var viewModel: GraphViewModel
    @Binding var mode: Mode
    var min: Bool
    
    init(mode: Binding<Mode>, min: Bool) {
        self.min = min
        self._mode = mode
    }
    
    @ViewBuilder var body: some View {
        let maxY = viewModel.meta!.mode(mode: mode, min: false)
        let minY = viewModel.meta!.mode(mode: mode, min: true)

        ZStack {
            let maxY = maxY < 0 ? 0 : maxY
            !min
            ? Text(mode.format(double: maxY))
                .font(.system(size: CGFloat(15).hScaled()))
            : Text("\(minY < 0 ? mode.format(double: minY) : "\(mode.format(double: 0))")")
                .font(.system(size: CGFloat(15).hScaled()))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
         
        }
    }
