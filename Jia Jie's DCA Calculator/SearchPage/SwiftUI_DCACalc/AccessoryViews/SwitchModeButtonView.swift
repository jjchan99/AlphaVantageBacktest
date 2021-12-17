//
//  SwitchModeButtonView.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 14/10/21.
//

import SwiftUI

struct SwitchModeButton: View {
    
    @Binding var mode: Mode
    var left: Bool
    
    init(mode: Binding<Mode>, left: Bool) {
        self._mode = mode
        self.left = left
    }
    
    var body: some View {
        left ?
        Button {
            switch mode {
            case .gain:
                mode = .yield
            case .annualReturn:
                mode = .gain
            case .yield:
                mode = .annualReturn
            }
        } label: {
            Image(systemName: "arrow.left")
        }
            :
            Button {
                switch mode {
                case .gain:
                    mode = .annualReturn
                case .annualReturn:
                    mode = .yield
                case .yield:
                    mode = .gain
                }
            } label : {
                Image(systemName: "arrow.right")
            }
        
    }
}

