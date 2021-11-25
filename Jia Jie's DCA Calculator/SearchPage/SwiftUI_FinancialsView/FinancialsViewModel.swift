//
//  FinancialsViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 7/11/21.
//

import SwiftUI
import Foundation

class FinancialsViewModel: ObservableObject {
    
    @Published var bs: BalanceSheet?
    @Published var pl: IncomeStatement?
    @Published var earnings: Earnings?
    
    let height: CGFloat = CGFloat(300).hScaled()
    let width: CGFloat = CGFloat(428).wScaled()
    
}

