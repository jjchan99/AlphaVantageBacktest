//
//  PopupViews.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

struct PopupView: View {
    @EnvironmentObject var vm: InputViewModel
    var titleIdx: Int 
    var frame: Int
    @State private var percentB: Double = 0
    @State private var isPresented = false
    @State private var selected = 1
    let selectedColor: Color = Color.yellow
    @State private var selectedButtonIdx: Int = 0
    @State private var isOn = false
    
    var body: some View {
        NavigationView {
            VStack {
                Slider(value: $percentB, in: 0...100)
                Text("\(percentB, specifier: "%.1f")")
                
                HStack {
                    Button("Buy") {
                        selectedButtonIdx = 0
                    }.buttonStyle(.borderedProminent)
                        .tint(selectedButtonIdx == 0 ? .mint : self.selectedColor)
                     
                      
                    Button("Sell") {
                        selectedButtonIdx = 1
                    }.buttonStyle(.borderedProminent)
                        .tint(selectedButtonIdx == 1 ? .mint : self.selectedColor)
                }
                
                Picker("Selected", selection: $selectedButtonIdx) {
                    Text("hello").tag(0)
                    Text("James English").tag(1)
                }
                Spacer()
                }
                .navigationTitle(vm.titleFrame[frame][titleIdx])
                .navigationBarTitleDisplayMode(.inline)
            
        }
       
    }
}
