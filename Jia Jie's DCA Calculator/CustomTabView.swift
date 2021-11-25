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
            Spacer(minLength: viewModel.width/4)
            Button(action: {
                viewModel.selectedIndex = 1
                viewModel.index1tapped!()
            }) {
                Image(systemName: "magnifyingglass").foregroundColor(viewModel.selectedIndex == 1 ? .black : .gray).padding(.horizontal)
            }
            Spacer(minLength: viewModel.width/4)
            Button(action: {
                viewModel.selectedIndex = 2
                viewModel.index2tapped!()
            }) {
                Image(systemName: "questionmark").foregroundColor(viewModel.selectedIndex == 2 ? .black : .gray).padding(.horizontal)
            }
        }
        .background(Color.white)
        .clipShape(Capsule())
        .padding()
    }
}
