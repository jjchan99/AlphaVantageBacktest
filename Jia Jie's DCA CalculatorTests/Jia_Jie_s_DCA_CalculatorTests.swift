//
//  Jia_Jie_s_DCA_CalculatorTests.swift
//  Jia Jie's DCA CalculatorTests
//
//  Created by Jia Jie Chan on 9/10/21.
//

import XCTest
import Combine
import Foundation
@testable import Jia_Jie_s_DCA_Calculator

class Jia_Jie_s_DCA_CalculatorTests: XCTestCase {
    
    var sut: DCACalculator!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        let mockSubject = createMockSubject()
        sut = DCACalculator(subject: mockSubject, initialInvestment: 5000, monthlyInvestment: 1500, sortedData: mockSubject.sortedData(), monthIndex: 9)
        print("Should be: \(sut.sortedData[0].value.close)")
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        sut = nil
    }
    
    private func createMockSubject() -> TimeSeriesMonthlyAdjusted {
        let meta = TimeSeriesMonthlyAdjusted.Meta(information: "Mock Company", symbol: "Mock", lastRefreshed: "Not Important", timeZone: "Not Important")
        var data: [String: TimeSeriesMonthlyAdjusted.Data] = [:]
        let datesArray: [String] = ["2021-10-08", "2021-09-30", "2021-08-31", "2021-07-30", "2021-06-30", "2021-05-28", "2021-04-30", "2021-03-31", "2021-02-26", "2021-01-29"]
    
        for dates in datesArray {
            data[dates] = TimeSeriesMonthlyAdjusted.Data(open: "\(Int.random(in: 100...200))", high: "\(Int.random(in: 100...200))", low: "\(Int.random(in: 100...200))", close: "\(Int.random(in: 100...200))", adjustedClose: "\(Int.random(in: 100...200))", volume: "\(Int.random(in: 100...200))", dividendAmount: "\(Int.random(in: 100...200))")
        }
        let subject = TimeSeriesMonthlyAdjusted(metaData: meta, data: data)
        return subject
    }
    
    func testResult() {
        //MARK: TEST SUBJECT
        let testSubject = sut.calculate()
        
        //MARK: SOURCES OF TRUTH
        let sourceOfTruth = sut.subject.data.sorted(by: {
            $0.key < $1.key
        })
        let accumulatedInvestment: [Double] = [5000, 6500, 8000, 9500, 11000, 12500, 14000, 15500, 17000, 18500]
        var OHLCArray: [OHLC] = []
        var accumulatedShares: Double = 0
       
        
        for idx in 0..<testSubject.result.count {
            
            //MARK: SOURCES OF TRUTH
            let sellingPrice = sourceOfTruth[idx].value.close
            let OHLCElement = OHLC(symbol: sut.subject.metaData.symbol, monthlyDateStamp: sourceOfTruth[idx].key, open: sourceOfTruth[idx].value.open, high: sourceOfTruth[idx].value.high, low: sourceOfTruth[idx].value.low, close: sourceOfTruth[idx].value.close, adjustedClose: sourceOfTruth[idx].value.adjustedClose)
            OHLCArray.append(OHLCElement)
            let adjustedOpen: Double = ((Double(sourceOfTruth[idx].value.open)! * Double(sourceOfTruth[idx].value.adjustedClose)!)) / Double(sourceOfTruth[idx].value.close)!
            let additionalShares = idx == 0 ? 5000.00 / adjustedOpen : 1500 / adjustedOpen
            accumulatedShares += additionalShares
            let currentValue = accumulatedShares*Double(sellingPrice)!
            let gain = currentValue - accumulatedInvestment[idx]
            let yield = 100 * (gain / accumulatedInvestment[idx])
            let annualReturn = 100 * (pow(1 + (yield * 0.01), 1 / (Double(idx+1)/12)) - 1)
            guard OHLCArray.count != 0 else { fatalError() }
        
            XCTAssertEqual(testSubject.result[idx].currentValue, currentValue, accuracy: 0.01)
            XCTAssertEqual(testSubject.result[idx].accumulatedInvestment, accumulatedInvestment[idx])
            XCTAssertEqual(testSubject.result[idx].gain, gain, accuracy: 0.01)
//            XCTAssertEqual(sut.getTotalShares(OHLCData: OHLCArray, initialInvestment: 5000, monthlyInvestment: 1500, monthIndex: idx), accumulatedShares, accuracy: 0.01)
            XCTAssertEqual(testSubject.result[idx].annualReturn, annualReturn, accuracy: 0.01)
            XCTAssertEqual(testSubject.result[idx].yield, yield, accuracy: 0.01)
            //print("received: \(sut.getTotalShares(OHLCData: OHLCArray, initialInvestment: 5000, monthlyInvestment: 1500, monthIndex: idx)), actual: \(accumulatedShares). Adjusted open: \(adjustedOpen)")
        }
    }
}
