//
//  CandleViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

enum CandleMode {
    case days5
    case months1
    case months3
    case months6
}

class CandleViewModel: ObservableObject {
    
    @Published var sorted: [OHLC]? {
        didSet {
            self.id = UUID()
            
            
        }
    }
    
    let height: CGFloat = .init(350).hScaled()
    let width: CGFloat = .init(420).wScaled()
    let barHeight: CGFloat = .init(45).hScaled()
    
    @Published var charts: ChartLibrary?
    
    @Published var selectedIndex: Int?
    
    @Published var modeChanged: ((CandleMode) -> ())?
    
    @Published var id = UUID()
    
    lazy var padding: CGFloat = 0.05 * width
    
    
   
    
    
    
    
    
}


