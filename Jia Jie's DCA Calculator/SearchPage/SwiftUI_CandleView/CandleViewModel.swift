//
//  CandleViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

enum CandleMode: CaseIterable {
    case days5
    case months1
    case months3
    case months6
}

class CandleViewModel<T: CandlePointSpecified>: ObservableObject {
    
    init() {}
    
    @Published var sorted: [T]?
    
    let height: CGFloat = .init(350).hScaled()
    let width: CGFloat = .init(420).wScaled()
    let barHeight: CGFloat = .init(45).hScaled()
    lazy var heightScaledForSingleCandleView: CGFloat = 0.5 * width
    
//    @Published var charts: ChartLibrary? { didSet {
//        Log.queue(action: "Charts are ready")
//        indicator = .init(height: height, width: width, dataToDisplay: charts!.candles)
//    }}
    
    @Published var specifications: Specifications<T.T>?
    
    @Published var chartsOutput: ChartLibraryOutput<T>?
    
    @Published var selectedIndex: Int?
    
    @Published var modeChanged: ((CandleMode) -> ())?
    
    @Published var indicator: CandleIndicator<OHLCCloudElement>?
    
    lazy var padding: CGFloat = 0.05 * width
    
    
   
    
    
    
    
    
}


