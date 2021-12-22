//
//  DCACalculator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 14/9/21.
//

import Foundation
import CoreGraphics

struct DCACalculator {
    
    let initialInvestment: Double
    let monthlyInvestment: Double
    let sortedData: [OHLC]
    let monthIndex: Int
    
    init(initialInvestment: Double, monthlyInvestment: Double, sortedData: [OHLC], monthIndex: Int) {
        self.initialInvestment = initialInvestment
        self.monthlyInvestment = monthlyInvestment
        self.sortedData = sortedData
        self.monthIndex = monthIndex
    }
    
    func calculate() -> (result: [DCAResult], meta: DCAResultMeta) {
        var OHLCData: [OHLC] = []
     
        var dcaResultArray: [DCAResult] = []
        var meta: DCAResultMeta?
        
        for monthIndex in 0...self.monthIndex {
            OHLCData.append(sortedData[self.monthIndex - monthIndex])
            let accumulatedInvestment = getAccumulatedInvestment(initialInvestment: initialInvestment, monthlyInvestment: monthlyInvestment, monthIndex: monthIndex)
            
            let totalShares = getTotalShares(OHLCData: OHLCData, initialInvestment: initialInvestment, monthlyInvestment: monthlyInvestment, monthIndex: monthIndex)
            
            let currentValue = totalShares * getSellingPrice(monthIndex: monthIndex, OHLCData: OHLCData)
            
            let gain = getGain(currentValue: currentValue, accumulatedInvestment: accumulatedInvestment)
            let yield = getYield(gain: gain, accumulatedInvestment: accumulatedInvestment)
            let annualReturn = getAnnualReturn(yield: yield, monthIndex: monthIndex)
            
            if meta == nil { meta = DCAResultMeta(minYield: yield, maxYield: yield, minGain: gain, maxGain: gain, minAnnualReturn: annualReturn, maxAnnualReturn: annualReturn, minCurrentValue: currentValue, maxCurrentValue: currentValue) } else {
                meta!.maxAnnualReturn = meta!.maxAnnualReturn > annualReturn ?  meta!.maxAnnualReturn : annualReturn
                meta!.minAnnualReturn = meta!.minAnnualReturn < annualReturn ?  meta!.minAnnualReturn : annualReturn
                meta!.maxGain = meta!.maxGain > gain ?  meta!.maxGain : gain
                meta!.minGain = meta!.minGain < gain ? meta!.minGain : gain
                meta!.maxYield = meta!.maxYield > yield ? meta!.maxYield : yield
                meta!.minYield = meta!.minYield < yield ? meta!.minYield : yield
                meta!.maxCurrentValue = meta!.maxCurrentValue > currentValue ? meta!.maxCurrentValue : currentValue
                meta!.minCurrentValue = meta!.minCurrentValue < currentValue ? meta!.minCurrentValue : currentValue
            }
            
            let result = DCAResult(symbol: sortedData[0].meta.symbol, currentValue: currentValue, accumulatedInvestment: accumulatedInvestment, gain: gain, yield: yield, annualReturn: annualReturn, month: OHLCData[monthIndex].stamp)
            dcaResultArray.append(result)
        }
        
        return (dcaResultArray, meta!)
    }
}

extension DCACalculator {
    func getAnnualReturn(yield: Double, monthIndex: Int) -> Double {
        let numberOfYears = (Double(monthIndex) + 1)  / 12
        return 100 * (pow(1 + (yield * 0.01), 1 / numberOfYears) - 1)
    }
    
    func getTotalShares(OHLCData: [OHLC], initialInvestment: Double, monthlyInvestment: Double, monthIndex: Int) -> Double {
        let OHLCData = OHLCData.prefix(upTo: monthIndex + 1)
        
        var accumulatedShares: Double = 0
        for idx in 0..<OHLCData.count {
            let previousOpen: Double = Double(OHLCData[idx].open)!
            let additionalShares = idx == 0 ? initialInvestment / previousOpen : monthlyInvestment / previousOpen
            accumulatedShares += additionalShares
//            print("check this: accumulated investment \(accumulatedInvestment) at monthIndex \(monthIndex). accumulated shares is \(accumulatedShares)")
        }
        return accumulatedShares
    }
    
    func getAccumulatedInvestment(initialInvestment: Double, monthlyInvestment: Double, monthIndex: Int) -> Double {
        let accumulatedInvestment = initialInvestment + (monthlyInvestment * Double(monthIndex))
        return accumulatedInvestment
    }
    
    func getGain(currentValue: Double, accumulatedInvestment: Double) -> Double {
        return currentValue - accumulatedInvestment
    }
    
    func getYield(gain: Double, accumulatedInvestment: Double) -> Double {
        return 100 * (gain / accumulatedInvestment)
    }
    
    func getSellingPrice(monthIndex: Int, OHLCData: [OHLC]) -> Double {
        let sellingPrice = Double(OHLCData[monthIndex].close)!
//        print("sellingPrice is \(sellingPrice)")
        return sellingPrice
    }
}

//struct OHLC: Equatable {
//    var symbol: String
//    var monthlyDateStamp: String
//    var open: String
//    var high: String
//    var low: String
//    var close: String
//    var adjustedClose: String
//
//    static func == (lhs: OHLC, rhs: OHLC) -> Bool {
//        return lhs.monthlyDateStamp == rhs.monthlyDateStamp
//    }
//
//}

enum Mode {
    case gain
    case yield
    case annualReturn
    
    func getTitle() -> String {
        switch self {
        case .gain:
        return "Gain"
        case .yield:
        return "Yield"
        case .annualReturn:
        return "Annual Return"
    }
    }
    
    func format(float: CGFloat) -> String {
        switch self {
        case .gain:
            return "\(Double(float).roundedWithAbbreviations)"
        case .annualReturn:
            return "\(Double(float).percentageFormat)"
        case .yield:
            return "\(Double(float).percentageFormat)"
        }
    }
    
    func format(double: Double) -> String {
        switch self {
        case .gain:
            return "\(double.roundedWithAbbreviations)"
        case .annualReturn:
            return "\(double.percentageFormat)"
        case .yield:
            return "\(double.percentageFormat)"
        }
    }
}




