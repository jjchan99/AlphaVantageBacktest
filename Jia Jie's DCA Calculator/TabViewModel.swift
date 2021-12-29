//
//  TabViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/11/21.
//

import Foundation
import SwiftUI

class TabViewModel: ObservableObject {
    @Published var selectedIndex: Int = 0
    
    var index0tapped: (() -> ())?
    var index1tapped: (() -> ())?
    var index2tapped: (() -> ())?
}
