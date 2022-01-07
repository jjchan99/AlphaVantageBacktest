//
//  IndexPathState.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/1/22.
//

import Foundation
import SwiftUI

class IndexPathState: ObservableObject {
    @Published private(set)var section: Int = 0 { didSet {
        Log.queue(action: "section: \(section)")
    }}
    @Published private(set) var index: Int = 0 { didSet {
        Log.queue(action: "index: \(index)")
    }}
    
    @Published private(set) var selectedTabIndex: Int = 0
    
    @Published private(set) var selectedDictIndex: Int = 0
    
    func set(section: Int? = nil, index: Int? = nil, selectedTabIndex: Int? = nil, selectedDictIndex: Int? = nil) {
        if let section = section {
            self.section = section
        }
        
        if let index = index {
            self.index = index
        }
        
        if let selectedTabIndex = selectedTabIndex {
            self.selectedTabIndex = selectedTabIndex
        }
        
        if let selectedDictIndex = selectedDictIndex {
            self.selectedDictIndex = selectedDictIndex
        }
    }
    
    func reset() {
        section = 0
        index = 0
        selectedTabIndex = 0
        selectedDictIndex = 0
    }
}
