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
    var body: some View {
        ZStack {
            
        }
        .onAppear {
            ChartLibraryGeneric.render(data: <#T##[T]#>, setItemsToPlot: {
                
            })
        }
    }
}

struct Exponential: ChartPointSpecified {
    typealias T = Double
    
    
    
}
