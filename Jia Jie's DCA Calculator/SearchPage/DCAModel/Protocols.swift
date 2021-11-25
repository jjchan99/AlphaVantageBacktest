//
//  Protocols.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 15/9/21.
//

import Foundation

protocol TSMAtoOHLC {
    func getOhlcArray() -> [OHLC]
}

protocol DCAMethods {
    func getTotalShares(OHLCData: [OHLC], initialInvestment: Double, monthlyInvestment: Double, monthIndex: Int) -> Double
    func getAccumulatedInvestment(initialInvestment: Double, monthlyInvestment: Double, monthIndex: Int) -> Double
    func getGain(currentValue: Double, accumulatedInvestment: Double) -> Double
    func getYield(gain: Double, accumulatedInvestment: Double) -> Double
    func getAnnualReturn(yield: Double, monthIndex: Int) -> Double
}
