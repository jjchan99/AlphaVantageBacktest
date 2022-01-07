//
//  IndexPathState.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/1/22.
//

import Foundation
import SwiftUI

class IndexPathState: ObservableObject {
    @Published var section: Int = 0 { didSet {
        Log.queue(action: "section: \(section)")
    }}
    @Published var index: Int = 0 { didSet {
        Log.queue(action: "index: \(index)")
    }}
    
    @Published var selectedTabIndex: Int = 0
    
    @Published var selectedDictIndex: Int = 0
}
