//
//  ValidationState.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/1/22.
//

import Foundation
import SwiftUI

class ValidationState: ObservableObject {
    @Published var validationState: Bool = true
    
    @Published var validationMessage: String = ""
}
