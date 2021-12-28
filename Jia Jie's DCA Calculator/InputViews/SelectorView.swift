//
//  SelectorView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 28/12/21.
//

import Foundation
import SwiftUI
struct SelectorView: View {
    @EnvironmentObject var vm: InputViewModel
    @State private var isPresented: Bool = false
    @Binding var rootIsActive : Bool
    
    var body: some View {
                Form {
        Section {
            List(0..<vm.titles.count, id: \.self) { idx in
                Button() {
                    isPresented = true
                } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                    VStack(alignment: .leading) {
                        Text(vm.titles[idx])
                            .font(.caption.bold())
                        Text(vm.description[idx])
                            .font(.caption2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
                .frame(height: 0.1 * Dimensions.height)
                }
                .sheet(isPresented: $isPresented) {
                    PopupView(shouldPopToRootView: self.$rootIsActive, titleIdx: idx, frame: 0)
                }
                .foregroundColor(.black)
                
            }
        } header: {
            Text("Trading Indicators")
        }
        Section {
            List(0..<vm.titlesSection2.count, id: \.self) { idx in
                Button() {
                    isPresented = true
                } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                    VStack(alignment: .leading) {
                        Text(vm.titlesSection2[idx])
                            .font(.caption.bold())
                        Text(vm.descriptionSection2[idx])
                            .font(.caption2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
                .frame(height: 0.1 * Dimensions.height)
                }
                .sheet(isPresented: $isPresented) {
                    PopupView(shouldPopToRootView: self.$rootIsActive, titleIdx: idx, frame: 1)
                }
                .foregroundColor(.black)
                
            }
        } header: {
            Text("Custom targets")
        }
    }
    }
    
}
