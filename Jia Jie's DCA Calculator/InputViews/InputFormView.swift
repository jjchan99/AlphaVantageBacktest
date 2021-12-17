//
//  InputForm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    let factory = BotFactory()
    let symbol: String = "TSLA"
    let width: CGFloat = .init(50).wScaled()
    let height: CGFloat = .init(50).hScaled()
}

struct InputMenuView: View {
    
    @EnvironmentObject var vm: InputViewModel
    var body: some View {
        GridStack(rows: 3, columns: 3) { row, col in
            HStack {
           
            }
        }
    }
}

struct InputCustomizationView: View {
    @EnvironmentObject var vm: InputViewModel
    
    
    var body: some View {
        List(0...4, id: \.self) { idx in
            Text("HELLO")
            
        }
        .frame(width: Dimensions.width, height: Dimensions.height)
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    @ViewBuilder let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack {
                    ForEach(0..<columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
}
