//
//  PercentageChangeModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 1/12/21.
//

import Foundation

struct PercentageChange {
    
    let first: Double
    var percentageChangeArray: [Double] = []
    
    init(first: Double) {
        self.first = first
    }
    
   mutating func percentageChange(new: Double) {
        let percentageChange = (new - first) / first
        percentageChangeArray.append(percentageChange)
    }
    
    
}
