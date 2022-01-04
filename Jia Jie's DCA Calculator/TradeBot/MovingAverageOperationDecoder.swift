//
//  MovingAverageOperationDecoder.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 4/1/22.
//

import Foundation

struct MAOperationDecoder {
    
    static func decode(rawValue: Double) -> (period1: Int, period2: Int) {
        return table[rawValue]!
    }
    
    private static let table: [Double: (period1: Int, period2: Int)] = [
        2020 : (period1: 20, period2: 20),
        2050 : (period1: 20, period2: 50),
        20100 : (period1: 20, period2: 100),
        20200 : (period1: 20, period2: 200),
        5020 : (period1: 50, period2: 20),
        5050 : (period1: 50, period2: 50),
        50100 : (period1: 50, period2: 100),
        50200 : (period1: 50, period2: 200),
        10020 : (period1: 100, period2: 20),
        10050 : (period1: 100, period2: 50),
        100100 : (period1: 100, period2: 100),
        100200 : (period1: 100, period2: 200),
        20020 : (period1: 200, period2: 20),
        20050 : (period1: 200, period2: 50),
        200100 : (period1: 200, period2: 100),
        200200 : (period1: 200, period2: 200)
    ]
}
