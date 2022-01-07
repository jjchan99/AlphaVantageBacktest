//
//  InputState.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/1/22.
//

import Foundation
import SwiftUI

class InputState: ObservableObject {
    @Published private(set) var selectedWindowIdx: Int = 0 { didSet {
//        Log.queue(action: "selected window: \(selectedWindowIdx)")
    }}
    
    @Published private(set) var anotherSelectedWindowIdx: Int = 0 { didSet {
//        Log.queue(action: "selected window: \(selectedWindowIdx)")
    }}
    
    @Published private(set) var selectedPositionIdx: Int = 0 { didSet {
        validationState = updateValidationState()
    }}
    @Published private(set) var selectedPercentage: Double = 0 { didSet {
//        Log.queue(action: "selected percentage: \(selectedPercentage)")
        validationState = updateValidationState()
    }}
    
    @Published private(set) var stepperValue: Int = 2
    
    func set(selectedWindowIdx: Int? = nil, anotherSelectedWindowIdx: Int? = nil, selectedPositionIdx: Int? = nil, selectedPercentage: Double? = nil, stepperValue: Int? = nil) {
        if let selectedPercentage = selectedPercentage {
            self.selectedPercentage = selectedPercentage
        }
        
        if let selectedWindowIdx = selectedWindowIdx {
            self.selectedWindowIdx = selectedWindowIdx
        }
        
        if let stepperValue = stepperValue {
            self.stepperValue = stepperValue
        }
        
        if let selectedWindowIdx = selectedWindowIdx {
            self.selectedWindowIdx = selectedWindowIdx
        }
        
        if let selectedPositionIdx = selectedPositionIdx {
            self.selectedPositionIdx
        }
        
    }
    
    func reset() {
        selectedWindowIdx = 0
        selectedPercentage = 0
        selectedPositionIdx = 0
        anotherSelectedWindowIdx = 0
        stepperValue = 2
    }
}
