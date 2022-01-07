//
//  InputState.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/1/22.
//

import Foundation
import SwiftUI

class InputState: ObservableObject {
    @Published var selectedWindowIdx: Int = 0 { didSet {
//        Log.queue(action: "selected window: \(selectedWindowIdx)")
    }}
    
    @Published var anotherSelectedWindowIdx: Int = 0 { didSet {
//        Log.queue(action: "selected window: \(selectedWindowIdx)")
    }}
    
    @Published var selectedPositionIdx: Int = 0 { didSet {
        validationState = updateValidationState()
    }}
    @Published var selectedPercentage: Double = 0 { didSet {
//        Log.queue(action: "selected percentage: \(selectedPercentage)")
        validationState = updateValidationState()
    }}
    
    @Published var stepperValue: Int = 2
}
