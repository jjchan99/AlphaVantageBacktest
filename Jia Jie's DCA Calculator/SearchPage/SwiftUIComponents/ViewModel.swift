//
//  ViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/10/21.
//

import Foundation
import SwiftUI

class GraphViewModel: ObservableObject {
    
    @Published var id = UUID()
    
    @Published var results: [DCAResult] = [] {
        willSet {
                   objectWillChange.send()
                   self.id = UUID()
            selectedIndex = 0
               }
        didSet {
            selectedIndex = 0
        }
    }
    lazy var padding: CGFloat = 0.05 * width
    @Published var shouldDrawGraph: Bool?
    
    @Published var meta: DCAResultMeta?
    
    @Published var percentage: CGFloat = 0
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(428).wScaled()
    
    @Published var offset: CGFloat = .zero
    
    @Published var selectedIndex: Int?
}
