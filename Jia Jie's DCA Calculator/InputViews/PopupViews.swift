//
//  PopupViews.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

struct BPercentPopupView: View {
    @EnvironmentObject var vm: InputViewModel
    @State private var percentB: Double = 0
    @State private var isPresented = false
    
    var body: some View {
            ZStack {
                Slider(value: $percentB, in: 0...100)
                Text("\(percentB, specifier: "%.1f")")
        }
    }
}

