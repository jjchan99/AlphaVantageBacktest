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
    var selectedDictIndex: Int
    
    
    init(rootIsActive: Binding<Bool>, selectedDictIndex: Int) {
        self._rootIsActive = rootIsActive
        self.selectedDictIndex = selectedDictIndex
    }
    
    var body: some View {
                Form {
        Section {
            List(vm.entry ? 0..<vm.entryTitleFrame[0].count : 0..<vm.exitTitleFrame[0].count, id: \.self) { idx in
                Button() {
                    vm.transitionState(key: vm.keysAtSection0[idx])
                    isPresented = true
                } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                    VStack(alignment: .leading) {
                        Text(vm.entry ? vm.entryTitleFrame[0][idx] : vm.exitTitleFrame[0][idx])
                            .font(.caption.bold())
                        Text(vm.entry ? vm.entryDescriptionFrame[0][idx] : vm.exitDescriptionFrame[0][idx])
                            .font(.caption2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
                .frame(height: 0.1 * Dimensions.height)
                }
          
                .foregroundColor(.black)
                
            }
        } header: {
            Text("Trading Indicators")
        }
        Section {
            List(vm.entry ? 0..<vm.entryTitleFrame[1].count : 0..<vm.exitTitleFrame[1].count, id: \.self) { idx in
                Button() {
                    vm.transitionState(key: vm.keysAtSection1[idx])
                    isPresented = true
                } label: {
                HStack {
                    Image(systemName: "dollarsign.circle")
                    VStack(alignment: .leading) {
                        Text(vm.entry ? vm.entryTitleFrame[1][idx] : vm.exitTitleFrame[1][idx])
                            .font(.caption.bold())
                        Text(vm.entry ? vm.entryDescriptionFrame[1][idx] : vm.exitDescriptionFrame[1][idx])
                            .font(.caption2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
                .frame(height: 0.1 * Dimensions.height)
                }
                .foregroundColor(.black)
                
            }
        } header: {
            Text(vm.entry ? "" : "Custom targets")
        }
    }
    .onAppear {
        vm.selectedDictIndex = self.selectedDictIndex
    }
    .customSheet(isPresented: $isPresented, frame: vm.frame) {
        PopupView(shouldPopToRootView: self.$rootIsActive, entryForm: true)
            .environmentObject(vm)
    }
    }
    
}
