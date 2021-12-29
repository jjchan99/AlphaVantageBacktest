//
//  SelectionTab.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/11/21.
//

import Foundation
import SwiftUI

struct CustomTabView: View {
    
    @EnvironmentObject var viewModel: TabViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.selectedIndex = 0
                viewModel.index0tapped!()
            }) {
                Image(systemName: "house").foregroundColor(viewModel.selectedIndex == 0 ? .black : .gray).padding(.horizontal)
            }
            Spacer(minLength: Dimensions.width/4)
            Button(action: {
                viewModel.selectedIndex = 1
                viewModel.index1tapped!()
            }) {
                Image(systemName: "magnifyingglass").foregroundColor(viewModel.selectedIndex == 1 ? .black : .gray).padding(.horizontal)
            }
            Spacer(minLength: Dimensions.width/4)
            Button(action: {
                viewModel.selectedIndex = 2
                viewModel.index2tapped!()
            }) {
                Image(systemName: "plus.circle").foregroundColor(viewModel.selectedIndex == 2 ? .black : .gray).padding(.horizontal)
            }
        }
        .padding(.init(top: 0, leading: .init(10).wScaled(), bottom: 0, trailing: .init(10).wScaled()))
        .background(Color.white)
        .clipShape(Capsule())
        .frame(height: 0.05 * Dimensions.height)
        
    }
}
