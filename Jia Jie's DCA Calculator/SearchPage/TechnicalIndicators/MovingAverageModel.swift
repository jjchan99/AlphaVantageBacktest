//
//  TradeAlgo.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/11/21.
//

import Foundation
import CoreGraphics
import SwiftUI

struct SimpleMovingAverageCalculator {
    
    let window: Int
    var windowSum: Double = 0
    var queue: [Double] = []
    var max: Double = 0
    var min: Double = .infinity
    var array: [Double] = []
    
    init(window: Int) {
        self.window = window
    }
    
    mutating func dequeue() -> Double {
        guard queue.count > 0 else { fatalError() }
        let first = queue[0]
        queue.remove(at: 0)
        return first
    }
    
    mutating func movingAverage(data: Double, completion: (Double) -> Void) {
    
        windowSum += data
        queue.append(data)
        let index = array.count
        let window = index < self.window ? index + 1 : self.window
        if index >= window {
            windowSum -= dequeue()
        }
        let average = Double(windowSum) / Double(window)
        self.max = average > max ? average : max
        self.min = average < min ? average : min
        array.append(average)
//        print("Average for \(queue.count) numbers \(queue) is \(average)")
        completion(average)
    }

}

extension SimpleMovingAverageCalculator {
    func stdev(avg: Double) -> Double {
      let v = self.queue.reduce(0, { $0 + (($1-avg) ^^ 2) })
      return sqrt(v / Double(self.queue.count - 1))
    }
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Double, power: Double) -> Double {
    return (pow(radix, power))
}
